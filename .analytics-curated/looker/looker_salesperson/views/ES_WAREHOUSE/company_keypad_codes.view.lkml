view: company_keypad_codes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_KEYPAD_CODES"
    ;;
  drill_fields: [company_keypad_code_id]

  dimension: company_keypad_code_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_KEYPAD_CODE_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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

  dimension_group: date_deactivated {
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
    sql: CAST(${TABLE}."DATE_DEACTIVATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: keypad_code_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."KEYPAD_CODE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: rental_default {
    type: yesno
    sql: ${TABLE}."RENTAL_DEFAULT" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_keypad_code_id, name, keypad_codes.keypad_code_id]
  }
}
