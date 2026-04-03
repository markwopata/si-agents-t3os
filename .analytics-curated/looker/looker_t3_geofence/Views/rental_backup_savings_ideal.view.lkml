view: rental_backup_savings_ideal {



  derived_table: {
    sql:
 with recursive on_rent as (
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

        avg(coalesce(b.on_time_hours_cst, 0)) as avg_on_time_hours_cst,

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
      and total_overage_hours_cst = 0
),

candidate_pairs as (
    select
        o.company_id,

        -- UNDER side
        u.asset_id as under_asset_id,
        u.make_and_model as under_make_and_model,
        u.asset_class as under_asset_class,
        u.avg_on_time_hours_cst as under_avg_hours_cst,
        u.billing_days_left as under_billing_days_left,
        u.price_per_hour as under_price_per_hour,

        -- OVER side
        o.asset_id as over_asset_id,
        o.make_and_model as over_make_and_model,
        o.asset_class as over_asset_class,
        o.avg_on_time_hours_cst as over_avg_hours_cst,
        o.total_overage_hours_cst as over_total_overage_hours_cst,
        o.billing_days_left as over_billing_days_left,
        o.overage_hourly_rate as over_overage_hourly_rate,

        -- match metadata (not used for selection, just for explainability)
        case
            when o.make_and_model is not null and u.make_and_model = o.make_and_model then 'make_model'
            when u.asset_class = o.asset_class then 'asset_class'
            else null
        end as match_type,

        -- overlap of remaining days
        least(
            greatest(coalesce(o.billing_days_left, 0), 0),
            greatest(coalesce(u.billing_days_left, 0), 0)
        ) as days_remaining_overlap,

        -- estimated savings (CST)
        (
            greatest(o.avg_on_time_hours_cst - 8, 0) * coalesce(o.overage_hourly_rate, 0)
          + greatest(8 - u.avg_on_time_hours_cst, 0) * coalesce(u.price_per_hour, 0)
        )
        *
        least(
            greatest(coalesce(o.billing_days_left, 0), 0),
            greatest(coalesce(u.billing_days_left, 0), 0)
        ) as estimated_savings_cst

    from overutilized o
    join underutilized u
      on u.company_id = o.company_id
     and u.asset_id <> o.asset_id
     and (
            (o.make_and_model is not null and u.make_and_model = o.make_and_model)
         or (u.asset_class = o.asset_class)
         )
),

-- optional: if you want to test a single company, keep this filter.
-- removing it will compute greedily per-company only if you run per-company (recommended).
candidate_pairs_scoped as (
    select *
    from candidate_pairs
    where company_id = 109154
      and estimated_savings_cst is not null
      and estimated_savings_cst > 0
),

greedy as (
  select
    company_id,
    under_asset_id,
    under_make_and_model,
    under_asset_class,
    over_asset_id as ideal_over_asset_id,
    over_make_and_model as ideal_over_make_and_model,
    over_asset_class as ideal_over_asset_class,
    match_type,
    estimated_savings_cst as ideal_estimated_savings
  from candidate_pairs_scoped
  qualify
    row_number() over (
      partition by company_id, under_asset_id
      order by estimated_savings_cst desc, over_total_overage_hours_cst desc, over_asset_id
    ) = 1
    and row_number() over (
      partition by company_id, over_asset_id
      order by estimated_savings_cst desc, over_total_overage_hours_cst desc, under_asset_id
    ) = 1
)


select
    company_id,
    under_asset_id,
    under_make_and_model,
    under_asset_class,
    ideal_over_asset_id,
    ideal_over_make_and_model,
    ideal_over_asset_class,
    match_type,
    ideal_estimated_savings
from greedy
order by ideal_estimated_savings desc
          ;;
  }


  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
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

  dimension: ideal_over_asset_id {
    type: number
    sql: ${TABLE}.IDEAL_OVER_ASSET_ID ;;
  }

  dimension: ideal_over_make_and_model {
    type: string
    sql: ${TABLE}.IDEAL_OVER_MAKE_AND_MODEL ;;
  }

  dimension: ideal_over_asset_class {
    type: string
    sql: ${TABLE}.IDEAL_OVER_ASSET_CLASS ;;
  }

  dimension: match_type {
    type: string
    sql: ${TABLE}.MATCH_TYPE ;;
  }

  dimension: ideal_estimated_savings {
    type: number
    sql: ${TABLE}.IDEAL_ESTIMATED_SAVINGS ;;
    value_format_name: usd_0
  }




}
