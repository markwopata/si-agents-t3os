view: vic__po_line_invoice_items_matched {
  sql_table_name: "VIC_GOLD"."VIC__PO_LINE_INVOICE_ITEMS_MATCHED" ;;

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }

  dimension: fk_po_line_id {
    type: string
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }

  dimension: fk_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_INVOICE_HEADER_ID" ;;
  }

  dimension: fk_sage_bill_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_BILL_HEADER_ID" ;;
  }

  dimension: fk_invoice_line_id {
    type: string
    sql: ${TABLE}."FK_INVOICE_LINE_ID" ;;
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

  dimension: po_line_number {
    type: number
    sql: ${TABLE}."PO_LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_line_number {
    type: number
    sql: ${TABLE}."INVOICE_LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: status_po_vic {
    type: string
    sql: ${TABLE}."STATUS_PO_VIC" ;;
  }

  dimension: status_po_source {
    type: string
    sql: ${TABLE}."STATUS_PO_SOURCE" ;;
  }

  dimension: status_invoice {
    type: string
    sql: ${TABLE}."STATUS_INVOICE" ;;
  }

  dimension: pol_product_number {
    type: string
    sql: ${TABLE}."POL_PRODUCT_NUMBER" ;;
  }

  dimension: pol_product_description {
    type: string
    sql: ${TABLE}."POL_PRODUCT_DESCRIPTION" ;;
  }

  dimension: invoice_item_number {
    type: string
    sql: ${TABLE}."INVOICE_ITEM_NUMBER" ;;
  }

  dimension: invoice_item_description {
    type: string
    sql: ${TABLE}."INVOICE_ITEM_DESCRIPTION" ;;
  }

  dimension: qty_pol_received {
    type: number
    sql: ${TABLE}."QTY_POL_RECEIVED" ;;
  }

  dimension: amount_pol_unit {
    type: number
    sql: ${TABLE}."AMOUNT_POL_UNIT" ;;
    value_format_name: usd
  }

  dimension: qty_invoice_line {
    type: number
    sql: ${TABLE}."QTY_INVOICE_LINE" ;;
  }

  dimension: amount_invoice_unit {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_UNIT" ;;
    value_format_name: usd
  }

  dimension: qty_matched {
    type: number
    sql: ${TABLE}."QTY_MATCHED" ;;
  }

  dimension: amount_matched {
    type: number
    sql: ${TABLE}."AMOUNT_MATCHED" ;;
    value_format_name: usd
  }

  dimension: pol_name_location {
    type: string
    sql: ${TABLE}."POL_NAME_LOCATION" ;;
  }

  dimension: pol_id_department {
    type: string
    sql: ${TABLE}."POL_ID_DEPARTMENT" ;;
  }

  dimension: url_po_source {
    type: string
    sql: ${TABLE}."URL_PO_SOURCE" ;;
    link: {
      label: "URL Po Source"
      url: "{{ value }}"
    }
  }

  dimension: url_po_vic {
    type: string
    sql: ${TABLE}."URL_PO_VIC" ;;
    link: {
      label: "URL Po Vic"
      url: "{{ value }}"
    }
  }

  dimension: url_invoice_vic {
    type: string
    sql: ${TABLE}."URL_INVOICE_VIC" ;;
    link: {
      label: "URL Invoice Vic"
      url: "{{ value }}"
    }
  }

  dimension: url_pdf {
    type: string
    sql: ${TABLE}."URL_PDF" ;;
    link: {
      label: "URL Pdf"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_bill {
    type: string
    sql: ${TABLE}."URL_SAGE_BILL" ;;
    link: {
      label: "URL Sage Bill"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_invoice {
    type: string
    sql: ${TABLE}."URL_SAGE_INVOICE" ;;
    link: {
      label: "URL Sage Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_alt_bill {
    type: string
    sql: ${TABLE}."URL_SAGE_ALT_BILL" ;;
    link: {
      label: "URL Sage Alt Bill"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_alt_invoice {
    type: string
    sql: ${TABLE}."URL_SAGE_ALT_INVOICE" ;;
    link: {
      label: "URL Sage Alt Invoice"
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
  }

  dimension: fk_company_id_uuid {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_UUID" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      fk_po_header_id,
      fk_source_po_header_id,
      fk_po_line_id,
      fk_source_po_line_id,
      fk_invoice_header_id,
      fk_sage_bill_header_id,
      fk_invoice_line_id,
      id_vendor,
      name_vendor,
      po_number,
      po_line_number,
      invoice_number,
      invoice_line_number,
      status_po_vic,
      status_po_source,
      status_invoice,
      pol_product_number,
      pol_product_description,
      invoice_item_number,
      invoice_item_description,
      qty_pol_received,
      amount_pol_unit,
      qty_invoice_line,
      amount_invoice_unit,
      qty_matched,
      amount_matched,
      pol_name_location,
      pol_id_department,
      url_po_source,
      url_po_vic,
      url_invoice_vic,
      url_pdf,
      url_sage_bill,
      url_sage_invoice,
      url_sage_alt_bill,
      url_sage_alt_invoice,
      name_environment,
      name_environment_alias,
      fk_company_id_numeric,
      fk_company_id_uuid,
      timestamp_modified_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_pol_unit {
    type: sum
    sql: ${TABLE}."AMOUNT_POL_UNIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoice_unit {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICE_UNIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_matched {
    type: sum
    sql: ${TABLE}."AMOUNT_MATCHED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
