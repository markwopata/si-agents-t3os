view: keypad_codes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."KEYPAD_CODES"
    ;;
  drill_fields: [keypad_code_id]

  dimension: keypad_code_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_CODE_ID" ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_reserved {
    type: yesno
    sql: ${TABLE}."IS_RESERVED" ;;
  }

  dimension: master_code {
    type: yesno
    sql: ${TABLE}."MASTER_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_code_id]
  }
}
