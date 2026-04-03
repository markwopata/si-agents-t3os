view: vic__gl_accounts {
  sql_table_name: "VIC_GOLD"."VIC__GL_ACCOUNTS" ;;

  dimension: pk_vic_gl_account_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.pk_vic_gl_account_id ;;
    value_format_name: id
  }

  dimension: number_gl_account {
    type: number
    sql: ${TABLE}.number_gl_account ;;
    value_format_name: id
  }

  dimension: name_gl_account {
    type: string
    sql: ${TABLE}.name_gl_account ;;
  }

  dimension: name_full_gl_account {
    type: string
    sql: ${TABLE}.name_full_gl_account ;;
  }

  dimension: fk_sage_gl_account_id {
    type: number
    sql: ${TABLE}.fk_sage_gl_account_id ;;
    value_format_name: id
  }

  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}.fk_extract_hash_id ;;
    value_format_name: id
  }

  dimension: name_environment {
    type: string
    sql: ${TABLE}.name_environment ;;
  }

  dimension: fk_company_id_numeric {
    type: number
    sql: ${TABLE}.fk_company_id_numeric ;;
  }

  dimension: fk_company_id_uuid {
    type: number
    sql: ${TABLE}.fk_company_id_uuid ;;
    value_format_name: id
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_modified ;;
  }

  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_extracted ;;
  }
  measure: count {
    type: count
  }
}
