view: v_payout_programs {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."V_PAYOUT_PROGRAMS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: payout_program_assignment_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ASSIGNMENT_ID" ;;
  }
  dimension: payout_program_billing_type {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_BILLING_TYPE" ;;
  }
  dimension: payout_program_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }
  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }
  dimension: payout_program_schedule_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_SCHEDULE_ID" ;;
  }
  dimension: payout_program_type_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
  }
  dimension: replaced_by_asset_id {
    type: number
    sql: ${TABLE}."REPLACED_BY_ASSET_ID" ;;
  }
  dimension: replaced_or_removed_reason {
    type: string
    sql: ${TABLE}."REPLACED_OR_REMOVED_REASON" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: updated_by_user_id {
    type: number
    sql: ${TABLE}."UPDATED_BY_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [payout_program_name]
  }
}
