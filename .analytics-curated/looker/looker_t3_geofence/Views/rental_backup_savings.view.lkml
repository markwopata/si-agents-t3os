view: rental_backup_savings {



  derived_table: {
    sql:


with on_rent as (
    select
        asset_id,
        asset_class,
        make_and_model,
        company_id,
        rental_start_date,
        price_per_day,
        billing_days_left,
        price_per_day / 8.0 as price_per_hour,
        price_per_day / 4.0 as overage_hourly_rate
    from business_intelligence.triage.stg_t3__on_rent
    where rental_start_date < current_date
    group by all
),

by_day as (
    select
        asset_id,
        date,
        coalesce(on_time_cst / 3600.0, 0) as on_time_hours_cst
    from business_intelligence.triage.stg_t3__by_day_utilization
    where date < current_date
    group by all
),

-- summarize utilization behavior over the rental window, per asset
asset_util as (
    select
        o.asset_id,
        o.asset_class,
        o.make_and_model,
        o.company_id,
        o.rental_start_date,

        max(o.billing_days_left) as billing_days_left,
        max(o.price_per_hour) as price_per_hour,
        max(o.overage_hourly_rate) as overage_hourly_rate,

        count(distinct b.date) as days_with_util_rows,  -- informational only
        avg(coalesce(b.on_time_hours_cst, 0)) as avg_on_time_hours_cst,

        /* hours */
        sum(greatest(coalesce(b.on_time_hours_cst, 0) - 8, 0)) as total_overage_hours_cst,
        sum(greatest(8 - coalesce(b.on_time_hours_cst, 0), 0)) as total_lost_opp_hours_cst

    from on_rent o
    left join by_day b
      on b.asset_id = o.asset_id
     and b.date >= o.rental_start_date
     and b.date < current_date
    group by
        o.asset_id,
        o.asset_class,
        o.make_and_model,
        o.company_id,
        o.rental_start_date
),

overutilized as (
    select *
    from asset_util
    where total_overage_hours_cst > 0
),

underutilized as (
    select *
    from asset_util
    where total_lost_opp_hours_cst > 0
      and total_overage_hours_cst = 0   -- optional: keep “clean” backups (not overutilized too)
),

-- candidate matches (make_and_model first, else asset_class)
candidates as (
    select
        o.company_id,
        o.asset_id as over_asset_id,
        o.asset_class as over_asset_class,
        o.make_and_model as over_make_and_model,
        o.rental_start_date as over_rental_start_date,
        o.avg_on_time_hours_cst as over_avg_hours_cst,
        o.total_overage_hours_cst as over_total_overage_hours_cst,

        o.billing_days_left as over_billing_days_left,
        o.price_per_hour as over_price_per_hour,
        o.overage_hourly_rate as over_overage_hourly_rate,

        u.asset_id as under_asset_id,
        u.asset_class as under_asset_class,
        u.make_and_model as under_make_and_model,
        u.rental_start_date as under_rental_start_date,
        u.avg_on_time_hours_cst as under_avg_hours_cst,
        u.total_lost_opp_hours_cst as under_total_lost_opp_hours_cst,

        u.billing_days_left as under_billing_days_left,
        u.price_per_hour as under_price_per_hour

    from overutilized o
    join underutilized u
      on u.company_id = o.company_id
     and u.asset_id <> o.asset_id
     and (
            (o.make_and_model is not null and u.make_and_model = o.make_and_model)
         or (u.asset_class = o.asset_class)
         )
),

ranked as (
    select
        *,
        row_number() over (
            partition by company_id, over_asset_id
            order by
                match_priority asc,                  -- prefer make/model
                under_total_lost_opp_hours_cst desc,  -- most underutilized backup
                under_avg_hours_cst asc,              -- tie-break: lower avg hours
                under_asset_id                        -- deterministic final tie-break
        ) as rn
    from (
        select
            *,
            case
                when over_make_and_model is not null and under_make_and_model = over_make_and_model then 1
                when under_asset_class = over_asset_class then 2
                else 99
            end as match_priority
        from candidates
    )
    where match_priority < 99
),

final_pairs as (
    select
        company_id,

        -- under (backup)
        under_asset_id,
        under_make_and_model,
        under_asset_class,

        -- over (needs backup)
        over_asset_id,
        over_make_and_model,
        over_total_overage_hours_cst,

        /* overlap of remaining billing days (don’t assume beyond either rental) */
        least(
            greatest(coalesce(over_billing_days_left, 0), 0),
            greatest(coalesce(under_billing_days_left, 0), 0)
        ) as days_remaining_overlap,

        /* per-day deltas toward 8h/day */
        greatest(over_avg_hours_cst - 8, 0) as over_hours_reduced_per_day,
        greatest(8 - under_avg_hours_cst, 0) as under_hours_increased_per_day,

        /* monetize per-day deltas */
        greatest(over_avg_hours_cst - 8, 0) * coalesce(over_overage_hourly_rate, 0) as over_savings_per_day,
        greatest(8 - under_avg_hours_cst, 0) * coalesce(under_price_per_hour, 0)      as under_savings_per_day,

        /* total estimated savings for the remaining overlap days */
        (
            greatest(over_avg_hours_cst - 8, 0) * coalesce(over_overage_hourly_rate, 0)
          + greatest(8 - under_avg_hours_cst, 0) * coalesce(under_price_per_hour, 0)
        )
        *
        least(
            greatest(coalesce(over_billing_days_left, 0), 0),
            greatest(coalesce(under_billing_days_left, 0), 0)
        ) as estimated_savings_cst

    from ranked
    where rn = 1
),

under_asset_view as (
    select
        company_id,
        under_asset_id,
        under_make_and_model,
        under_asset_class,

        /* arrays ordered by highest $ savings per day (proxy for “highest pain” to fix) */
        array_agg(over_asset_id)
            within group (order by over_savings_per_day desc, over_asset_id) as matching_over_asset_ids,

        array_agg(over_make_and_model)
            within group (order by over_savings_per_day desc, over_asset_id) as matching_over_make_and_models,

        /* floor / ceiling of estimated savings across the array */
        min(estimated_savings_cst) as estimated_savings_floor,
        max(estimated_savings_cst) as estimated_savings_celing

    from final_pairs
    group by
        company_id,
        under_asset_id,
        under_make_and_model,
        under_asset_class
)

select *
from under_asset_view
where company_id = 109154

          ;;
  }



  dimension: under_asset_id {
    type: number
    sql: ${TABLE}.UNDER_ASSET_ID ;;
  }

  dimension: under_make_and_model {
    type: string
    sql: ${TABLE}.UNDER_MAKE_AND_MODEL ;;
  }

  dimension: under_asset_class {
    type: string
    sql: ${TABLE}.UNDER_ASSET_CLASS ;;
  }

  dimension: matching_over_asset_ids {
    type: string
    sql: ${TABLE}.MATCHING_OVER_ASSET_IDS ;;
  }

  dimension: matching_over_make_and_models {
    type: string
    sql: ${TABLE}.MATCHING_OVER_MAKE_AND_MODELS ;;
  }

  dimension: estimated_savings_floor {
    type: number
    sql: ${TABLE}.ESTIMATED_SAVINGS_FLOOR ;;
    value_format_name: usd_0
  }

  dimension: estimated_savings_celing {
    type: number
    sql: ${TABLE}.ESTIMATED_SAVINGS_CELING ;;
    value_format_name: usd_0
  }







}
