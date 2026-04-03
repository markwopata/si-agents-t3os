view: fact_total_cost_to_own {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."FACT_TOTAL_COST_TO_OWN" ;;

  dimension: age_in_months_from_first_rental {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_FIRST_RENTAL" ;;
  }
  dimension: age_in_months_from_purchase {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_PURCHASE" ;;
  }
  dimension: asset_hours_consumed {
    type: number
    sql: ${TABLE}."ASSET_HOURS_CONSUMED" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_month_key {
    type: string
    sql: ${TABLE}."ASSET_MONTH_KEY" ;;
  }
  dimension: asset_oec {
    type: number
    sql: ${TABLE}."ASSET_OEC" ;;
  }
  dimension: class_revenue_per_rental_day {
    type: number
    sql: ${TABLE}."CLASS_REVENUE_PER_RENTAL_DAY" ;;
  }
  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  dimension: damage_revenue {
    type: number
    sql: ${TABLE}."DAMAGE_REVENUE" ;;
  }
  dimension: days_in_fleet_multiplier {
    type: number
    sql: ${TABLE}."DAYS_IN_FLEET_MULTIPLIER" ;;
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  dimension: estimated_lost_revenue_in_month {
    type: number
    sql: ${TABLE}."ESTIMATED_LOST_REVENUE_IN_MONTH" ;;
  }
  dimension: labor_cost {
    type: number
    sql: ${TABLE}."LABOR_COST" ;;
  }
  dimension: monthly_cost_to_own {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN" ;;
  }
  dimension: monthly_cost_to_own_adjusted {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN_ADJUSTED" ;;
  }
  dimension: net_monthly_profit {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT" ;;
  }
  dimension: net_monthly_profit_adjusted {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT_ADJUSTED" ;;
  }
  dimension: parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
  }
  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: tf_key {
    type: string
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: total_hard_down_days {
    type: number
    sql: ${TABLE}."TOTAL_HARD_DOWN_DAYS" ;;
  }
  dimension: total_labor_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_LABOR_WORK_ORDERS" ;;
  }
  dimension: total_parts_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_PARTS_WORK_ORDERS" ;;
  }
  dimension: total_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_WORK_ORDERS" ;;
  }
  dimension: warranty_revenue {
    type: number
    sql: ${TABLE}."WARRANTY_REVENUE" ;;
  }
  dimension: work_order_labor_hours {
    type: number
    sql: ${TABLE}."WORK_ORDER_LABOR_HOURS" ;;
  }
  measure: count {
    type: count
  }
}

