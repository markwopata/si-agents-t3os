view: costentory_sandbox__po_receipt_headers {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__PO_RECEIPT_HEADERS" ;;

  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
  }
  dimension: email_receipt_creator {
    type: string
    sql: ${TABLE}."EMAIL_RECEIPT_CREATOR" ;;
  }
  dimension: email_receipt_modifier {
    type: string
    sql: ${TABLE}."EMAIL_RECEIPT_MODIFIER" ;;
  }
  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: fk_po_requested_store_id {
    type: number
    sql: ${TABLE}."FK_PO_REQUESTED_STORE_ID" ;;
  }
  dimension: fk_receipt_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_receipt_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_received_at_store_id {
    type: number
    sql: ${TABLE}."FK_RECEIVED_AT_STORE_ID" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: name_receipt_creator {
    type: string
    sql: ${TABLE}."NAME_RECEIPT_CREATOR" ;;
  }
  dimension: name_receipt_modifier {
    type: string
    sql: ${TABLE}."NAME_RECEIPT_MODIFIER" ;;
  }
  dimension: name_store_ordered {
    type: string
    sql: ${TABLE}."NAME_STORE_ORDERED" ;;
  }
  dimension: name_store_received {
    type: string
    sql: ${TABLE}."NAME_STORE_RECEIVED" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: pk_po_receipt_header_id {
    type: string
    sql: ${TABLE}."PK_PO_RECEIPT_HEADER_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension_group: timestamp_po_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_PO_ARCHIVED" AS TIMESTAMP_NTZ) ;;
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
  dimension_group: timestamp_receipt_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_RECEIPT_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_receipt_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_RECEIPT_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_receipt_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_RECEIPT_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: type_receipt {
    type: string
    sql: ${TABLE}."TYPE_RECEIPT" ;;
  }
  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  measure: count {
    type: count
  }
}
