view: tam_performance_previous_month {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."TAM_PERFORMANCE_PREVIOUS_MONTH" ;;

  dimension: commission_start {
    type: date_raw
    sql: ${TABLE}."COMMISSION_START_DATE" ;;
  }
  dimension: date_hired {
    type: date_raw
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension: date_terminated {
    type: date_raw
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }
  dimension: direct_manager_employee_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: guarantee_end {
    type: date_raw
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }
  dimension: guarantee_months {
    type: number
    sql: ${TABLE}."GUARANTEE_MONTHS" ;;
  }
  dimension: guarantee_start {
    type: date_raw
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }
  dimension: primary_bulk_revenue {
    type: number
    sql: ${TABLE}."PRIMARY_BULK_REVENUE" ;;
  }
  dimension: primary_delivery_revenue {
    type: number
    sql: ${TABLE}."PRIMARY_DELIVERY_REVENUE" ;;
  }
  dimension: primary_in_market_rental_pct {
    type: number
    sql: ${TABLE}."PRIMARY_IN_MARKET_RENTAL_PCT" ;;
  }
  dimension: primary_in_market_total_pct {
    type: number
    sql: ${TABLE}."PRIMARY_IN_MARKET_TOTAL_PCT" ;;
  }
  dimension: primary_parts_revenue {
    type: number
    sql: ${TABLE}."PRIMARY_PARTS_REVENUE" ;;
  }
  dimension: primary_rental_revenue {
    type: number
    sql: ${TABLE}."PRIMARY_RENTAL_REVENUE" ;;
  }
  dimension: primary_total_revenue {
    type: number
    sql: ${TABLE}."PRIMARY_TOTAL_REVENUE" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: secondary_bulk_revenue {
    type: number
    sql: ${TABLE}."SECONDARY_BULK_REVENUE" ;;
  }
  dimension: secondary_delivery_revenue {
    type: number
    sql: ${TABLE}."SECONDARY_DELIVERY_REVENUE" ;;
  }
  dimension: secondary_in_market_rental_pct {
    type: number
    sql: ${TABLE}."SECONDARY_IN_MARKET_RENTAL_PCT" ;;
  }
  dimension: secondary_in_market_total_pct {
    type: number
    sql: ${TABLE}."SECONDARY_IN_MARKET_TOTAL_PCT" ;;
  }
  dimension: secondary_parts_revenue {
    type: number
    sql: ${TABLE}."SECONDARY_PARTS_REVENUE" ;;
  }
  dimension: secondary_rental_revenue {
    type: number
    sql: ${TABLE}."SECONDARY_RENTAL_REVENUE" ;;
  }
  dimension: secondary_total_revenue {
    type: number
    sql: ${TABLE}."SECONDARY_TOTAL_REVENUE" ;;
  }
  dimension: tenure_in_months {
    type: number
    sql: ${TABLE}."TENURE_IN_MONTHS" ;;
  }
  dimension: total_bulk_revenue {
    type: number
    sql: ${TABLE}."TOTAL_BULK_REVENUE" ;;
  }
  dimension: total_delivery_revenue {
    type: number
    sql: ${TABLE}."TOTAL_DELIVERY_REVENUE" ;;
  }
  dimension: total_in_market_rental_pct {
    type: number
    sql: ${TABLE}."TOTAL_IN_MARKET_RENTAL_PCT" ;;
  }
  dimension: total_in_market_total_pct {
    type: number
    sql: ${TABLE}."TOTAL_IN_MARKET_TOTAL_PCT" ;;
  }
  dimension: total_parts_revenue {
    type: number
    sql: ${TABLE}."TOTAL_PARTS_REVENUE" ;;
  }
  dimension: total_rental_revenue {
    type: number
    sql: ${TABLE}."TOTAL_RENTAL_REVENUE" ;;
  }
  dimension: total_total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_TOTAL_REVENUE" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [name, market_name, direct_manager_name]
  }
}
