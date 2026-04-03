view: vehicle_tracking_employee_detail {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."VEHICLE_TRACKING_EMPLOYEE_DETAIL" ;;

  dimension: asset_annual_lease_value {
    type: number
    sql: ${TABLE}."ASSET_ANNUAL_LEASE_VALUE" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: business_mileage {
    type: number
    sql: ${TABLE}."BUSINESS_MILEAGE" ;;
  }
  dimension: calendar_day_proration {
    type: number
    sql: ${TABLE}."CALENDAR_DAY_PRORATION" ;;
  }
  dimension: current_period_personal_use_fuel {
    type: number
    sql: ${TABLE}."CURRENT_PERIOD_PERSONAL_USE_FUEL" ;;
  }
  dimension: current_period_personal_use_lease_value {
    type: number
    sql: ${TABLE}."CURRENT_PERIOD_PERSONAL_USE_LEASE_VALUE" ;;
  }
  dimension: current_period_taxable_fringe {
    type: number
    sql: ${TABLE}."CURRENT_PERIOD_TAXABLE_FRINGE" ;;
  }
  dimension: days_with_vehicle {
    type: number
    sql: ${TABLE}."DAYS_WITH_VEHICLE" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: end {
    type: date_raw
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: personal_mileage {
    type: number
    sql: ${TABLE}."PERSONAL_MILEAGE" ;;
  }
  dimension: personal_use_percentage {
    type: number
    sql: ${TABLE}."PERSONAL_USE_PERCENTAGE" ;;
  }
  dimension: purchase {
    type: date_raw
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }
  dimension: start {
    type: date_raw
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: total_mileage {
    type: number
    sql: ${TABLE}."TOTAL_MILEAGE" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: vehicle_cost {
    type: number
    sql: ${TABLE}."VEHICLE_COST" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: years_day {
    type: number
    sql: ${TABLE}."YEARS_DAY" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
