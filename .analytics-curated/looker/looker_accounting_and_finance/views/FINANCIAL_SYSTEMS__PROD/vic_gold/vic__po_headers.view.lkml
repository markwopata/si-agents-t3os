view: vic__po_headers {
  sql_table_name: "VIC_GOLD"."VIC__PO_HEADERS" ;;

  dimension: pk_po_header_id {
    type: string
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
    primary_key: yes
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }

  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
  }

  dimension: amount_requested {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
  }

  dimension: amount_converted {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
  }

  dimension: amount_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
  }

  dimension: code_currency {
    type: string
    sql: ${TABLE}."CODE_CURRENCY" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: type_matching {
    type: string
    sql: ${TABLE}."TYPE_MATCHING" ;;
  }

  dimension: status_matching {
    type: string
    sql: ${TABLE}."STATUS_MATCHING" ;;
  }

  dimension: status_po_vic {
    type: string
    sql: ${TABLE}."STATUS_PO_VIC" ;;
  }

  dimension: status_po_source {
    type: string
    sql: ${TABLE}."STATUS_PO_SOURCE" ;;
  }

  dimension: type_po_document {
    type: string
    sql: ${TABLE}."TYPE_PO_DOCUMENT" ;;
  }

  dimension: email_requestor {
    type: string
    sql: ${TABLE}."EMAIL_REQUESTOR" ;;
  }

  dimension: name_requestor {
    type: string
    sql: ${TABLE}."NAME_REQUESTOR" ;;
  }

  dimension: email_site_owner {
    type: string
    sql: ${TABLE}."EMAIL_SITE_OWNER" ;;
  }

  dimension: name_site_owner {
    type: string
    sql: ${TABLE}."NAME_SITE_OWNER" ;;
  }

  dimension: line_items {
    type: string
    sql: ${TABLE}."LINE_ITEMS" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_delivered {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DELIVERED" ;;
  }

  dimension_group: date_issued {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ISSUED" ;;
  }

  dimension: url_source {
    type: string
    sql: ${TABLE}."URL_SOURCE" ;;
    link: {
      label: "URL Source"
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

  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }

  dimension: name_environment_alias {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT_ALIAS" ;;
  }

  dimension: fk_company_id_numeric {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID_NUMERIC" ;;
    value_format_name: id
  }

  dimension: fk_company_id_uuid {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_UUID" ;;
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DELETED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      pk_po_header_id,
      fk_source_po_header_id,
      id_vendor,
      name_vendor,
      po_number,
      amount,
      qty_requested,
      qty_converted,
      qty_remaining,
      amount_requested,
      amount_converted,
      amount_remaining,
      code_currency,
      description,
      type_matching,
      status_matching,
      status_po_vic,
      status_po_source,
      type_po_document,
      email_requestor,
      name_requestor,
      email_site_owner,
      name_site_owner,
      line_items,
      date_created_date,
      date_delivered_date,
      date_issued_date,
      url_source,
      url_vic,
      name_environment,
      name_environment_alias,
      fk_company_id_numeric,
      fk_company_id_uuid,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_deleted_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
