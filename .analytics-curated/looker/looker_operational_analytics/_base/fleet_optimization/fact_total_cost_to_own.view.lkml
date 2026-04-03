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
  dimension: service_outside_labor_cost {
    type: number
    sql: ${TABLE}."SERVICE_OUTSIDE_LABOR_COST" ;;
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
