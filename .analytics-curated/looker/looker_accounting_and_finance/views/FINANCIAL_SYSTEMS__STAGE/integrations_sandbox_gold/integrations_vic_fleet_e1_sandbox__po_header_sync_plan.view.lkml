view: integrations_vic_fleet_e1_sandbox__po_header_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_FLEET_E1_SANDBOX__PO_HEADER_SYNC_PLAN" ;;

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }
  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
  }
  dimension: currency_id {
    type: string
    sql: ${TABLE}."CURRENCY_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_issued {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ISSUED" ;;
  }
  dimension_group: deliver {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DELIVER_ON" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }
  dimension: fk_payment_term_id {
    type: string
    sql: ${TABLE}."FK_PAYMENT_TERM_ID" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }
  dimension: pk_po_header_id {
    type: number
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
