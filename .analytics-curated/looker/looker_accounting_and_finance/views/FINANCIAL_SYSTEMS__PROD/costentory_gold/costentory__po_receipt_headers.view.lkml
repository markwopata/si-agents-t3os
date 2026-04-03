view: costentory__po_receipt_headers {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__PO_RECEIPT_HEADERS" ;;

  dimension: pk_po_receipt_header_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }

  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }

  dimension: amount_accepted {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
  }

  dimension: amount_rejected {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
  }

  dimension: type_receipt {
    type: string
    sql: ${TABLE}."TYPE_RECEIPT" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    link: {
      label: "URL T3"
      url: "{{ value }}"
    }
  }

  dimension: url_vic {
    type: string
    sql: ${TABLE}."URL_VIC" ;;
    link: {
      label: "URL Vic"
      url: "{{ value }}"
    }
  }

  dimension: fk_received_at_store_id {
    type: number
    sql: ${TABLE}."FK_RECEIVED_AT_STORE_ID" ;;
    value_format_name: id
  }

  dimension: name_store_received {
    type: string
    sql: ${TABLE}."NAME_STORE_RECEIVED" ;;
  }

  dimension: fk_po_requested_store_id {
    type: number
    sql: ${TABLE}."FK_PO_REQUESTED_STORE_ID" ;;
    value_format_name: id
  }

  dimension: name_store_ordered {
    type: string
    sql: ${TABLE}."NAME_STORE_ORDERED" ;;
  }

  dimension: fk_receipt_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: name_receipt_creator {
    type: string
    sql: ${TABLE}."NAME_RECEIPT_CREATOR" ;;
  }

  dimension: email_receipt_creator {
    type: string
    sql: ${TABLE}."EMAIL_RECEIPT_CREATOR" ;;
  }

  dimension: fk_receipt_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: name_receipt_modifier {
    type: string
    sql: ${TABLE}."NAME_RECEIPT_MODIFIER" ;;
  }

  dimension: email_receipt_modifier {
    type: string
    sql: ${TABLE}."EMAIL_RECEIPT_MODIFIER" ;;
  }

  dimension: fk_po_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_PO_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_po_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_PO_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
    value_format_name: id
  }

  dimension_group: timestamp_receipt_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_RECEIPT_CREATED" ;;
  }

  dimension_group: timestamp_receipt_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_RECEIPT_MODIFIED" ;;
  }

  dimension_group: timestamp_receipt_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_RECEIPT_LOADED" ;;
  }

  dimension_group: timestamp_po_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_CREATED" ;;
  }

  dimension_group: timestamp_po_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_MODIFIED" ;;
  }

  dimension_group: timestamp_po_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_ARCHIVED" ;;
  }

  set: detail {
    fields: [
      pk_po_receipt_header_id,
      fk_po_header_id,
      po_number,
      id_vendor,
      amount_ordered,
      qty_accepted,
      qty_rejected,
      qty_received,
      amount_accepted,
      amount_rejected,
      amount_received,
      type_receipt,
      note,
      url_t3,
      url_vic,
      fk_received_at_store_id,
      name_store_received,
      fk_po_requested_store_id,
      name_store_ordered,
      fk_receipt_created_by_user_id,
      name_receipt_creator,
      email_receipt_creator,
      fk_receipt_modified_by_user_id,
      name_receipt_modifier,
      email_receipt_modifier,
      fk_po_created_by_user_id,
      fk_po_modified_by_user_id,
      fk_company_id,
      timestamp_receipt_created_date,
      timestamp_receipt_modified_date,
      timestamp_receipt_loaded_date,
      timestamp_po_created_date,
      timestamp_po_modified_date,
      timestamp_po_archived_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_ordered {
    type: sum
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_accepted {
    type: sum
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_rejected {
    type: sum
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
