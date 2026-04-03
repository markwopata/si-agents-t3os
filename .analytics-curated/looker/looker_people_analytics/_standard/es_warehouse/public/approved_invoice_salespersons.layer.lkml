include: "/_base/es_warehouse/public/approved_invoice_salespersons.view.lkml"

view: +approved_invoice_salespersons {

  ############### DATES ###############
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
}
