view: tracking_obd_dtc_codes {
  sql_table_name: "PUBLIC"."TRACKING_OBD_DTC_CODES"
    ;;
  # drill_fields: [tracking_obd_dtc_code_id]

  dimension: tracking_obd_dtc_code_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKING_OBD_DTC_CODE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
  }

  measure: count {
    type: count
    drill_fields: [tracking_obd_dtc_code_id, tracking_diagnostic_codes.count]
  }
}
