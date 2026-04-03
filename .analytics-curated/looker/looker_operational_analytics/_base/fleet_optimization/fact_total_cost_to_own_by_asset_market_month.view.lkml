view: fact_total_cost_to_own_by_asset_market_month {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."FACT_TOTAL_COST_TO_OWN_BY_ASSET_MARKET_MONTH" ;;

  dimension: age_in_months_from_first_rental {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_FIRST_RENTAL" ;;
  }
  dimension: age_in_months_from_purchase {
    type: number
    sql: ${TABLE}."AGE_IN_MONTHS_FROM_PURCHASE" ;;
  }
  dimension: alloc_weight_for_asset_month_measures {
    type: number
    sql: ${TABLE}."ALLOC_WEIGHT_FOR_ASSET_MONTH_MEASURES" ;;
  }
  dimension: asset_hours_consumed {
    type: number
    sql: ${TABLE}."ASSET_HOURS_CONSUMED" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_market_month_key {
    type: string
    sql: ${TABLE}."ASSET_MARKET_MONTH_KEY" ;;
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
  dimension_group: date_month_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MONTH_START" ;;
  }
  dimension: days_in_fleet_multiplier {
    type: number
    sql: ${TABLE}."DAYS_IN_FLEET_MULTIPLIER" ;;
  }
  dimension: days_in_market_in_month {
    type: number
    sql: ${TABLE}."DAYS_IN_MARKET_IN_MONTH" ;;
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  dimension: estimated_lost_revenue_in_month {
    type: number
    sql: ${TABLE}."ESTIMATED_LOST_REVENUE_IN_MONTH" ;;
  }
  dimension: is_market_as_of_month_end {
    type: number
    sql: ${TABLE}."IS_MARKET_AS_OF_MONTH_END" ;;
  }
  dimension: labor_cost {
    type: number
    sql: ${TABLE}."LABOR_COST" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
  }
  dimension: monthly_cost_to_own {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN" ;;
  }
  dimension: monthly_cost_to_own_adjusted {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN_ADJUSTED" ;;
  }
  dimension: monthly_cost_to_own_incl_outside_labor {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN_INCL_OUTSIDE_LABOR" ;;
  }
  dimension: monthly_cost_to_own_incl_outside_labor_adjusted {
    type: number
    sql: ${TABLE}."MONTHLY_COST_TO_OWN_INCL_OUTSIDE_LABOR_ADJUSTED" ;;
  }
  dimension: net_monthly_profit {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT" ;;
  }
  dimension: net_monthly_profit_adjusted {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT_ADJUSTED" ;;
  }
  dimension: net_monthly_profit_incl_outside_labor {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT_INCL_OUTSIDE_LABOR" ;;
  }
  dimension: net_monthly_profit_incl_outside_labor_adjusted {
    type: number
    sql: ${TABLE}."NET_MONTHLY_PROFIT_INCL_OUTSIDE_LABOR_ADJUSTED" ;;
  }
  dimension: parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
  }
  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: service_outside_labor_cost {
    type: number
    sql: ${TABLE}."SERVICE_OUTSIDE_LABOR_COST" ;;
  }
  dimension: share_of_month {
    type: number
    sql: ${TABLE}."SHARE_OF_MONTH" ;;
  }
  dimension: share_of_month_calendar {
    type: number
    sql: ${TABLE}."SHARE_OF_MONTH_CALENDAR" ;;
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
