include: "/_standard/analytics/commission/commission_details.layer.lkml"
include: "/_standard/analytics/payroll/pay_periods.layer.lkml"
include: "/_standard/analytics/branch_earnings/parent_market.layer.lkml"
include: "/dashboards/commission_statement/salesperson_type_invoice.view.lkml"

view: +pay_periods {

  dimension: comm_batch_id {
    sql: concat('Comm allocations ',lpad(month(${paycheck}),2,'0'),'.',lpad(day(${paycheck}),2,'0'),'.',substr(year(${paycheck}),3,2)) ;;
  }
  dimension: parts_batch_id {
    sql: concat('Parts allocations ',lpad(month(${paycheck}),2,'0'),'.',lpad(day(${paycheck}),2,'0'),'.',substr(year(${paycheck}),3,2)) ;;
  }
  dimension: retail_batch_id {
    sql: concat('Retail Comm allocations ',lpad(month(${paycheck}),2,'0'),'.',lpad(day(${paycheck}),2,'0'),'.',substr(year(${paycheck}),3,2)) ;;
  }
  dimension: header_key {
    type: number
    sql:  1 ;;
  }
  dimension: rental_earning_code {
    type: string
    sql: 'Commissi' ;;
  }
  dimension: retail_earning_code {
    type: string
    sql: 'RSC' ;;
  }
  dimension: parts_earning_code {
    type: string
    sql: 'Parts' ;;
  }
  dimension: column_D {
    type: string
    sql: '' ;;
  }
  dimension: column_E {
    type: string
    sql: '' ;;
  }
  dimension: column_G {
    type: string
    sql: '' ;;
  }
  dimension: column_H {
    type: string
    sql: '' ;;
  }
  dimension: column_K {
    type: string
    sql: '' ;;
  }
  dimension: column_M {
    type: string
    sql: '' ;;
  }
  dimension: column_O {
    type: string
    sql: '' ;;
  }
  dimension: column_Q {
    type: string
    sql: '' ;;
  }
  dimension: column_R {
    type: string
    sql: '' ;;
  }
  dimension: column_S {
    type: string
    sql: '' ;;
  }
}


explore: commission_details {
  view_label: "Commission Details"
  label: "Commission Allocations"

  join: pay_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_details.payroll_paycheck_date} = ${pay_periods.paycheck_date} ;;
  }

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_details.parent_market_id} = ${parent_market.market_id}
      and ${commission_details.transaction_date} between ${parent_market.start_date} and ${parent_market.end_date} ;;
  }

  join: salesperson_type_invoice {
    type: left_outer
    relationship: one_to_many
    sql_on: ${commission_details.invoice_id} = ${salesperson_type_invoice.invoice_id} ;;
  }
}

# view: +salesperson_type_invoice {
#   view_label: "Salesperson Type by Invoice"



# }
