view: tracking_diagnostic_codes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."TRACKING_DIAGNOSTIC_CODES" ;;

  dimension: tracking_diagnostic_codes_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRACKING_DIAGNOSTIC_CODES_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/diagnostic-codes" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension_group: cleared {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CLEARED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
  }
  dimension: failure_mode_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."FAILURE_MODE_IDENTIFIER" ;;
  }
  dimension_group: last_seen {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_SEEN" AS TIMESTAMP_NTZ) ;;
  }
  dimension: level {
    type: number
    sql: ${TABLE}."LEVEL" ;;
  }
  dimension: module_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."MODULE_IDENTIFIER" ;;
  }
  dimension: occurrences {
    type: number
    sql: ${TABLE}."OCCURRENCES" ;;
  }
  dimension_group: report_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: suspect_parameter_number {
    type: number
    sql: ${TABLE}."SUSPECT_PARAMETER_NUMBER" ;;
  }
  dimension: tracking_event_id {
    type: number
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
  }
  dimension: tracking_obd_dtc_code_id {
    type: number
    sql: ${TABLE}."TRACKING_OBD_DTC_CODE_ID" ;;
  }
  dimension_group: vendor_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."VENDOR_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  measure: count_assets_with_open_codes {
    type: count_distinct
    sql: ${asset_id};;
    drill_fields: [asset_id,assets.asset_type_id,assets.make,assets.model,markets.name,code,tracking_obd_dtc_codes.description,report_timestamp_date,last_seen_date]
  }

  measure: count_open_codes {
    type: count_distinct
    filters: [cleared_date: "NULL"]
    sql: ${tracking_diagnostic_codes_id};;
  }

  measure: open_dtc {
    type: yesno
    sql: ${count_open_codes} > 0 ;;
  }
}
