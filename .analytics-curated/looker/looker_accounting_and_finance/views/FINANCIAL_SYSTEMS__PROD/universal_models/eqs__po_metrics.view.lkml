view: eqs__po_metrics {
  sql_table_name: "EQS_GOLD"."EQS__PO_METRICS" ;;

  dimension: pk_procurement_header_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PROCUREMENT_HEADER_ID" ;;
  }

  dimension: fk_document_t3_header_id {
    type: string
    sql: ${TABLE}."FK_DOCUMENT_T3_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_document_intacct_header_id {
    type: number
    sql: ${TABLE}."FK_DOCUMENT_INTACCT_HEADER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_document_vic_header_id {
    type: string
    sql: ${TABLE}."FK_DOCUMENT_VIC_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension_group: date_po_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PO_CREATED" ;;
    group_label: "Dates"
  }

  dimension: record_system {
    type: string
    sql: ${TABLE}."RECORD_SYSTEM" ;;
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}."SOURCE_SYSTEM" ;;
  }

  dimension: num_receipts {
    type: number
    sql: ${TABLE}."NUM_RECEIPTS" ;;
  }

  dimension_group: date_earliest_receipt {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_RECEIPT" ;;
    group_label: "Dates"
  }

  dimension_group: date_latest_receipt {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LATEST_RECEIPT" ;;
    group_label: "Dates"
  }

  dimension: num_invoices {
    type: number
    sql: ${TABLE}."NUM_INVOICES" ;;
  }

  dimension_group: date_earliest_invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_INVOICE" ;;
    group_label: "Dates"
  }

  dimension_group: date_latest_invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LATEST_INVOICE" ;;
    group_label: "Dates"
  }

  dimension: status_receipt {
    type: string
    sql: ${TABLE}."STATUS_RECEIPT" ;;
  }

  dimension: status_invoice {
    type: string
    sql: ${TABLE}."STATUS_INVOICE" ;;
  }

  dimension: status_receipt_lifecycle {
    type: string
    sql: ${TABLE}."STATUS_RECEIPT_LIFECYCLE" ;;
  }

  dimension: status_invoice_lifecycle {
    type: string
    sql: ${TABLE}."STATUS_INVOICE_LIFECYCLE" ;;
  }

  dimension: is_ap_closed {
    type: yesno
    sql: ${TABLE}."IS_AP_CLOSED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_acct_closed {
    type: yesno
    sql: ${TABLE}."IS_ACCT_CLOSED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: status_ap_lifecycle {
    type: string
    sql: ${TABLE}."STATUS_AP_LIFECYCLE" ;;
  }

  dimension: status_acct_lifecycle {
    type: string
    sql: ${TABLE}."STATUS_ACCT_LIFECYCLE" ;;
  }

  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
    group_label: "Quantities"
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
    group_label: "Quantities"
  }

  dimension: qty_pending_receipt {
    type: number
    sql: ${TABLE}."QTY_PENDING_RECEIPT" ;;
    group_label: "Quantities"
  }

  dimension: qty_invoiced {
    type: number
    sql: ${TABLE}."QTY_INVOICED" ;;
    group_label: "Quantities"
  }

  dimension: qty_po_less_invoiced {
    type: number
    sql: ${TABLE}."QTY_PO_LESS_INVOICED" ;;
    group_label: "Quantities"
  }

  dimension: qty_received_less_invoiced {
    type: number
    sql: ${TABLE}."QTY_RECEIVED_LESS_INVOICED" ;;
    group_label: "Quantities"
  }

  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_pending_receipt {
    type: number
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_invoiced {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_po_less_invoiced {
    type: number
    sql: ${TABLE}."AMOUNT_PO_LESS_INVOICED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received_less_invoiced {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED_LESS_INVOICED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_inventory {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: qty_received_inventory {
    type: number
    sql: ${TABLE}."QTY_RECEIVED_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: qty_pending_receipt_inventory {
    type: number
    sql: ${TABLE}."QTY_PENDING_RECEIPT_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: qty_invoiced_inventory {
    type: number
    sql: ${TABLE}."QTY_INVOICED_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_pending_receipt_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_invoiced_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICED_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_cip {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_CIP" ;;
    group_label: "Quantities"
  }

  dimension: qty_received_cip {
    type: number
    sql: ${TABLE}."QTY_RECEIVED_CIP" ;;
    group_label: "Quantities"
  }

  dimension: qty_pending_receipt_cip {
    type: number
    sql: ${TABLE}."QTY_PENDING_RECEIPT_CIP" ;;
    group_label: "Quantities"
  }

  dimension: qty_invoiced_cip {
    type: number
    sql: ${TABLE}."QTY_INVOICED_CIP" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_cip {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received_cip {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_pending_receipt_cip {
    type: number
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_invoiced_cip {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICED_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_expense {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: qty_received_expense {
    type: number
    sql: ${TABLE}."QTY_RECEIVED_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: qty_pending_receipt_expense {
    type: number
    sql: ${TABLE}."QTY_PENDING_RECEIPT_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: qty_invoiced_expense {
    type: number
    sql: ${TABLE}."QTY_INVOICED_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_expense {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received_expense {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_pending_receipt_expense {
    type: number
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_invoiced_expense {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICED_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: gl_net_inventory {
    type: number
    sql: ${TABLE}."GL_NET_INVENTORY" ;;
    value_format_name: usd
  }

  dimension: gl_net_cip {
    type: number
    sql: ${TABLE}."GL_NET_CIP" ;;
    value_format_name: usd
  }

  dimension: gl_net_expense {
    type: number
    sql: ${TABLE}."GL_NET_EXPENSE" ;;
    value_format_name: usd
  }

  dimension: gl_net_grni {
    type: number
    sql: ${TABLE}."GL_NET_GRNI" ;;
    value_format_name: usd
  }

  dimension: gl_net_ap {
    type: number
    sql: ${TABLE}."GL_NET_AP" ;;
    value_format_name: usd
  }

  dimension: is_receipt_invoice_gl_balanced {
    type: yesno
    sql: ${TABLE}."IS_RECEIPT_INVOICE_GL_BALANCED" ;;
    html:
      {% if value == 'No' %}
        <span style="background-color:yellow; color:black; padding:3px;">No</span>
      {% else %}
        Yes
      {% endif %}
    ;;
  }

  dimension_group: date_earliest_bill_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_BILL_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension_group: date_earliest_receipt_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_RECEIPT_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension: is_earliest_bill_posted_prior_month_to_earliest_receipt {
    type: yesno
    sql: ${TABLE}."IS_EARLIEST_BILL_POSTED_PRIOR_MONTH_TO_EARLIEST_RECEIPT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension_group: date_latest_bill_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LATEST_BILL_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension_group: date_latest_receipt_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LATEST_RECEIPT_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension: is_latest_bill_posted_prior_month_to_latest_receipt {
    type: yesno
    sql: ${TABLE}."IS_LATEST_BILL_POSTED_PRIOR_MONTH_TO_LATEST_RECEIPT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_inventory {
    type: yesno
    sql: ${TABLE}."HAS_INVENTORY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_cip {
    type: yesno
    sql: ${TABLE}."HAS_CIP" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_expense {
    type: yesno
    sql: ${TABLE}."HAS_EXPENSE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_multiple_departments {
    type: yesno
    sql: ${TABLE}."HAS_MULTIPLE_DEPARTMENTS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }

  dimension: payment_term_description {
    type: string
    sql: ${TABLE}."PAYMENT_TERM_DESCRIPTION" ;;
  }

  dimension: days_payment_due {
    type: number
    sql: ${TABLE}."DAYS_PAYMENT_DUE" ;;
  }

  dimension: num_days_epay_due_date_deduction {
    type: number
    sql: ${TABLE}."NUM_DAYS_EPAY_DUE_DATE_DEDUCTION" ;;
  }

  dimension: days_payment_due_effective {
    type: number
    sql: ${TABLE}."DAYS_PAYMENT_DUE_EFFECTIVE" ;;
  }

  dimension: due_from_basis {
    type: string
    sql: ${TABLE}."DUE_FROM_BASIS" ;;
  }

  dimension: days_since_po_created {
    type: number
    sql: ${TABLE}."DAYS_SINCE_PO_CREATED" ;;
  }

  dimension: days_remaining_po_vendor_terms {
    type: number
    sql: ${TABLE}."DAYS_REMAINING_PO_VENDOR_TERMS" ;;
  }

  dimension: is_po_within_vendor_terms {
    type: yesno
    sql: ${TABLE}."IS_PO_WITHIN_VENDOR_TERMS" ;;
    html:
      {% if value == 'No' %}
        <span style="background-color:yellow; color:black; padding:3px;">No</span>
      {% else %}
        Yes
      {% endif %}
    ;;
  }

  dimension: days_remaining_earliest_receipt_vendor_terms {
    type: number
    sql: ${TABLE}."DAYS_REMAINING_EARLIEST_RECEIPT_VENDOR_TERMS" ;;
  }

  dimension: is_earliest_receipt_within_vendor_terms {
    type: yesno
    sql: ${TABLE}."IS_EARLIEST_RECEIPT_WITHIN_VENDOR_TERMS" ;;
    html:
      {% if value == 'No' %}
        <span style="background-color:yellow; color:black; padding:3px;">No</span>
      {% else %}
        Yes
      {% endif %}
    ;;
  }

  dimension: days_remaining_latest_receipt_vendor_terms {
    type: number
    sql: ${TABLE}."DAYS_REMAINING_LATEST_RECEIPT_VENDOR_TERMS" ;;
  }

  dimension: is_latest_receipt_within_vendor_terms {
    type: yesno
    sql: ${TABLE}."IS_LATEST_RECEIPT_WITHIN_VENDOR_TERMS" ;;
    html:
      {% if value == 'No' %}
        <span style="background-color:yellow; color:black; padding:3px;">No</span>
      {% else %}
        Yes
      {% endif %}
    ;;
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

  set: detail {
    fields: [
      pk_procurement_header_id,
      fk_document_t3_header_id,
      fk_document_intacct_header_id,
      fk_document_vic_header_id,
      vendor_id,
      vendor_name,
      po_number,
      date_po_created_date,
      record_system,
      source_system,
      num_receipts,
      date_earliest_receipt_date,
      date_latest_receipt_date,
      num_invoices,
      date_earliest_invoice_date,
      date_latest_invoice_date,
      status_receipt,
      status_invoice,
      status_receipt_lifecycle,
      status_invoice_lifecycle,
      is_ap_closed,
      is_acct_closed,
      status_ap_lifecycle,
      status_acct_lifecycle,
      qty_ordered,
      qty_received,
      qty_pending_receipt,
      qty_invoiced,
      qty_po_less_invoiced,
      qty_received_less_invoiced,
      amount_ordered,
      amount_received,
      amount_pending_receipt,
      amount_invoiced,
      amount_po_less_invoiced,
      amount_received_less_invoiced,
      qty_requested_inventory,
      qty_received_inventory,
      qty_pending_receipt_inventory,
      qty_invoiced_inventory,
      amount_requested_inventory,
      amount_received_inventory,
      amount_pending_receipt_inventory,
      amount_invoiced_inventory,
      qty_requested_cip,
      qty_received_cip,
      qty_pending_receipt_cip,
      qty_invoiced_cip,
      amount_requested_cip,
      amount_received_cip,
      amount_pending_receipt_cip,
      amount_invoiced_cip,
      qty_requested_expense,
      qty_received_expense,
      qty_pending_receipt_expense,
      qty_invoiced_expense,
      amount_requested_expense,
      amount_received_expense,
      amount_pending_receipt_expense,
      amount_invoiced_expense,
      gl_net_inventory,
      gl_net_cip,
      gl_net_expense,
      gl_net_grni,
      gl_net_ap,
      is_receipt_invoice_gl_balanced,
      date_earliest_bill_gl_posted_date,
      date_earliest_receipt_gl_posted_date,
      is_earliest_bill_posted_prior_month_to_earliest_receipt,
      date_latest_bill_gl_posted_date,
      date_latest_receipt_gl_posted_date,
      is_latest_bill_posted_prior_month_to_latest_receipt,
      has_inventory,
      has_cip,
      has_expense,
      has_multiple_departments,
      name_payment_term,
      payment_term_description,
      days_payment_due,
      num_days_epay_due_date_deduction,
      days_payment_due_effective,
      due_from_basis,
      days_since_po_created,
      days_remaining_po_vendor_terms,
      is_po_within_vendor_terms,
      days_remaining_earliest_receipt_vendor_terms,
      is_earliest_receipt_within_vendor_terms,
      days_remaining_latest_receipt_vendor_terms,
      is_latest_receipt_within_vendor_terms,
      url_po_source,
      url_po_vic,
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

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_pending_receipt {
    type: sum
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoiced {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_po_less_invoiced {
    type: sum
    sql: ${TABLE}."AMOUNT_PO_LESS_INVOICED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received_less_invoiced {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED_LESS_INVOICED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_pending_receipt_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoiced_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICED_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_pending_receipt_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoiced_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICED_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_pending_receipt_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_PENDING_RECEIPT_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoiced_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICED_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_num_receipts {
    type: average
    sql: ${TABLE}."NUM_RECEIPTS" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_num_invoices {
    type: average
    sql: ${TABLE}."NUM_INVOICES" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_ordered {
    type: average
    sql: ${TABLE}."QTY_ORDERED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received {
    type: average
    sql: ${TABLE}."QTY_RECEIVED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_pending_receipt {
    type: average
    sql: ${TABLE}."QTY_PENDING_RECEIPT" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_invoiced {
    type: average
    sql: ${TABLE}."QTY_INVOICED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_po_less_invoiced {
    type: average
    sql: ${TABLE}."QTY_PO_LESS_INVOICED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received_less_invoiced {
    type: average
    sql: ${TABLE}."QTY_RECEIVED_LESS_INVOICED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_inventory {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received_inventory {
    type: average
    sql: ${TABLE}."QTY_RECEIVED_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_pending_receipt_inventory {
    type: average
    sql: ${TABLE}."QTY_PENDING_RECEIPT_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_invoiced_inventory {
    type: average
    sql: ${TABLE}."QTY_INVOICED_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_cip {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received_cip {
    type: average
    sql: ${TABLE}."QTY_RECEIVED_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_pending_receipt_cip {
    type: average
    sql: ${TABLE}."QTY_PENDING_RECEIPT_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_invoiced_cip {
    type: average
    sql: ${TABLE}."QTY_INVOICED_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_expense {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received_expense {
    type: average
    sql: ${TABLE}."QTY_RECEIVED_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_pending_receipt_expense {
    type: average
    sql: ${TABLE}."QTY_PENDING_RECEIPT_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_invoiced_expense {
    type: average
    sql: ${TABLE}."QTY_INVOICED_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_num_days_epay_due_date_deduction {
    type: average
    sql: ${TABLE}."NUM_DAYS_EPAY_DUE_DATE_DEDUCTION" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
