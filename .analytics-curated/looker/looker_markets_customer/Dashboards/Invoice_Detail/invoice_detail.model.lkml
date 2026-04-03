connection: "es_snowflake_analytics"

include: "/Dashboards/Invoice_Detail/Views/*.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/credit_note_allocations.view.lkml"
include: "/Dashboards/Invoice_Detail/Views/credit_notes.view.lkml"
include: "/views/Business_Intelligence/stg_t3__national_account_assignments.view.lkml"

explore: invoice_detail {
  from: orders

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoice_detail.order_id} = ${invoices.order_id} ;;
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

  join: line_item_types {
    type: inner
    relationship: one_to_many
    sql_on: ${v_line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: credit_note_allocations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${credit_note_allocations.invoice_id} ;;
  }

  join: credit_notes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_note_allocations.credit_note_id} = ${credit_notes.credit_note_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoice_detail.order_id} = ${rentals.order_id} ;;
  }

  join: order_user {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${invoice_detail.user_id} = ${order_user.user_id} ;;
  }

  join: order_company {
    from: companies
    type: inner
    relationship: one_to_one
    sql_on: ${order_user.company_id} = ${order_company.company_id} ;;
  }

  join: stg_t3__national_account_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${order_company.company_id} = ${stg_t3__national_account_assignments.company_id} ;;
  }


}
