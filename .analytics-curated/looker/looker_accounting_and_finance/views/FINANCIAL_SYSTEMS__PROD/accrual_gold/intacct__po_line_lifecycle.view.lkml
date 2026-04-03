view: intacct__po_line_lifecycle {
  sql_table_name: "ACCRUAL_GOLD"."INTACCT__PO_LINE_LIFECYCLE" ;;

  dimension: fk_poe_header_id {
    type: number
    sql: ${TABLE}."FK_POE_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_poe_line_id {
    type: number
    sql: ${TABLE}."FK_POE_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_t3_po_header_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_HEADER_ID" ;;
  }

  dimension: fk_t3_po_line_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_LINE_ID" ;;
  }

  dimension: fk_t3_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_t3_po_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_RECEIPT_LINE_ID" ;;
  }

  dimension: fk_po_header_id {
    type: number
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_po_line_id {
    type: number
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
    value_format_name: id
  }

  dimension: po_number_t3 {
    type: string
    sql: ${TABLE}."PO_NUMBER_T3" ;;
  }

  dimension: po_number_sage {
    type: string
    sql: ${TABLE}."PO_NUMBER_SAGE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: status_po_sage {
    type: string
    sql: ${TABLE}."STATUS_PO_SAGE" ;;
  }

  dimension: fk_vi_line_id {
    type: number
    sql: ${TABLE}."FK_VI_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_vi_header_id {
    type: number
    sql: ${TABLE}."FK_VI_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_ap_line_id {
    type: number
    sql: ${TABLE}."FK_AP_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_cpo_line_id {
    type: number
    sql: ${TABLE}."FK_CPO_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_cpo_header_id {
    type: number
    sql: ${TABLE}."FK_CPO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_cponp_line_id {
    type: number
    sql: ${TABLE}."FK_CPONP_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_cponp_header_id {
    type: number
    sql: ${TABLE}."FK_CPONP_HEADER_ID" ;;
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

  dimension_group: date_po_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PO_CREATED" ;;
  }

  dimension_group: date_receipt_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECEIPT_CREATED" ;;
  }

  dimension_group: date_vi_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_VI_CREATED" ;;
  }

  dimension_group: date_bill_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BILL_CREATED" ;;
  }

  dimension_group: date_bill_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BILL_DUE" ;;
  }

  dimension_group: date_bill_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BILL_PAID" ;;
  }

  dimension_group: date_cpo_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CPO_CREATED" ;;
  }

  dimension_group: date_cponp_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CPONP_CREATED" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: qty_ordered_po {
    type: number
    sql: ${TABLE}."QTY_ORDERED_PO" ;;
  }

  dimension: qty_accepted_po {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED_PO" ;;
  }

  dimension: qty_rejected_po {
    type: number
    sql: ${TABLE}."QTY_REJECTED_PO" ;;
  }

  dimension: qty_received_po {
    type: number
    sql: ${TABLE}."QTY_RECEIVED_PO" ;;
  }

  dimension: qty_converted_po {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_PO" ;;
  }

  dimension: qty_remaining_po {
    type: number
    sql: ${TABLE}."QTY_REMAINING_PO" ;;
  }

  dimension: unit_price_po {
    type: number
    sql: ${TABLE}."UNIT_PRICE_PO" ;;
  }

  dimension: amount_ordered_po {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED_PO" ;;
    value_format_name: usd
  }

  dimension: amount_accepted_po {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED_PO" ;;
    value_format_name: usd
  }

  dimension: amount_rejected_po {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED_PO" ;;
    value_format_name: usd
  }

  dimension: amount_received_po {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED_PO" ;;
    value_format_name: usd
  }

  dimension: amount_converted_po {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_PO" ;;
    value_format_name: usd
  }

  dimension: id_item_receipt {
    type: string
    sql: ${TABLE}."ID_ITEM_RECEIPT" ;;
  }

  dimension: name_item_receipt {
    type: string
    sql: ${TABLE}."NAME_ITEM_RECEIPT" ;;
  }

  dimension: memo_receipt {
    type: string
    sql: ${TABLE}."MEMO_RECEIPT" ;;
  }

  dimension: fk_department_id_receipt {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID_RECEIPT" ;;
  }

  dimension: name_department_receipt {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT_RECEIPT" ;;
  }

  dimension: id_expense_line_receipt {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE_RECEIPT" ;;
  }

  dimension: name_expense_line_receipt {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE_RECEIPT" ;;
  }

  dimension: category_expense_receipt {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE_RECEIPT" ;;
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }

  dimension: qty_converted_receipt {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_RECEIPT" ;;
  }

  dimension: qty_remaining_receipt {
    type: number
    sql: ${TABLE}."QTY_REMAINING_RECEIPT" ;;
  }

  dimension: unit_price_receipt {
    type: number
    sql: ${TABLE}."UNIT_PRICE_RECEIPT" ;;
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
  }

  dimension: amount_converted_receipt {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_RECEIPT" ;;
    value_format_name: usd
  }

  dimension: amount_remaining_receipt {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_RECEIPT" ;;
    value_format_name: usd
  }

  dimension: id_item_vi {
    type: string
    sql: ${TABLE}."ID_ITEM_VI" ;;
  }

  dimension: name_item_vi {
    type: string
    sql: ${TABLE}."NAME_ITEM_VI" ;;
  }

  dimension: memo_vi {
    type: string
    sql: ${TABLE}."MEMO_VI" ;;
  }

  dimension: fk_department_id_vi {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID_VI" ;;
  }

  dimension: name_department_vi {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT_VI" ;;
  }

  dimension: id_expense_line_vi {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE_VI" ;;
  }

  dimension: name_expense_line_vi {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE_VI" ;;
  }

  dimension: category_expense_vi {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE_VI" ;;
  }

  dimension: qty_billed_vi {
    type: number
    sql: ${TABLE}."QTY_BILLED_VI" ;;
  }

  dimension: qty_converted_vi {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_VI" ;;
  }

  dimension: qty_remaining_vi {
    type: number
    sql: ${TABLE}."QTY_REMAINING_VI" ;;
  }

  dimension: unit_price_vi {
    type: number
    sql: ${TABLE}."UNIT_PRICE_VI" ;;
  }

  dimension: amount_billed_vi {
    type: number
    sql: ${TABLE}."AMOUNT_BILLED_VI" ;;
    value_format_name: usd
  }

  dimension: amount_converted_vi {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_VI" ;;
    value_format_name: usd
  }

  dimension: amount_remaining_vi {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_VI" ;;
    value_format_name: usd
  }

  dimension: account_number_bill {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER_BILL" ;;
  }

  dimension: account_title_bill {
    type: string
    sql: ${TABLE}."ACCOUNT_TITLE_BILL" ;;
  }

  dimension: department_id_bill {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID_BILL" ;;
  }

  dimension: department_name_bill {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME_BILL" ;;
  }

  dimension: expense_line_bill {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_BILL" ;;
  }

  dimension: expense_line_name_bill {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_NAME_BILL" ;;
  }

  dimension: category_expense_bill {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE_BILL" ;;
  }

  dimension: memo_bill {
    type: string
    sql: ${TABLE}."MEMO_BILL" ;;
  }

  dimension: amount_bill_line {
    type: number
    sql: ${TABLE}."AMOUNT_BILL_LINE" ;;
    value_format_name: usd
  }

  dimension: amount_bill_line_paid {
    type: number
    sql: ${TABLE}."AMOUNT_BILL_LINE_PAID" ;;
    value_format_name: usd
  }

  dimension: id_item_cpo {
    type: string
    sql: ${TABLE}."ID_ITEM_CPO" ;;
  }

  dimension: name_item_cpo {
    type: string
    sql: ${TABLE}."NAME_ITEM_CPO" ;;
  }

  dimension: memo_cpo {
    type: string
    sql: ${TABLE}."MEMO_CPO" ;;
  }

  dimension: fk_department_id_cpo {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID_CPO" ;;
  }

  dimension: name_department_cpo {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT_CPO" ;;
  }

  dimension: qty_billed_cpo {
    type: number
    sql: ${TABLE}."QTY_BILLED_CPO" ;;
  }

  dimension: qty_converted_cpo {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_CPO" ;;
  }

  dimension: qty_remaining_cpo {
    type: number
    sql: ${TABLE}."QTY_REMAINING_CPO" ;;
  }

  dimension: unit_price_cpo {
    type: number
    sql: ${TABLE}."UNIT_PRICE_CPO" ;;
  }

  dimension: amount_billed_cpo {
    type: number
    sql: ${TABLE}."AMOUNT_BILLED_CPO" ;;
    value_format_name: usd
  }

  dimension: amount_converted_cpo {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_CPO" ;;
    value_format_name: usd
  }

  dimension: amount_remaining_cpo {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_CPO" ;;
    value_format_name: usd
  }

  dimension: id_item_cponp {
    type: string
    sql: ${TABLE}."ID_ITEM_CPONP" ;;
  }

  dimension: name_item_cponp {
    type: string
    sql: ${TABLE}."NAME_ITEM_CPONP" ;;
  }

  dimension: memo_cponp {
    type: string
    sql: ${TABLE}."MEMO_CPONP" ;;
  }

  dimension: fk_department_id_cponp {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID_CPONP" ;;
  }

  dimension: name_department_cponp {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT_CPONP" ;;
  }

  dimension: qty_billed_cponp {
    type: number
    sql: ${TABLE}."QTY_BILLED_CPONP" ;;
  }

  dimension: qty_converted_cponp {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_CPONP" ;;
  }

  dimension: qty_remaining_cponp {
    type: number
    sql: ${TABLE}."QTY_REMAINING_CPONP" ;;
  }

  dimension: unit_price_cponp {
    type: number
    sql: ${TABLE}."UNIT_PRICE_CPONP" ;;
  }

  dimension: amount_billed_cponp {
    type: number
    sql: ${TABLE}."AMOUNT_BILLED_CPONP" ;;
    value_format_name: usd
  }

  dimension: amount_converted_cponp {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_CPONP" ;;
    value_format_name: usd
  }

  dimension: amount_remaining_cponp {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_CPONP" ;;
    value_format_name: usd
  }

  dimension_group: timestamp_po_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_CREATED" ;;
  }

  dimension_group: timestamp_receipt_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_RECEIPT_CREATED" ;;
  }

  dimension_group: timestamp_vi_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_VI_CREATED" ;;
  }

  dimension_group: timestamp_bill_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_BILL_CREATED" ;;
  }

  dimension_group: timestamp_cpo_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CPO_CREATED" ;;
  }

  dimension_group: timestamp_cponp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CPONP_CREATED" ;;
  }

  dimension: url_po {
    type: string
    sql: ${TABLE}."URL_PO" ;;
    link: {
      label: "URL Po"
      url: "{{ value }}"
    }
  }

  dimension: url_po_receipt {
    type: string
    sql: ${TABLE}."URL_PO_RECEIPT" ;;
    link: {
      label: "URL Po Receipt"
      url: "{{ value }}"
    }
  }

  dimension: url_vendor_invoice {
    type: string
    sql: ${TABLE}."URL_VENDOR_INVOICE" ;;
    link: {
      label: "URL Vendor Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_cpo {
    type: string
    sql: ${TABLE}."URL_CPO" ;;
    link: {
      label: "URL Cpo"
      url: "{{ value }}"
    }
  }

  dimension: url_cponp {
    type: string
    sql: ${TABLE}."URL_CPONP" ;;
    link: {
      label: "URL Cponp"
      url: "{{ value }}"
    }
  }

  dimension: url_ap_bill {
    type: string
    sql: ${TABLE}."URL_AP_BILL" ;;
    link: {
      label: "URL Ap Bill"
      url: "{{ value }}"
    }
  }

  dimension: url_bill_pdf {
    type: string
    sql: ${TABLE}."URL_BILL_PDF" ;;
    link: {
      label: "URL Bill Pdf"
      url: "{{ value }}"
    }
  }

  set: detail {
    fields: [
      fk_poe_header_id,
      fk_poe_line_id,
      fk_t3_po_header_id,
      fk_t3_po_line_id,
      fk_t3_po_receipt_header_id,
      fk_t3_po_receipt_line_id,
      fk_po_header_id,
      fk_po_line_id,
      po_number_t3,
      po_number_sage,
      invoice_number,
      status_po_sage,
      fk_vi_line_id,
      fk_vi_header_id,
      fk_ap_line_id,
      fk_ap_header_id,
      fk_cpo_line_id,
      fk_cpo_header_id,
      fk_cponp_line_id,
      fk_cponp_header_id,
      id_vendor,
      name_vendor,
      date_po_created_date,
      date_receipt_created_date,
      date_vi_created_date,
      date_bill_created_date,
      date_bill_due_date,
      date_bill_paid_date,
      date_cpo_created_date,
      date_cponp_created_date,
      id_item,
      name_item,
      qty_ordered_po,
      qty_accepted_po,
      qty_rejected_po,
      qty_received_po,
      qty_converted_po,
      qty_remaining_po,
      unit_price_po,
      amount_ordered_po,
      amount_accepted_po,
      amount_rejected_po,
      amount_received_po,
      amount_converted_po,
      id_item_receipt,
      name_item_receipt,
      memo_receipt,
      fk_department_id_receipt,
      name_department_receipt,
      id_expense_line_receipt,
      name_expense_line_receipt,
      category_expense_receipt,
      qty_received,
      qty_converted_receipt,
      qty_remaining_receipt,
      unit_price_receipt,
      amount_received,
      amount_converted_receipt,
      amount_remaining_receipt,
      id_item_vi,
      name_item_vi,
      memo_vi,
      fk_department_id_vi,
      name_department_vi,
      id_expense_line_vi,
      name_expense_line_vi,
      category_expense_vi,
      qty_billed_vi,
      qty_converted_vi,
      qty_remaining_vi,
      unit_price_vi,
      amount_billed_vi,
      amount_converted_vi,
      amount_remaining_vi,
      account_number_bill,
      account_title_bill,
      department_id_bill,
      department_name_bill,
      expense_line_bill,
      expense_line_name_bill,
      category_expense_bill,
      memo_bill,
      amount_bill_line,
      amount_bill_line_paid,
      id_item_cpo,
      name_item_cpo,
      memo_cpo,
      fk_department_id_cpo,
      name_department_cpo,
      qty_billed_cpo,
      qty_converted_cpo,
      qty_remaining_cpo,
      unit_price_cpo,
      amount_billed_cpo,
      amount_converted_cpo,
      amount_remaining_cpo,
      id_item_cponp,
      name_item_cponp,
      memo_cponp,
      fk_department_id_cponp,
      name_department_cponp,
      qty_billed_cponp,
      qty_converted_cponp,
      qty_remaining_cponp,
      unit_price_cponp,
      amount_billed_cponp,
      amount_converted_cponp,
      amount_remaining_cponp,
      timestamp_po_created_date,
      timestamp_receipt_created_date,
      timestamp_vi_created_date,
      timestamp_bill_created_date,
      timestamp_cpo_created_date,
      timestamp_cponp_created_date,
      url_po,
      url_po_receipt,
      url_vendor_invoice,
      url_cpo,
      url_cponp,
      url_ap_bill,
      url_bill_pdf,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_ordered_po {
    type: sum
    sql: ${TABLE}."AMOUNT_ORDERED_PO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_accepted_po {
    type: sum
    sql: ${TABLE}."AMOUNT_ACCEPTED_PO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_rejected_po {
    type: sum
    sql: ${TABLE}."AMOUNT_REJECTED_PO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received_po {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED_PO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_po {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_PO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_receipt {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_RECEIPT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_receipt {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_RECEIPT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_billed_vi {
    type: sum
    sql: ${TABLE}."AMOUNT_BILLED_VI" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_vi {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_VI" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_vi {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_VI" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_bill_line {
    type: sum
    sql: ${TABLE}."AMOUNT_BILL_LINE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_bill_line_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_BILL_LINE_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_billed_cpo {
    type: sum
    sql: ${TABLE}."AMOUNT_BILLED_CPO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_cpo {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_CPO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_cpo {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_CPO" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_billed_cponp {
    type: sum
    sql: ${TABLE}."AMOUNT_BILLED_CPONP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_cponp {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_CPONP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_cponp {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_CPONP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
