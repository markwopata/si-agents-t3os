view: keypad_firmware {
  sql_table_name: "TRACKERS"."KEYPAD_FIRMWARE"
    ;;
  drill_fields: [keypad_firmware_id]

  dimension: keypad_firmware_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_FIRMWARE_ID" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: data {
    type: string
    sql: ${TABLE}."DATA" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: disabled {
    type: yesno
    sql: ${TABLE}."DISABLED" ;;
  }

  dimension: is_test {
    type: yesno
    sql: ${TABLE}."IS_TEST" ;;
  }

  dimension: keypad_controller_type_id {
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
  }

  dimension: latest {
    type: yesno
    sql: ${TABLE}."LATEST" ;;
  }

  dimension: release_notes {
    type: string
    sql: ${TABLE}."RELEASE_NOTES" ;;
  }

  dimension: sha256 {
    type: string
    sql: ${TABLE}."SHA256" ;;
  }

  dimension: uploader_account_id {
    type: number
    sql: ${TABLE}."UPLOADER_ACCOUNT_ID" ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}."VERSION" ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_firmware_id, app_name]
  }
}