view: vendor_total_cost_to_own {
  derived_table: {
    sql:
select tf.start_date
    , v.vendorid
    , cto.*
    , a.asset_equipment_model_name
from FLEET_OPTIMIZATION.GOLD.FACT_TOTAL_COST_TO_OWN cto
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
    on a.asset_key = cto.asset_key
join (
        select vendorid
            , vendor_name
            , mapped_vendor_name
            , vendor_type
            , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
            , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
        from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
        where primary_vendor ilike 'yes' and mapped_vendor_name is not null
        ) v
    on upper(join1) = a.asset_equipment_make or upper(join2) = a.asset_equipment_make
join FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC tf
    on tf.tf_key = cto.tf_key;;
  }
  dimension_group: reference {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.start_date ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: age_in_months_from_first_rental {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_FIRST_RENTAL" ;;
  }
  dimension: age_in_months_from_purchase {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_PURCHASE" ;;
  }
  dimension: asset_hours_consumed {
    type: number
    sql: ${TABLE}."ASSET_HOURS_CONSUMED" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_month_key {
    type: string
    sql: ${TABLE}."ASSET_MONTH_KEY" ;;
  }
  dimension: asset_oec {
    type: number
    sql: ${TABLE}."ASSET_OEC" ;;
  }
  measure: total_oec {
    type: sum
    value_format_name: usd
    sql: ${asset_oec} ;;
  }
  dimension: class_revenue_per_rental_day {
    type: number
    sql: ${TABLE}."CLASS_REVENUE_PER_RENTAL_DAY" ;;
  }
  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  dimension: damage_revenue {
    type: number
    sql: ${TABLE}."DAMAGE_REVENUE" ;;
  }
  measure: total_damage_revenue {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${damage_revenue} ;;
  }
  measure: damage_revenue_month_oec {
    type: number
    value_format_name: percent_2
    sql: ${total_damage_revenue} / nullifzero((${total_oec} / 12)) ;;
  }
  dimension: days_in_fleet_multiplier {
    type: number
    sql: ${TABLE}."DAYS_IN_FLEET_MULTIPLIER" ;;
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  dimension: estimated_lost_revenue_in_month {
    type: number
    sql: ${TABLE}."ESTIMATED_LOST_REVENUE_IN_MONTH" ;;
  }
  dimension: labor_cost {
    type: number
    sql: ${TABLE}."LABOR_COST" ;;
  }
  measure: total_labor_cost {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${labor_cost} ;;
  }
  measure: labor_cost_over_month_oec {
    type: number
    value_format_name: percent_2
    sql: ${total_labor_cost} / (nullifzero(${total_oec} / 12)) ;;
  }
  measure: labor_cost_oec_ytd {
    type: number
    value_format_name: percent_2
    sql: ${total_labor_cost} / (nullifzero(${total_oec} / iff(month(current_date) <> 1, (month(current_date) - 1), month(current_date)))) ;;
  }
  dimension: asset_model {
    type: string
    sql: ${TABLE}.asset_equipment_model_name ;;
  }
  measure: negative_total_labor_cost {
    type: sum
    value_format: "[<=-1000000000]$0.00,,,\"B\";[<=-1000000]$0.00,,\"M\";[<=-1000]$0.00,\"K\";$0"
    sql: -${labor_cost} ;;
    drill_fields: [
      asset_model
      , total_labor_cost
      , total_parts_cost]
  }
  dimension: monthly_cost_to_own {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN" ;;
  }
  measure: total_cost_to_own {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${monthly_cost_to_own} ;;
  }
  measure: cost_to_own_oec {
    type: number
    value_format_name: percent_2
    sql: ${total_cost_to_own} / nullifzero(${total_oec} / iff(month(current_date) <> 1, (month(current_date) - 1), month(current_date))) ;;
  }
  dimension: monthly_cost_to_own_adjusted {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN_ADJUSTED" ;;
  }
  dimension: net_monthly_profit {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT" ;;
  }
  dimension: net_monthly_profit_adjusted {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT_ADJUSTED" ;;
  }
  dimension: parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
  }
  measure: total_parts_cost {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${parts_cost} ;;
  }
  measure: negative_total_parts_cost {
    type: sum
    value_format: "[<=-1000000000]$0.00,,,\"B\";[<=-1000000]$0.00,,\"M\";[<=-1000]$0.00,\"K\";$0"
    sql: -${parts_cost} ;;
    drill_fields: [
      asset_model
      , total_labor_cost
      , total_parts_cost]
  }
  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: tf_key {
    type: string
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: total_hard_down_days {
    type: number
    sql: ${TABLE}."TOTAL_HARD_DOWN_DAYS" ;;
  }
  dimension: total_labor_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_LABOR_WORK_ORDERS" ;;
  }
  dimension: total_parts_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_PARTS_WORK_ORDERS" ;;
  }
  dimension: total_work_orders {
    type: number
    sql: ${TABLE}."TOTAL_WORK_ORDERS" ;;
  }
  dimension: warranty_revenue {
    type: number
    sql: ${TABLE}."WARRANTY_REVENUE" ;;
  }
  measure: total_warranty_revenue {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${warranty_revenue} ;;
  }
  measure: warranty_revenue_month_oec {
    type: number
    value_format_name: percent_2
    sql: ${total_warranty_revenue} / (nullifzero(${total_oec} / 12)) ;;
  }
  measure: maintenance_rev_oec_ytd {
    type:number
    value_format_name: percent_2
    sql: (${total_warranty_revenue} + ${total_damage_revenue}) / (nullifzero(${total_oec} / (month(current_date) - 1))) ;;
  }
  dimension: work_order_labor_hours {
    type: number
    sql: ${TABLE}."WORK_ORDER_LABOR_HOURS" ;;
  }
  measure: count {
    type: count
  }
  dimension: service_outside_labor_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.service_outside_labor_cost ;;
  }
  measure: total_service_outside_labor_cost {
    type: sum
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    sql: ${service_outside_labor_cost} ;;
    drill_fields: [
      asset_model
      , total_labor_cost
      , total_parts_cost]
  }
  measure: negative_total_service_outside_labor_cost {
    type: sum
    value_format: "[<=-1000000000]$0.00,,,\"B\";[<=-1000000]$0.00,,\"M\";[<=-1000]$0.00,\"K\";$0"
    sql: -${service_outside_labor_cost} ;;
    drill_fields: [
      asset_model
      , total_labor_cost
      , total_parts_cost]
  }
}

