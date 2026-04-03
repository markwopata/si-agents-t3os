view: asset_dependency_risk {



  derived_table: {
    sql:
 with base as (
    select *
    from business_intelligence.triage.stg_t3__geofence_asset_usage
    where company_id = 109154
      and usage_date >= current_date - 365
),

-- 1) Geofence rollup (L365D), plus recency (L90D)
geofence_rollup as (
    select
        company_id,
        geofence_id,
        any_value(geofence_name) as geofence_name,

        sum(hours_in_geofence) as total_usage_365d,

        sum(case
              when usage_date >= current_date - 90 then hours_in_geofence
              else 0
            end) as total_usage_90d,

        max(usage_date) as last_usage_date_365d,

        count(distinct asset_id) as distinct_assets_365d,
        count(distinct case when usage_date >= current_date - 90 then asset_id end) as distinct_assets_90d
    from base
    group by 1,2
),

-- 2) Top 20% threshold
usage_threshold as (
    select
        approx_percentile(total_usage_365d, 0.80) as p80_total_usage_365d
    from geofence_rollup
),

-- 3) Asset usage per geofence (L365D)
asset_rollup as (
    select
        geofence_id,
        asset_id,
        sum(hours_in_geofence) as asset_usage_365d
    from base
    group by 1,2
),

-- 4) Rank assets + cumulative contribution
asset_ranked as (
    select
        geofence_id,
        asset_id,
        asset_usage_365d,

        sum(asset_usage_365d) over (partition by geofence_id) as geofence_usage_365d,

        row_number() over (
            partition by geofence_id
            order by asset_usage_365d desc
        ) as asset_rank,

        sum(asset_usage_365d) over (
            partition by geofence_id
            order by asset_usage_365d desc
            rows between unbounded preceding and current row
        ) as cum_asset_usage_365d
    from asset_rollup
),

-- 5) Determine assets needed to hit 80% + collect those assets into array
pareto as (
    select
        geofence_id,

        min(case
              when geofence_usage_365d = 0 then null
              when cum_asset_usage_365d / geofence_usage_365d >= 0.80 then asset_rank
            end) as assets_to_80pct,

        count(*) as total_assets_with_usage

    from asset_ranked
    group by 1
),

-- 6) Collect the actual asset_ids contributing to 80%
top_assets as (
    select
        r.geofence_id,
        array_agg(r.asset_id) within group (order by r.asset_rank) as top_assets_array
    from asset_ranked r
    join pareto p
      on r.geofence_id = p.geofence_id
     and r.asset_rank <= p.assets_to_80pct
    group by 1
),

final as (
    select
        g.company_id,
        g.geofence_id,
        g.geofence_name,

        g.total_usage_365d,
        g.total_usage_90d,
        g.last_usage_date_365d,

        g.distinct_assets_365d,
        g.distinct_assets_90d,

        p.assets_to_80pct,
        p.total_assets_with_usage,

        case
          when p.total_assets_with_usage = 0 then null
          else p.assets_to_80pct / p.total_assets_with_usage::float
        end as share_assets_to_80pct,

        ta.top_assets_array,

        -- Flags
        (g.total_usage_365d >= t.p80_total_usage_365d) as is_top_20pct_usage,
        (g.last_usage_date_365d >= current_date - 90) as has_recent_usage_90d,
        (
          p.total_assets_with_usage >= 5
          and p.assets_to_80pct is not null
          and (p.assets_to_80pct / p.total_assets_with_usage::float) <= 0.20
        ) as is_concentrated_80_20

    from geofence_rollup g
    cross join usage_threshold t
    left join pareto p
      on g.geofence_id = p.geofence_id
    left join top_assets ta
      on g.geofence_id = ta.geofence_id
)

select *
from final
where is_top_20pct_usage
  and has_recent_usage_90d
  and is_concentrated_80_20
  and assets_to_80pct <= 5
order by total_usage_365d desc
          ;;
  }


  dimension: geofence_id { type: string sql: ${TABLE}.GEOFENCE_ID ;; }
  measure: distinct_geofences {
    type: count_distinct
    sql: ${geofence_id} ;;
    value_format_name: decimal_0
  }




}
