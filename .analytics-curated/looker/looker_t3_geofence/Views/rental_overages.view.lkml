view: rental_overages {



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
        price_per_day / 8.0 as price_per_hour,
        price_per_day / 4.0 as overage_hourly_rate,   -- double-time vs normal hourly
        billing_days_left
    from business_intelligence.triage.stg_t3__on_rent
    where rental_start_date < current_date
    group by all
),

by_day as (
    select
        asset_id,
        date,

        coalesce(on_time_cst / 3600.0, 0) as on_time_hours_cst,
        coalesce(on_time_est / 3600.0, 0) as on_time_hours_est,
        coalesce(on_time_mnt / 3600.0, 0) as on_time_hours_mnt,
        coalesce(on_time_utc / 3600.0, 0) as on_time_hours_utc,
        coalesce(on_time_wst / 3600.0, 0) as on_time_hours_wst
    from business_intelligence.triage.stg_t3__by_day_utilization
    where date < current_date
    group by all
),

rental_day as (
    select
        o.asset_id,
        o.asset_class,
        o.make_and_model,
        o.company_id,
        o.rental_start_date,
        o.price_per_hour,
        b.date,

        o.price_per_day,
        o.overage_hourly_rate,

        /* Total Hours (coalesced so missing-utilization days act like 0) */
        coalesce(b.on_time_hours_cst, 0) as on_time_hours_cst,
        coalesce(b.on_time_hours_est, 0) as on_time_hours_est,
        coalesce(b.on_time_hours_mnt, 0) as on_time_hours_mnt,
        coalesce(b.on_time_hours_utc, 0) as on_time_hours_utc,
        coalesce(b.on_time_hours_wst, 0) as on_time_hours_wst,

        /* Overage Hours */
        greatest(coalesce(b.on_time_hours_cst, 0) - 8, 0) as overage_hours_cst,
        greatest(coalesce(b.on_time_hours_est, 0) - 8, 0) as overage_hours_est,
        greatest(coalesce(b.on_time_hours_mnt, 0) - 8, 0) as overage_hours_mnt,
        greatest(coalesce(b.on_time_hours_utc, 0) - 8, 0) as overage_hours_utc,
        greatest(coalesce(b.on_time_hours_wst, 0) - 8, 0) as overage_hours_wst,

        /* Overage Fees */
        greatest(coalesce(b.on_time_hours_cst, 0) - 8, 0) * o.overage_hourly_rate as overage_fee_cst,
        greatest(coalesce(b.on_time_hours_est, 0) - 8, 0) * o.overage_hourly_rate as overage_fee_est,
        greatest(coalesce(b.on_time_hours_mnt, 0) - 8, 0) * o.overage_hourly_rate as overage_fee_mnt,
        greatest(coalesce(b.on_time_hours_utc, 0) - 8, 0) * o.overage_hourly_rate as overage_fee_utc,
        greatest(coalesce(b.on_time_hours_wst, 0) - 8, 0) * o.overage_hourly_rate as overage_fee_wst,

        /* Total daily charges (base + overage) */
        o.price_per_day
          + (greatest(coalesce(b.on_time_hours_cst, 0) - 8, 0) * o.overage_hourly_rate) as total_daily_charge_cst,
        o.price_per_day
          + (greatest(coalesce(b.on_time_hours_est, 0) - 8, 0) * o.overage_hourly_rate) as total_daily_charge_est,
        o.price_per_day
          + (greatest(coalesce(b.on_time_hours_mnt, 0) - 8, 0) * o.overage_hourly_rate) as total_daily_charge_mnt,
        o.price_per_day
          + (greatest(coalesce(b.on_time_hours_utc, 0) - 8, 0) * o.overage_hourly_rate) as total_daily_charge_utc,
        o.price_per_day
          + (greatest(coalesce(b.on_time_hours_wst, 0) - 8, 0) * o.overage_hourly_rate) as total_daily_charge_wst,

        /* Lost opportunity hours (unused prepaid 8 hours) */
        greatest(8 - coalesce(b.on_time_hours_cst, 0), 0) as lost_opp_hours_cst,
        greatest(8 - coalesce(b.on_time_hours_est, 0), 0) as lost_opp_hours_est,
        greatest(8 - coalesce(b.on_time_hours_mnt, 0), 0) as lost_opp_hours_mnt,
        greatest(8 - coalesce(b.on_time_hours_utc, 0), 0) as lost_opp_hours_utc,
        greatest(8 - coalesce(b.on_time_hours_wst, 0), 0) as lost_opp_hours_wst,

        /* Lost opportunity cost ($) */
        greatest(8 - coalesce(b.on_time_hours_cst, 0), 0) * o.price_per_hour as lost_opp_cost_cst,
        greatest(8 - coalesce(b.on_time_hours_est, 0), 0) * o.price_per_hour as lost_opp_cost_est,
        greatest(8 - coalesce(b.on_time_hours_mnt, 0), 0) * o.price_per_hour as lost_opp_cost_mnt,
        greatest(8 - coalesce(b.on_time_hours_utc, 0), 0) * o.price_per_hour as lost_opp_cost_utc,
        greatest(8 - coalesce(b.on_time_hours_wst, 0), 0) * o.price_per_hour as lost_opp_cost_wst

    from on_rent o
    left join by_day b
      on b.asset_id = o.asset_id
     and b.date >= o.rental_start_date
     and b.date < current_date
),


