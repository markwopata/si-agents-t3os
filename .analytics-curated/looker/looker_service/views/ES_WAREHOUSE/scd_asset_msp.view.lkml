view: scd_asset_msp {
  sql_table_name: "ES_WAREHOUSE"."SCD"."SCD_ASSET_MSP" ;;
  drill_fields: [scd_asset_msp_id]

  dimension: scd_asset_msp_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SCD_ASSET_MSP_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: current_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [scd_asset_msp_id]
  }
}