view: vendor_cost_to_own_score {
  derived_table: {
    sql:
with vendor_oec as (
    select v.vendorid
        , v.vendor_type
        , v.mapped_vendor_name
        , sum(zeroifnull(rental_fleet_oec)) / count(distinct daily_timestamp::DATE) as avg_oec
    from ANALYTICS.ASSETS.INT_ASSET_HISTORICAL a
    join (
            select vendorid
                , vendor_name
                , mapped_vendor_name
                , vendor_type
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes' and mapped_vendor_name is not null
            ) v
        on upper(join1) = a.make or upper(join2) = a.make
    where a.daily_timestamp::DATE >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1,2,3
    having avg_oec > 0
)

, agg as (
    select v.vendorid
        , vo.mapped_vendor_name
        , vo.vendor_type
        , vo.avg_oec
        , sum(zeroifnull(v.monthly_cost_to_own)) as cost_to_own
        , sum(zeroifnull(v.labor_cost)) as labor_cost
    from ${vendor_total_cost_to_own.SQL_TABLE_NAME} v
    join vendor_oec vo
        on vo.vendorid = v.vendorid
    join FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC tf
        on tf.tf_key = v.tf_key
            and tf.start_date >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1,2,3,4
)


select a.vendorid
    , a.mapped_vendor_name
    , a.labor_cost / nullifzero(a.avg_oec) as vendor_labor_cost_oec
    , sum(pa.labor_cost) / sum(pa.avg_oec) as peers_labor_cost_oec
    , least(coalesce(peers_labor_cost_oec, 1), 0.01) as labor_cost_oec_target
    , iff((labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * (1/14) > (1/14), (1/14), (labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * (1/14)) as labor_cost_oec_score
    , iff((labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 10 > 10, 10, (labor_cost_oec_target / nullifzero(vendor_labor_cost_oec)) * 10) as labor_cost_oec_score10

    , a.cost_to_own / nullifzero(a.avg_oec) as vendor_cost_to_own_oec
    , sum(pa.cost_to_own) / sum(pa.avg_oec) as peers_cost_to_own_oec
    , least(coalesce(peers_cost_to_own_oec, 1), 0.02) as cost_to_own_oec_target
    , iff((cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * (1/14) > (1/14), (1/14), (cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * (1/14)) as cost_to_own_oec_score
    , iff((cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 10 > 10, 10, (cost_to_own_oec_target / nullifzero(vendor_cost_to_own_oec)) * 10) as cost_to_own_oec_score10
from agg a
left join agg pa
    on pa.vendorid <> a.vendorid
        and pa.vendor_type = a.vendor_type
group by 1, 2, 3, vendor_cost_to_own_oec;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_labor_cost_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_labor_cost_oec ;;
  }
  dimension: peers_labor_cost_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_labor_cost_oec ;;
  }
  dimension: labor_cost_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.labor_cost_oec_target ;;
  }
  dimension: labor_cost_oec_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.labor_cost_oec_score, 0) ;;
  }
  dimension: labor_cost_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.labor_cost_oec_score10, 0) ;;
  }

  dimension: vendor_cost_to_own_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_cost_to_own_oec ;;
  }
  dimension: peers_cost_to_own_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_cost_to_own_oec ;;
  }
  dimension: cost_to_own_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.cost_to_own_oec_target ;;
  }
  dimension: cost_to_own_oec_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.cost_to_own_oec_score, 0) ;;
  }
  dimension: cost_to_own_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.cost_to_own_oec_score10, 0) ;;
  }
}
