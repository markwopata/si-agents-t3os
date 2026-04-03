view: rented_substitutions {
  derived_table: {
    sql:
      select r.RENTAL_ID,
             li.LINE_ITEM_ID,
            r.EQUIPMENT_CLASS_ID                                                                       as requested_class,
       li.BRANCH_ID,
       dmfo.MARKET_NAME                                                                                as branch_name,
       dmfo.MARKET_DISTRICT                                                                            as district,
       dmfo.MARKET_REGION_NAME                                                                         as region_name,
       aa.EQUIPMENT_CLASS_ID                                                                           as rented_class,
       li.EXTENDED_DATA,
       datediff('day', i.START_DATE, i.END_DATE)                                                       as cycle_length,
       li.EXTENDED_DATA:rental:cheapest_period_hour_count                                              as hours,
       li.EXTENDED_DATA:rental:cheapest_period_day_count                                               as days,
       li.EXTENDED_DATA:rental:cheapest_period_week_count                                              as weeks,
       li.EXTENDED_DATA:rental:cheapest_period_four_week_count                                         as four_weeks,
       li.EXTENDED_DATA:rental:cheapest_period_month_count                                             as months,
       li.amount                                                                                       as actual_revenue,
       i.billing_approved_date                                                                         as billing_approved_date,
       case
           when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
           when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
           else null end                                                                               as BILLING_TYPE,
       case
           when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and r.PRICE_PER_DAY is not null then true
           else false end                                                                              as DAILY_BILLING_FLAG,
       case
           when daily_billing_flag = true then (brr1.PRICE_PER_MONTH / 28) * cycle_length
           when BILLING_TYPE = 'four_week' then hours * brr1.PRICE_PER_HOUR + days * brr1.PRICE_PER_DAY +
                                                weeks * brr1.PRICE_PER_WEEK + four_weeks * brr1.PRICE_PER_MONTH
           when BILLING_TYPE = 'monthly' then iff(cycle_length > 28, (brr1.PRICE_PER_MONTH / 28) * cycle_length,
                                                  hours * brr1.PRICE_PER_HOUR + days * brr1.PRICE_PER_DAY +
                                                  weeks * brr1.PRICE_PER_WEEK + months *
                                                                                brr1.PRICE_PER_MONTH) end as   benchmark_requested,
      case
          when daily_billing_flag = true then (brr2.PRICE_PER_MONTH / 28) * cycle_length
          when BILLING_TYPE = 'four_week' then hours * brr2.PRICE_PER_HOUR + days * brr2.PRICE_PER_DAY +
                                               weeks * brr2.PRICE_PER_WEEK + four_weeks * brr2.PRICE_PER_MONTH
          when BILLING_TYPE = 'monthly' then iff(cycle_length > 28, (brr2.PRICE_PER_MONTH / 28) * cycle_length,
                                                  hours * brr2.PRICE_PER_HOUR + days * brr2.PRICE_PER_DAY +
                                                  weeks * brr2.PRICE_PER_WEEK + months * brr2.PRICE_PER_MONTH) end as benchmark_rented,
      benchmark_rented - benchmark_requested as benchmark_rented_vs_requested,
      actual_revenue - benchmark_requested as actual_vs_requested,
      actual_revenue - benchmark_rented as actual_vs_rented
from ES_WAREHOUSE.PUBLIC.RENTALS r
         join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li on r.RENTAL_ID = li.RENTAL_ID
         join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on li.ASSET_ID = aa.ASSET_ID
         join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
         left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dmfo on dmfo.market_id = li.branch_id
    -- join to rates for requested class
         left join ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr1
                   on brr1.BRANCH_ID = li.BRANCH_ID and brr1.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID and
                      brr1.RATE_TYPE_ID = 2 and brr1.DATE_CREATED <= i.BILLING_APPROVED_DATE and
                      i.BILLING_APPROVED_DATE < coalesce(brr1.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
    -- join to rates for rented class
         left join ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES brr2
                   on brr2.BRANCH_ID = li.BRANCH_ID and brr2.EQUIPMENT_CLASS_ID = aa.EQUIPMENT_CLASS_ID and
                      brr2.RATE_TYPE_ID = 2 and brr2.DATE_CREATED <= i.BILLING_APPROVED_DATE and
                      i.BILLING_APPROVED_DATE < coalesce(brr2.DATE_VOIDED, '2099-12-31 23:59:59.999'::timestamp_ntz)
where li.LINE_ITEM_TYPE_ID = 8
  and requested_class <> rented_class
  and actual_revenue > 0
  and benchmark_rented > 0
  and benchmark_requested > 0
  and branch_name not ilike '%ARCHIVE%';;
  }

  # Primary keys
  dimension: rental_id { primary_key: yes type: number sql: ${TABLE}.RENTAL_ID ;; }
  dimension: line_item_id { type: number sql: ${TABLE}.LINE_ITEM_ID ;; }

  # Core attributes
  dimension: requested_class { type: number sql: ${TABLE}.REQUESTED_CLASS ;; }
  dimension: rented_class    { type: number sql: ${TABLE}.RENTED_CLASS ;; }

  dimension: branch_id    { type: number sql: ${TABLE}.BRANCH_ID ;; }
  dimension: branch_name  { type: string sql: ${TABLE}.BRANCH_NAME ;; }
  dimension: district     { type: string sql: ${TABLE}.DISTRICT ;; }
  dimension: region_name  { type: string sql: ${TABLE}.REGION_NAME ;; }

  dimension: billing_approved_date { type: date sql: ${TABLE}.BILLING_APPROVED_DATE ;; }
  dimension: billing_type          { type: string sql: ${TABLE}.BILLING_TYPE ;; }

  # Revenue dimensions
  dimension: actual_revenue {
    type: number
    sql: ${TABLE}."ACTUAL_REVENUE" ;;
    value_format_name: usd
  }

  dimension: benchmark_requested {
    type: number
    sql: ${TABLE}."BENCHMARK_REQUESTED" ;;
    value_format_name: usd
  }

  dimension: benchmark_rented {
    type: number
    sql: ${TABLE}."BENCHMARK_RENTED" ;;
    value_format_name: usd
  }

  # Benchmark & actual metrics (totals and ratios)
  dimension: ratio_actual_vs_requested {
    type: number
    sql: ( ${TABLE}.ACTUAL_REVENUE / NULLIF(${TABLE}.BENCHMARK_REQUESTED, 0) ) - 1 ;;
    value_format_name: percent_1
  }

  dimension: ratio_actual_vs_rented {
    type: number
    sql: ( ${TABLE}.ACTUAL_REVENUE / NULLIF(${TABLE}.BENCHMARK_RENTED, 0) ) - 1 ;;
    value_format_name: percent_1
  }

  dimension: ratio_rented_vs_requested {
    type: number
    sql: ( ${TABLE}.BENCHMARK_RENTED / NULLIF(${TABLE}.BENCHMARK_REQUESTED, 0) ) - 1 ;;
    value_format_name: percent_1
  }

  measure: total_actual_revenue {
    type: sum
    sql: ${actual_revenue} ;;
    value_format_name: usd
  }

  measure: total_benchmark_requested {
    type: sum
    sql: ${benchmark_requested} ;;
    value_format_name: usd
  }

  measure: total_benchmark_rented {
    type: sum
    sql: ${benchmark_rented} ;;
    value_format_name: usd
  }

  measure: actual_margin {
    type: sum
    sql: ${actual_revenue} - ${benchmark_rented} ;;
  }

  measure: count {
    type: count
  }


}
