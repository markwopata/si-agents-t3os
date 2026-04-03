view: geofence_transfers {


  derived_table: {
    sql:
 with base as (
    select
        company_id,
        geofence_id,
        geofence_name,
        asset_id,
        usage_date,
        hours_in_geofence,
        tracker_health_status
    from business_intelligence.triage.stg_t3__geofence_asset_usage
    where company_id = 109154
      and usage_date >= current_date - 365
),

assets_dim as (
    select
        asset_id,
        asset_class
    from es_warehouse.public.assets
),

base_w_class as (
    select
        b.company_id,
        b.geofence_id,
        b.geofence_name,
        b.asset_id,
        b.usage_date,
        b.hours_in_geofence,
        b.tracker_health_status,
        a.asset_class
    from base b
    left join assets_dim a
      on b.asset_id = a.asset_id
),

/* =====================================================
   A) Destination Geofences = "Asset dependency risk"
   ===================================================== */

geofence_rollup as (
    select
        company_id,
        geofence_id,
        max(geofence_name) as geofence_name,
        sum(hours_in_geofence) as total_usage_365d,
        sum(case when usage_date >= current_date - 90 then hours_in_geofence else 0 end) as total_usage_90d,
        max(usage_date) as last_usage_date_365d
    from base
    group by company_id, geofence_id
),

usage_threshold as (
    select
        approx_percentile(total_usage_365d, 0.80) as p80_total_usage_365d
    from geofence_rollup
),

asset_rollup as (
    select
        geofence_id,
        asset_id,
        sum(hours_in_geofence) as asset_usage_365d
    from base
    group by geofence_id, asset_id
),

asset_ranked as (
    select
        geofence_id,
        asset_id,
        asset_usage_365d,
        sum(asset_usage_365d) over (partition by geofence_id) as geofence_usage_365d,
        row_number() over (partition by geofence_id order by asset_usage_365d desc) as asset_rank,
        sum(asset_usage_365d) over (
            partition by geofence_id
            order by asset_usage_365d desc
            rows between unbounded preceding and current row
        ) as cum_asset_usage_365d
    from asset_rollup
),

pareto as (
    select
        geofence_id,
        min(case
              when geofence_usage_365d = 0 then null
              when cum_asset_usage_365d / geofence_usage_365d >= 0.80 then asset_rank
            end) as assets_to_80pct,
        count(*) as total_assets_with_usage
    from asset_ranked
    group by geofence_id
),

dependency_geofences as (
    select
        g.geofence_id,
        g.geofence_name,
        g.total_usage_365d,
        g.total_usage_90d,
        p.assets_to_80pct,
        p.total_assets_with_usage
    from geofence_rollup g
    cross join usage_threshold t
    join pareto p
      on g.geofence_id = p.geofence_id
    where g.total_usage_365d >= t.p80_total_usage_365d          -- top 20% by usage
      and g.last_usage_date_365d >= current_date - 90           -- recent usage
      and p.total_assets_with_usage >= 5                        -- avoid tiny geofences
      and p.assets_to_80pct is not null
      and (p.assets_to_80pct / p.total_assets_with_usage::float) <= 0.20   -- 80/20 concentration
),

/* Destination "top assets" (those with asset_rank <= assets_to_80pct) */
dest_top_assets as (
    select
        r.geofence_id,
        r.asset_id
    from asset_ranked r
    join pareto p
      on r.geofence_id = p.geofence_id
     and r.asset_rank <= p.assets_to_80pct
),

/* Destination "top asset classes" (distinct non-null classes among top assets) */
dest_top_asset_classes as (
    select
        dta.geofence_id,
        array_agg(distinct ad.asset_class) as dest_top_assets_asset_classes
    from dest_top_assets dta
    join assets_dim ad
      on dta.asset_id = ad.asset_id
    where ad.asset_class is not null
    group by dta.geofence_id
),

/* Optional: also expose the top asset_ids as an array for debugging/UX */
dest_top_asset_ids as (
    select
        geofence_id,
        array_agg(asset_id) as dest_top_asset_ids
    from (
        select distinct geofence_id, asset_id
        from dest_top_assets
    )
    group by geofence_id
),

dest_geofences_final as (
    select
        dg.*,
        dtac.dest_top_assets_asset_classes,
        dtaids.dest_top_asset_ids
    from dependency_geofences dg
    left join dest_top_asset_classes dtac
      on dg.geofence_id = dtac.geofence_id
    left join dest_top_asset_ids dtaids
      on dg.geofence_id = dtaids.geofence_id
),

/* =====================================================
   B) Candidate assets to transfer
   ===================================================== */

recent_assets as (
    select
        asset_id,
        max(usage_date) as last_usage_date_90d
    from base
    where usage_date >= current_date - 90
      and hours_in_geofence > 0
    group by asset_id
),

eligible_assets as (
    select distinct
        b.asset_id,
        b.asset_class,
        b.tracker_health_status
    from base_w_class b
    join recent_assets r
      on b.asset_id = r.asset_id
    where b.tracker_health_status in (
          'Healthy - HEALTHY',
          'Asset Likely In Low Cell Coverage Area - LIKELY IN LOW CELL COVERAGE AREA',
          'Asset Likely Under Cover or Inside Building - LIKELY UNDER COVER OR INSIDE BUILDING'
      )
),

/* Origin geofence = geofence of most recent usage in last 90 days */
asset_origin as (
    select
        b.asset_id,
        b.geofence_id as origin_geofence_id,
        b.geofence_name as origin_geofence_name,
        b.usage_date as origin_last_usage_date
    from base_w_class b
    join recent_assets r
      on b.asset_id = r.asset_id
     and b.usage_date = r.last_usage_date_90d
    qualify row_number() over (partition by b.asset_id order by b.usage_date desc) = 1
),

/* Origin usage (last 90d) within that origin geofence */
origin_usage as (
    select
        b.asset_id,
        ao.origin_geofence_id,
        sum(b.hours_in_geofence) as origin_usage_90d
    from base_w_class b
    join asset_origin ao
      on b.asset_id = ao.asset_id
     and b.geofence_id = ao.origin_geofence_id
    where b.usage_date >= current_date - 90
    group by b.asset_id, ao.origin_geofence_id
),

candidate_assets as (
    select
        ea.asset_id,
        ea.asset_class,
        ea.tracker_health_status,
        ao.origin_geofence_id,
        ao.origin_geofence_name,
        ao.origin_last_usage_date,
        ou.origin_usage_90d
    from eligible_assets ea
    join asset_origin ao
      on ea.asset_id = ao.asset_id
    join origin_usage ou
      on ea.asset_id = ou.asset_id
     and ao.origin_geofence_id = ou.origin_geofence_id
    where ou.origin_usage_90d <= 1      -- negligible threshold (hours)
),

/* =====================================================
   C) Recommend destination geofences with match logic
   ===================================================== */

/* A) Exact match: candidate asset_id is among destination top assets */
exact_asset_matches as (
    select
        ca.asset_id,
        dg.geofence_id as dest_geofence_id
    from candidate_assets ca
    join dest_top_assets dta
      on ca.asset_id = dta.asset_id
    join dest_geofences_final dg
      on dta.geofence_id = dg.geofence_id
    where ca.origin_geofence_id <> dg.geofence_id
),

/* B) Class match (non-null on both sides; null does NOT match) */
class_matches as (
    select
        ca.asset_id,
        dg.geofence_id as dest_geofence_id
    from candidate_assets ca
    join dest_geofences_final dg
      on ca.origin_geofence_id <> dg.geofence_id
    join dest_top_assets dta
      on dg.geofence_id = dta.geofence_id
    join assets_dim ad
      on dta.asset_id = ad.asset_id
    where ca.asset_class is not null
      and ad.asset_class is not null
      and ca.asset_class = ad.asset_class
),

matched_pairs as (
    select asset_id, dest_geofence_id from exact_asset_matches
    union
    select asset_id, dest_geofence_id from class_matches
),

recommendations as (
    select
        ca.asset_id,
        ca.asset_class,
        ca.tracker_health_status,

        ca.origin_geofence_id,
        ca.origin_geofence_name,
        ca.origin_last_usage_date,
        ca.origin_usage_90d,

        dg.geofence_id as dest_geofence_id,
        dg.geofence_name as dest_geofence_name,
        dg.total_usage_365d as dest_total_usage_365d,
        dg.total_usage_90d as dest_total_usage_90d,
        dg.assets_to_80pct,
        dg.total_assets_with_usage,

        dg.dest_top_assets_asset_classes,
        dg.dest_top_asset_ids
    from candidate_assets ca
    join matched_pairs mp
      on ca.asset_id = mp.asset_id
    join dest_geofences_final dg
      on mp.dest_geofence_id = dg.geofence_id
)

select *
from recommendations
qualify row_number() over (partition by asset_id order by dest_total_usage_365d desc) <= 5
order by dest_total_usage_365d desc, asset_id
          ;;
  }


  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }
  dimension: dest_geofence_id { type: number sql: ${TABLE}.DEST_GEOFENCE_ID ;; }

  measure: distinct_combinations {
    type: count
    value_format_name: decimal_0
  }








}
