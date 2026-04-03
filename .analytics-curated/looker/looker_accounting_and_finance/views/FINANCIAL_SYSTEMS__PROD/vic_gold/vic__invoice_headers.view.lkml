view: vic__invoice_headers {
  sql_table_name: "VIC_GOLD"."VIC__INVOICE_HEADERS" ;;

  dimension: pk_invoice_header_id {
    type: string
    sql: ${TABLE}."PK_INVOICE_HEADER_ID" ;;
    primary_key: yes
  }

  dimension: fk_sage_bill_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_BILL_HEADER_ID" ;;
  }

  dimension: fk_sage_alt_bill_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_ALT_BILL_HEADER_ID" ;;
  }

  dimension: fk_sage_invoice_header_id {
    type: number
    sql: ${TABLE}."FK_SAGE_INVOICE_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_sage_alt_invoice_header_id {
    type: number
    sql: ${TABLE}."FK_SAGE_ALT_INVOICE_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension_group: date_gl {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL" ;;
  }

  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
  }

  dimension: days_past_due {
    type: number
    sql: datediff(day, ${date_due_date}, current_date) ;;
  }

  dimension: past_due_bucket_sort {
    hidden: yes
    type: number
    sql:
    case
      when ${days_past_due} < 0 then 0
      when ${days_past_due} between 0 and 14 then 1
      when ${days_past_due} between 15 and 30 then 2
      when ${days_past_due} between 31 and 44 then 3
      when ${days_past_due} between 45 and 59 then 4
      when ${days_past_due} between 60 and 89 then 5
      when ${days_past_due} between 90 and 119 then 6
      when ${days_past_due} >= 120 then 7
    end ;;
  }

  dimension: past_due_bucket {
    type: string
    order_by_field: past_due_bucket_sort
    sql:
    case
      when ${days_past_due} < 0 then 'Current'
      when ${days_past_due} between 0 and 14 then '0-14'
      when ${days_past_due} between 15 and 30 then '15-30'
      when ${days_past_due} between 31 and 44 then '30+'
      when ${days_past_due} between 45 and 59 then '45+'
      when ${days_past_due} between 60 and 89 then '60+'
      when ${days_past_due} between 90 and 119 then '90+'
      when ${days_past_due} >= 120 then '120+'
    end ;;
  }

  dimension: status_bill {
    type: string
    sql: ${TABLE}."STATUS_BILL" ;;
  }

  dimension: status_payment {
    type: string
    sql: ${TABLE}."STATUS_PAYMENT" ;;
  }

  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_sum {
    type: number
    sql: ${TABLE}."AMOUNT_SUM" ;;
    value_format_name: usd
  }

  dimension: amount_without_tax {
    type: number
    sql: ${TABLE}."AMOUNT_WITHOUT_TAX" ;;
    value_format_name: usd
  }

  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
  }

  dimension: amount_freight {
    type: number
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    value_format_name: usd
  }

  dimension: amount_tax {
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
    value_format_name: usd
  }

  dimension: payment_term_count {
    type: number
    sql: ${TABLE}."PAYMENT_TERM_COUNT" ;;
  }

  dimension: payment_term_unit {
    type: string
    sql: ${TABLE}."PAYMENT_TERM_UNIT" ;;
  }

  dimension: code_currency {
    type: string
    sql: ${TABLE}."CODE_CURRENCY" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: type_transaction {
    type: string
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: posting_error {
    type: string
    sql: ${TABLE}."POSTING_ERROR" ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
    link: {
      label: "URL Source Po"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_po {
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
    link: {
      label: "URL Vic Po"
      url: "{{ value }}"
    }
  }

  dimension: url_invoice {
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
    link: {
      label: "URL Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_invoice_image {
    type: string
    sql: ${TABLE}."URL_INVOICE_IMAGE" ;;
    link: {
      label: "URL Invoice Image"
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

  dimension: fk_vic_vendor_id {
    type: number
    sql: ${TABLE}."FK_VIC_VENDOR_ID" ;;
    value_format_name: id
  }

  dimension: fk_vic_payment_term_id {
    type: string
    sql: ${TABLE}."FK_VIC_PAYMENT_TERM_ID" ;;
  }

  dimension_group: date_service_period_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_SERVICE_PERIOD_START" ;;
  }

  dimension_group: date_service_period_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_SERVICE_PERIOD_END" ;;
  }

  dimension: line_items {
    type: string
    sql: ${TABLE}."LINE_ITEMS" ;;
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
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_NUMERIC" ;;
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

  dimension_group: timestamp_posted_sage {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_POSTED_SAGE" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      pk_invoice_header_id,
      fk_sage_bill_header_id,
      fk_sage_alt_bill_header_id,
      fk_sage_invoice_header_id,
      fk_sage_alt_invoice_header_id,
      id_vendor,
      name_vendor,
      invoice_number,
      po_number,
      date_gl_date,
      date_due_date,
      days_past_due,
      status_bill,
      status_payment,
      amount_total,
      amount_sum,
      amount_without_tax,
      amount_net,
      amount_freight,
      amount_tax,
      payment_term_count,
      payment_term_unit,
      code_currency,
      notes,
      type_transaction,
      description,
      posting_error,
      url_source_po,
      url_vic_po,
      url_invoice,
      url_invoice_image,
      url_sage_bill,
      url_sage_invoice,
      url_sage_alt_bill,
      url_sage_alt_invoice,
      fk_vic_vendor_id,
      fk_vic_payment_term_id,
      date_service_period_start_date,
      date_service_period_end_date,
      line_items,
      name_environment,
      name_environment_alias,
      fk_company_id_numeric,
      fk_company_id_uuid,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_posted_sage_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_total {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_sum {
    type: sum
    sql: ${TABLE}."AMOUNT_SUM" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: amount {
    label: "$"
    type: sum
    sql: ${TABLE}."AMOUNT_SUM" ;;
    value_format: "$#,##0"
    drill_fields: [detail*]
  }

  measure: total_amount_without_tax {
    type: sum
    sql: ${TABLE}."AMOUNT_WITHOUT_TAX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_net {
    type: sum
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_freight {
    type: sum
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_tax {
    type: sum
    sql: ${TABLE}."AMOUNT_TAX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
