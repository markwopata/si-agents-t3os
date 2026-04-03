include: "/_base/es_warehouse/public/invoices.view.lkml"

view: +invoices {
  label: "Invoices"

  #################### DIMENSIONS ####################
  dimension: invoice_id {
    value_format_name: id
  }
  dimension: order_id {
    value_format_name: id
  }
  dimension: billing_approved_by_user_id {
    value_format_name: id
  }
  dimension: created_by_user_id {
    value_format_name: id
  }
  dimension: salesperson_user_id {
    value_format_name: id
  }
  dimension: purchase_order_id {
    value_format_name: id
  }
  dimension: company_id {
    value_format_name: id
  }
  dimension: tax_amount {
    value_format: "$#,##0.00"
  }
  dimension: rpp_amount {
    value_format: "$#,##0.00"
  }
  dimension: billed_amount {
    value_format: "$#,##0.00"
  }
  dimension: line_item_amount {
    value_format: "$#,##0.00"
  }
  dimension: owed_amount {
    value_format: "$#,##0.00"
  }
  dimension: rental_amount {
    value_format: "$#,##0.00"
  }


  #################### DATES ####################
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${_es_update_timestamp};;
  }
  dimension_group: billing_approved_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${billing_approved};;
  }
  dimension_group: due_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${due_date};;
  }
  dimension_group: end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${end_date};;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_created};;
  }
  dimension_group: start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${start_date};;
  }
  dimension_group: paid_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${paid_date};;
  }
  dimension_group: invoice_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${invoice_date};;
  }
  dimension_group: avalara_transaction_id_update_dt_tm {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${avalara_transaction_id_update_dt_tm};;
  }
  dimension_group: taxes_invalidated_dt_tm {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${taxes_invalidated_dt_tm};;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_updated};;
  }
}
