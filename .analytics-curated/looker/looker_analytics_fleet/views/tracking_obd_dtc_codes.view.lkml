view: tracking_obd_dtc_codes {
  sql_table_name: "PUBLIC"."TRACKING_OBD_DTC_CODES"
    ;;
  # drill_fields: [tracking_obd_dtc_code_id]

  dimension: tracking_obd_dtc_code_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKING_OBD_DTC_CODE_ID" ;;
    hidden: yes
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

  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [tracking_obd_dtc_code_id, tracking_diagnostic_codes.count]
    hidden: yes
  }
}
