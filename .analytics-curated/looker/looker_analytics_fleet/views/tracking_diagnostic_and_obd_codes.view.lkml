view: tracking_diagnostic_and_obd_codes {
  sql_table_name: "PUBLIC"."TRACKING_DIAGNOSTIC_AND_OBD_CODES"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension_group: cleared {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."CLEARED" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    hidden: yes
  }

  dimension: failure_mode_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."FAILURE_MODE_IDENTIFIER" ;;
    hidden: yes
  }

  dimension_group: last_seen {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_SEEN" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: level {
    type: number
    sql: ${TABLE}."LEVEL" ;;
    hidden: yes
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
    hidden: yes
  }

  dimension: module_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."MODULE_IDENTIFIER" ;;
    hidden: yes
  }

  dimension: occurrences {
    type: number
    sql: ${TABLE}."OCCURRENCES" ;;
    hidden: yes
  }

  dimension_group: report_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: suspect_parameter_number {
    type: number
    sql: ${TABLE}."SUSPECT_PARAMETER_NUMBER" ;;
    hidden: yes
  }

  dimension: tracking_event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
    hidden: yes
  }

  dimension: tracking_obd_dtc_code_id {
    type: number
    sql: ${TABLE}."TRACKING_OBD_DTC_CODE_ID" ;;
    hidden: yes
  }

  dimension_group: vendor_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."VENDOR_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  measure: asset_fault_code_count {
    type: count
    filters: [cleared_date: "null"]
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: []
    hidden: yes
  }
}
