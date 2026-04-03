view: intacct__po_header_lifecycle {
  sql_table_name: "ACCRUAL_GOLD"."INTACCT__PO_HEADER_LIFECYCLE" ;;

  dimension: pk_po_header_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_t3_po_header_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_HEADER_ID" ;;
  }

  dimension: fk_t3_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_poe_header_id {
    type: number
    sql: ${TABLE}."FK_POE_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_vi_header_id {
    type: number
    sql: ${TABLE}."FK_VI_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_cpo_header_id {
    type: number
    sql: ${TABLE}."FK_CPO_HEADER_ID" ;;
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

  dimension: type_po {
    type: string
    sql: ${TABLE}."TYPE_PO" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: po_number_raw {
    type: string
    sql: ${TABLE}."PO_NUMBER_RAW" ;;
  }

  dimension: poe_number {
    type: string
    sql: ${TABLE}."POE_NUMBER" ;;
  }

  dimension: poe_state {
    type: string
    sql: ${TABLE}."POE_STATE" ;;
  }

  dimension_group: poe_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POE_DATE_CREATED" ;;
  }

  dimension: poe_qty_requested {
    type: number
    sql: ${TABLE}."POE_QTY_REQUESTED" ;;
  }

  dimension: poe_qty_converted {
    type: number
    sql: ${TABLE}."POE_QTY_CONVERTED" ;;
  }

  dimension: poe_qty_remaining {
    type: number
    sql: ${TABLE}."POE_QTY_REMAINING" ;;
  }

  dimension: poe_amount_requested {
    type: number
    sql: ${TABLE}."POE_AMOUNT_REQUESTED" ;;
  }

  dimension: poe_amount_converted {
    type: number
    sql: ${TABLE}."POE_AMOUNT_CONVERTED" ;;
  }

  dimension: poe_amount_remaining {
    type: number
    sql: ${TABLE}."POE_AMOUNT_REMAINING" ;;
  }

  dimension: state_document {
    type: string
    sql: ${TABLE}."STATE_DOCUMENT" ;;
  }

  dimension_group: po_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PO_DATE_CREATED" ;;
  }

  dimension: po_qty_requested {
    type: number
    sql: ${TABLE}."PO_QTY_REQUESTED" ;;
  }

  dimension: po_qty_converted {
    type: number
    sql: ${TABLE}."PO_QTY_CONVERTED" ;;
  }

  dimension: po_qty_remaining {
    type: number
    sql: ${TABLE}."PO_QTY_REMAINING" ;;
  }

  dimension: po_amount_requested {
    type: number
    sql: ${TABLE}."PO_AMOUNT_REQUESTED" ;;
  }

  dimension: po_amount_converted {
    type: number
    sql: ${TABLE}."PO_AMOUNT_CONVERTED" ;;
  }

  dimension: po_amount_remaining {
    type: number
    sql: ${TABLE}."PO_AMOUNT_REMAINING" ;;
  }

  dimension: vi_number {
    type: string
    sql: ${TABLE}."VI_NUMBER" ;;
  }

  dimension: vi_state {
    type: string
    sql: ${TABLE}."VI_STATE" ;;
  }

  dimension_group: vi_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VI_DATE_CREATED" ;;
  }

  dimension: vi_concur_image_id {
    type: string
    sql: ${TABLE}."VI_CONCUR_IMAGE_ID" ;;
  }

  dimension: vi_qty_requested {
    type: number
    sql: ${TABLE}."VI_QTY_REQUESTED" ;;
  }

  dimension: vi_qty_converted {
    type: number
    sql: ${TABLE}."VI_QTY_CONVERTED" ;;
  }

  dimension: vi_qty_remaining {
    type: number
    sql: ${TABLE}."VI_QTY_REMAINING" ;;
  }

  dimension: vi_amount_requested {
    type: number
    sql: ${TABLE}."VI_AMOUNT_REQUESTED" ;;
  }

  dimension: vi_amount_converted {
    type: number
    sql: ${TABLE}."VI_AMOUNT_CONVERTED" ;;
  }

  dimension: vi_amount_remaining {
    type: number
    sql: ${TABLE}."VI_AMOUNT_REMAINING" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_state {
    type: string
    sql: ${TABLE}."BILL_STATE" ;;
  }

  dimension_group: bill_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILL_DATE_CREATED" ;;
  }

  dimension_group: bill_date_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILL_DATE_PAID" ;;
  }

  dimension: bill_amount {
    type: number
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  dimension: bill_amount_paid {
    type: number
    sql: ${TABLE}."BILL_AMOUNT_PAID" ;;
  }

  dimension: cpo_number {
    type: string
    sql: ${TABLE}."CPO_NUMBER" ;;
  }

  dimension: cpo_state {
    type: string
    sql: ${TABLE}."CPO_STATE" ;;
  }

  dimension_group: cpo_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CPO_DATE_CREATED" ;;
  }

  dimension: cpo_qty_requested {
    type: number
    sql: ${TABLE}."CPO_QTY_REQUESTED" ;;
  }

  dimension: cpo_qty_converted {
    type: number
    sql: ${TABLE}."CPO_QTY_CONVERTED" ;;
  }

  dimension: cpo_qty_remaining {
    type: number
    sql: ${TABLE}."CPO_QTY_REMAINING" ;;
  }

  dimension: cpo_amount_requested {
    type: number
    sql: ${TABLE}."CPO_AMOUNT_REQUESTED" ;;
  }

  dimension: cpo_amount_converted {
    type: number
    sql: ${TABLE}."CPO_AMOUNT_CONVERTED" ;;
  }

  dimension: cpo_amount_remaining {
    type: number
    sql: ${TABLE}."CPO_AMOUNT_REMAINING" ;;
  }

  dimension: cponp_number {
    type: string
    sql: ${TABLE}."CPONP_NUMBER" ;;
  }

  dimension: cponp_state {
    type: string
    sql: ${TABLE}."CPONP_STATE" ;;
  }

  dimension_group: cponp_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CPONP_DATE_CREATED" ;;
  }

  dimension: cponp_qty_requested {
    type: number
    sql: ${TABLE}."CPONP_QTY_REQUESTED" ;;
  }

  dimension: cponp_qty_converted {
    type: number
    sql: ${TABLE}."CPONP_QTY_CONVERTED" ;;
  }

  dimension: cponp_qty_remaining {
    type: number
    sql: ${TABLE}."CPONP_QTY_REMAINING" ;;
  }

  dimension: cponp_amount_requested {
    type: number
    sql: ${TABLE}."CPONP_AMOUNT_REQUESTED" ;;
  }

  dimension: cponp_amount_converted {
    type: number
    sql: ${TABLE}."CPONP_AMOUNT_CONVERTED" ;;
  }

  dimension: cponp_amount_remaining {
    type: number
    sql: ${TABLE}."CPONP_AMOUNT_REMAINING" ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    link: {
      label: "URL T3"
      url: "{{ value }}"
    }
  }

  dimension: url_poe {
    type: string
    sql: ${TABLE}."URL_POE" ;;
    link: {
      label: "URL Poe"
      url: "{{ value }}"
    }
  }

  dimension: url_po {
    type: string
    sql: ${TABLE}."URL_PO" ;;
    link: {
      label: "URL Po"
      url: "{{ value }}"
    }
  }

  dimension: url_vi {
    type: string
    sql: ${TABLE}."URL_VI" ;;
    link: {
      label: "URL Vi"
      url: "{{ value }}"
    }
  }

  dimension: url_bill {
    type: string
    sql: ${TABLE}."URL_BILL" ;;
    link: {
      label: "URL Bill"
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
      pk_po_header_id,
      fk_t3_po_header_id,
      fk_t3_po_receipt_header_id,
      fk_poe_header_id,
      fk_vi_header_id,
      fk_ap_header_id,
      fk_cpo_header_id,
      fk_cponp_header_id,
      id_vendor,
      name_vendor,
      type_po,
      po_number,
      po_number_raw,
      poe_number,
      poe_state,
      poe_date_created_date,
      poe_qty_requested,
      poe_qty_converted,
      poe_qty_remaining,
      poe_amount_requested,
      poe_amount_converted,
      poe_amount_remaining,
      state_document,
      po_date_created_date,
      po_qty_requested,
      po_qty_converted,
      po_qty_remaining,
      po_amount_requested,
      po_amount_converted,
      po_amount_remaining,
      vi_number,
      vi_state,
      vi_date_created_date,
      vi_concur_image_id,
      vi_qty_requested,
      vi_qty_converted,
      vi_qty_remaining,
      vi_amount_requested,
      vi_amount_converted,
      vi_amount_remaining,
      bill_number,
      bill_state,
      bill_date_created_date,
      bill_date_paid_date,
      bill_amount,
      bill_amount_paid,
      cpo_number,
      cpo_state,
      cpo_date_created_date,
      cpo_qty_requested,
      cpo_qty_converted,
      cpo_qty_remaining,
      cpo_amount_requested,
      cpo_amount_converted,
      cpo_amount_remaining,
      cponp_number,
      cponp_state,
      cponp_date_created_date,
      cponp_qty_requested,
      cponp_qty_converted,
      cponp_qty_remaining,
      cponp_amount_requested,
      cponp_amount_converted,
      cponp_amount_remaining,
      url_t3,
      url_poe,
      url_po,
      url_vi,
      url_bill,
      url_cpo,
      url_cponp,
      url_bill_pdf,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_bill_amount {
    type: sum
    sql: ${TABLE}."BILL_AMOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
