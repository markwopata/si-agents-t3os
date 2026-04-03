view: stg_t3__operator_assignments {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__OPERATOR_ASSIGNMENTS" ;;

  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_company_key {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: assignment_count {
    type: number
    sql: ${TABLE}."ASSIGNMENT_COUNT" ;;
  }
  dimension_group: assignment_time {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ASSIGNMENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: assumed_event {
    type: string
    sql: ${TABLE}."ASSUMED_EVENT" ;;
  }
  dimension: current_assignment {
    type: yesno
    sql: ${TABLE}."CURRENT_ASSIGNMENT" ;;
  }
  dimension: operator_assignment_key {
    type: string
    sql: ${TABLE}."OPERATOR_ASSIGNMENT_KEY" ;;
  }
  dimension: operator_assignment_source {
    type: string
    sql: ${TABLE}."OPERATOR_ASSIGNMENT_SOURCE" ;;
  }
  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }
  dimension: operator_name {
    label: "Driver"
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }
  dimension_group: unassignment {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UNASSIGNMENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: user_key {
    type: string
    sql: ${TABLE}."USER_KEY" ;;
  }
  measure: count {
    type: count
    drill_fields: [operator_name]
  }
}