asset_totals as (
    select
        asset_id,
        asset_class,
        make_and_model,
        company_id,
        rental_start_date,
        price_per_hour,

        -- Total overage hours
        sum(overage_hours_cst) as total_overage_hours_cst,
        sum(overage_hours_est) as total_overage_hours_est,
        sum(overage_hours_mnt) as total_overage_hours_mnt,
        sum(overage_hours_utc) as total_overage_hours_utc,
        sum(overage_hours_wst) as total_overage_hours_wst,

        -- Total overage fees
        sum(overage_fee_cst) as total_overage_fee_cst,
        sum(overage_fee_est) as total_overage_fee_est,
        sum(overage_fee_mnt) as total_overage_fee_mnt,
        sum(overage_fee_utc) as total_overage_fee_utc,
        sum(overage_fee_wst) as total_overage_fee_wst,

        -- Total charges (base + overage)
        sum(total_daily_charge_cst) as total_charge_cst,
        sum(total_daily_charge_est) as total_charge_est,
        sum(total_daily_charge_mnt) as total_charge_mnt,
        sum(total_daily_charge_utc) as total_charge_utc,
        sum(total_daily_charge_wst) as total_charge_wst,

        -- Total lost opportunity hours
        sum(lost_opp_hours_cst) as total_lost_opp_hours_cst,
        sum(lost_opp_hours_est) as total_lost_opp_hours_est,
        sum(lost_opp_hours_mnt) as total_lost_opp_hours_mnt,
        sum(lost_opp_hours_utc) as total_lost_opp_hours_utc,
        sum(lost_opp_hours_wst) as total_lost_opp_hours_wst,

        -- Total lost opportunity cost ($)
        sum(lost_opp_cost_cst) as total_lost_opp_cost_cst,
        sum(lost_opp_cost_est) as total_lost_opp_cost_est,
        sum(lost_opp_cost_mnt) as total_lost_opp_cost_mnt,
        sum(lost_opp_cost_utc) as total_lost_opp_cost_utc,
        sum(lost_opp_cost_wst) as total_lost_opp_cost_wst

    from rental_day
    group by all
)

select *
from asset_totals
where company_id = 109154

          ;;
  }


  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }
  dimension: total_overage_hours_cst { type: number sql: ${TABLE}.TOTAL_OVERAGE_HOURS_CST ;; }
  dimension: total_overage_fee_cst { type: number sql: ${TABLE}.TOTAL_OVERAGE_FEE_CST ;; }
  dimension: total_lost_opp_cost_cst { type: number sql: ${TABLE}.TOTAL_LOST_OPP_COST_CST ;; }
  dimension: total_charge_cst { type: number sql: ${TABLE}.TOTAL_CHARGE_CST ;; }


  measure: total_rental_overage_hours_cst {
    type: sum
    sql: ${total_overage_hours_cst} ;;
    value_format_name: decimal_0
  }

  measure: total_rental_overage_fees_cst {
    type: sum
    sql: ${total_overage_fee_cst} ;;
    value_format_name: usd_0
  }

  measure: total_rental_lost_opp_cost_cst {
    type: sum
    sql: ${total_lost_opp_cost_cst} ;;
    value_format_name: usd_0
  }

  measure: total_rental_charges_cst {
    type: sum
    sql: ${total_charge_cst} ;;
    value_format_name: usd_0
  }




}
