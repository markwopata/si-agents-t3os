view: integrations_vic_t3__po_header_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__PO_HEADER_SYNC_PLAN" ;;

  dimension: pk_po_header_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension_group: created_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CREATED_ON" ;;
  }

  dimension_group: issued_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ISSUED_ON" ;;
  }

  dimension_group: deliver_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DELIVER_ON" ;;
  }

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd
  }

  dimension: currency_id {
    type: string
    sql: ${TABLE}."CURRENCY_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }

  dimension: email_gm {
    type: string
    sql: ${TABLE}."EMAIL_GM" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: payment_term {
    type: string
    sql: ${TABLE}."PAYMENT_TERM" ;;
  }

  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }

  set: detail {
    fields: [
      pk_po_header_id,
      po_number,
      created_on_date,
      issued_on_date,
      deliver_on_date,
      amount_approved,
      currency_id,
      description,
      email_created_by,
      email_gm,
      id_vendor,
      payment_term,
      matching_type,
      action_to_take,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_approved {
    type: sum
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
