view: ap_accrual_bill_to_receipt {
  derived_table: {
    sql:
select * from analytics.procure_2_pay.ap_accrual_bill_to_receipt


      ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: terms {type: string sql: ${TABLE}."TERMS" ;;}
  dimension: ALT_PAY_DUE_DATE_DEDUCTION {type: string sql: ${TABLE}."ALT_PAY_DUE_DATE_DEDUCTION" ;;}
  dimension: pay_method {type: string sql: ${TABLE}."PAY_METHOD" ;;}
  dimension: bill_number {type: string sql: ${TABLE}."BILL_NUMBER" ;;}
  dimension: bill_date {convert_tz: no type: date sql: ${TABLE}."BILL_DATE" ;;}
  dimension: post_date {convert_tz: no type: date sql: ${TABLE}."POST_DATE" ;;}
  dimension: due_date {convert_tz: no type: date sql: ${TABLE}."DUE_DATE" ;;}
  dimension: po_or_reference {type: string sql: ${TABLE}."PO_OR_REFERENCE" ;;}
  dimension: state {type: string sql: ${TABLE}."STATE" ;;}
  dimension: header_description {type: string sql: ${TABLE}."HEADER_DESCRIPTION" ;;}
  dimension: url {
    type: string
    sql: ${TABLE}.URL ;;
    html: <a href='{{ value }}' target='_blank' style='color: blue'>{{ value }}</a>
      ;;
  }
  dimension: asset_id {type: string sql: ${TABLE}.asset_id;;}

  dimension: line {type: number sql: ${TABLE}."LINE" ;;}
  dimension: item_id {type: string sql: ${TABLE}."ITEM_ID" ;;}
  dimension: account_shown {type: string sql: ${TABLE}."ACCOUNT_SHOWN" ;;}
  dimension: account_number {type: string sql: ${TABLE}."ACCOUNT_NUMBER" ;;}
  dimension: dept_id {type: string sql: ${TABLE}."DEPT_ID" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  dimension: expense_line {type: string sql: ${TABLE}."EXPENSE_LINE" ;;}
  dimension: amount {type: number sql: ${TABLE}."AMOUNT" ;; value_format: "$#,##0.00"}
  dimension: line_description {type: string sql: ${TABLE}."LINE_DESCRIPTION" ;;}
  dimension: vi_number {type: string sql: ${TABLE}."VI_NUMBER" ;;}
  dimension: vi_line_no {type: number sql: ${TABLE}."VI_LINE_NO" ;;}
  dimension: vi_qty {type: number sql: ${TABLE}."VI_QTY" ;;}
  dimension: vi_unit_price {type: number sql: ${TABLE}."VI_UNIT_PRICE" ;;}
  dimension: vi_ext_cost {type: number sql: ${TABLE}."VI_EXT_COST" ;;}
  dimension: po_number {type: string sql: ${TABLE}."PO_NUMBER" ;;}
  dimension: po_line_no {type: number sql: ${TABLE}."PO_LINE_NO" ;;}
  dimension: po_qty {type: number sql: ${TABLE}."PO_QTY" ;;}
  dimension: po_unit_price {type: number sql: ${TABLE}."PO_UNIT_PRICE" ;;}
  dimension: po_ext_cost {type: number sql: ${TABLE}."PO_EXT_COST" ;;}
  dimension: rec_journal {type: string sql: ${TABLE}."REC_JOURNAL" ;;}
  dimension: rec_module {type: string sql: ${TABLE}."REC_MODULE" ;;}
  dimension: rec_batch_no {type: number sql: ${TABLE}."REC_BATCH_NO" ;;}
  dimension: receipt_date {type: string sql: ${TABLE}."RECEIPT_DATE" ;;}
  dimension: date_fully_paid {type: date sql: ${TABLE}."DATE_FULLY_PAID" ;;}
  dimension: summary {type: string sql: ${TABLE}."SUMMARY" ;;}
  dimension: created_by {type: string sql: ${TABLE}."CREATED_BY" ;;}
  dimension: when_modified {type: string sql: ${TABLE}."WHEN_MODIFIED" ;;}
  dimension: place_this_bill_on_hold {type: string sql: ${TABLE}."PLACE_THIS_BILL_ON_HOLD" ;;}
  dimension: vendor_due {type: number sql: ${TABLE}."VENDOR_DUE" ;; value_format: "$#,##0.00"}
  dimension: total_due {type: number sql: ${TABLE}."TOTAL_DUE" ;; value_format: "$#,##0.00"}
  dimension: total_paid {type: number sql: ${TABLE}."TOTAL_PAID" ;;}
  dimension: record_no {type: string sql: ${TABLE}."RECORD_NO" ;;}
  dimension: created_at_entity_name {type: string sql: ${TABLE}."CREATED_AT_ENTITY_NAME" ;;}
  dimension: account_name {type: string sql: ${TABLE}."ACCOUNT_NAME" ;;}
  dimension: department_name {type: string sql: ${TABLE}."DEPARTMENT_NAME" ;;}
  dimension: attachment {type: string sql: ${TABLE}."ATTACHMENT" ;;}
  # measure: sum_distinct_amount {type: sum_distinct sql: ${TABLE}."AMOUNT" ;;}

  dimension: url_invoice {type: string sql: ${TABLE}."URL_INVOICE" ;;}

  # dimension: sage_link {
  #   type: string sql: ${TABLE}."URL_INVOICE"
  #     link: {
  #       label: "label"  # The URL will be displayed as the text

  #       url: "{{url_invoice}}"    # The same URL will be used as the link destination
  #     }
  #   ;;}


  dimension: sage_link {
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
    html: <a href='{{ value }}' target='_blank' style='color: blue;'>{{ value }}</a>
      ;;
  }
  dimension: us_state_abrev {
    type: string sql: ${TABLE}.us_state_abrev ;;
    label: "US State Abrev"
    }

  set: detail {
    fields: [
        vendor_id,
        vendor_name,
        terms,
        pay_method,
        bill_number,
        bill_date,
        post_date,
        due_date,
        date_fully_paid,
        po_or_reference,
        state,
        header_description,
        url,
        line,
        item_id,
        account_shown,
        account_number,
        dept_id,
        entity,
        expense_line,
        line_description,
        amount,
        vi_number,
        vi_line_no,
        vi_qty,
        vi_unit_price,
        vi_ext_cost,
        po_number,
        po_line_no,
        po_qty,
        po_unit_price,
        po_ext_cost,
        rec_journal,
        rec_module,
        rec_batch_no,
        ALT_PAY_DUE_DATE_DEDUCTION,
        us_state_abrev,
        asset_id
    ]
  }
}
