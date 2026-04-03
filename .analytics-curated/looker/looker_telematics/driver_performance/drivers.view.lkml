view: drivers {
  sql_table_name: "FLEETCAM"."DRIVERS" ;;

  dimension: date_hired {
    type: string
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: operator_email {
    label: "Email Address"
    type: string
    sql: ${TABLE}."OPERATOR_EMAIL" ;;
  }
  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }
  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, direct_manager_name, operator_name]
  }
}
