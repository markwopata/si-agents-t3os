view: credit_notes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CREDIT_NOTES"
    ;;
  drill_fields: [credit_note_id]

  dimension: credit_note_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
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

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: credit_note_type_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
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

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: erp_external_id {
    type: string
    sql: ${TABLE}."ERP_EXTERNAL_ID" ;;
  }

  dimension: credit_note_status_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: originating_invoice_id {
    type: number
    sql: ${TABLE}."ORIGINATING_INVOICE_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: remaining_credit_amount {
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: total_credit_amount {
    type: number
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
  }

  dimension: days_from_today_to_date_created {
    type:  number
    sql:  datediff(day,${date_created_raw},current_timestamp()) ;;
    # DATE_PART('day',current_timestamp()-${date_created_raw}::timestamp) ;;
  }

  measure: Total_Available_Credit_Amount{
    type: sum
    sql: ${remaining_credit_amount} ;;
    filters: [days_from_today_to_date_created: ">= 0",
      remaining_credit_amount: ">0"]
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: count {
    type: count
    drill_fields: [credit_note_id]
  }

  measure: credit_note_time {
    type: number
    sql: ${count} * 0.01 ;;
  }


  measure: sum_total_credit_amount {
    type: sum
    sql: ${total_credit_amount} ;;
  }

  set: detail {
    fields: [
      companies.name,
      credit_note_id,
      Total_Available_Credit_Amount
    ]
  }
}
