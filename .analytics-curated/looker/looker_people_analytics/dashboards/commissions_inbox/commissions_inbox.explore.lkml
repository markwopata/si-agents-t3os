connection: "es_snowflake_analytics"

include: "/_base/es_warehouse/public/invoices.view.lkml"
include: "/_base/es_warehouse/public/order_salespersons.view.lkml"
include: "/_base/es_warehouse/public/orders.view.lkml"
include: "/_base/es_warehouse/public/users.view.lkml"
include: "/_base/es_warehouse/public/companies.view.lkml"
include: "/_base/analytics/public/market_region_xwalk.view.lkml"
include: "/_base/analytics/public/v_line_items.view.lkml"

explore: invoice_detail {
  from: orders

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoice_detail.order_id} = ${invoices.order_id} ;;
  }

  join: order_salespersons {
    type: inner
    relationship: one_to_many
    sql_on: ${invoice_detail.order_id}= ${order_salespersons.order_id} ;;
  }

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${order_salespersons.user_id} = ${users.user_id};;
  }

  join: order_market {
    from: market_region_xwalk
    type: left_outer
    relationship: one_to_one
    sql_on: ${invoice_detail.market_id} = ${order_market.market_id} ;;
  }

  join: v_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${v_line_items.invoice_id} ;;
  }

  join: order_company {
    from: companies
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.company_id} = ${order_company.company_id} ;;
  }



}
