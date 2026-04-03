view: vic__payment_terms {
  sql_table_name: "VIC_GOLD"."VIC__PAYMENT_TERMS" ;;

  dimension: pk_payment_term_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.pk_payment_term_id ;;
    value_format_name: id
  }

  dimension: fk_source_payment_term_id {
    type: number
    sql: ${TABLE}.fk_source_payment_term_id ;;
    value_format_name: id
  }

  dimension: name_term {
    type: string
    sql: ${TABLE}.name_term ;;
  }

  dimension: term_description {
    type: string
    sql: ${TABLE}.term_description ;;
  }

  dimension: days_to_pay {
    type: string
    sql: ${TABLE}.days_to_pay ;;
  }

  dimension: days_to_pay_condition {
    type: string
    sql: ${TABLE}.days_to_pay_condition ;;
  }

  dimension: discount_days {
    type: string
    sql: ${TABLE}.discount_days ;;
  }

  dimension: discount_days_condition {
    type: string
    sql: ${TABLE}.discount_days_condition ;;
  }

  dimension: discount_percentage {
    type: string
    sql: ${TABLE}.discount_percentage ;;
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

  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_extracted ;;
  }
  measure: count {
    type: count
  }
}
