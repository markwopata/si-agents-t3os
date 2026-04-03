connection: "es_snowflake_analytics"

include: "/Dashboards/Customer_Rebates/views/*.view.lkml"

include: "/views/ANALYTICS/customer_rebates.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"


include: "/views/ES_WAREHOUSE/companies.view.lkml"
# include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/billing_company_preferences.view.lkml"
# include: "/views/ANALYTICS/v_line_items.view.lkml"

# include: "/views/ES_WAREHOUSE/payment_applications.view.lkml"
# include: "/views/ES_WAREHOUSE/credit_note_allocations.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"

include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/company_rental_rates.view.lkml"
include: "/views/ES_WAREHOUSE/invoices_rebates.view.lkml"
include: "/views/ANALYTICS/rebate_amount_per_customer.view.lkml"

# for use with the Customer Rebate Dashboard
explore: customer_rebates{
  case_sensitive: no
  label: "Customer Rebates"
  description: "Use this explore for pulling customer rebate information"
  fields: [ALL_FIELDS*,
    -companies.company_name_with_net_terms
    ]

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${customer_rebates.customer_id} = ${companies.company_id} ;;
  }

  join: billing_company_preferences {
    type: left_outer
    relationship: one_to_one
    sql_on: ${billing_company_preferences.company_id} = ${companies.company_id} ;;
  }

  join: invoices_rebates {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices_rebates.company_id} = ${customer_rebates.customer_id};;
  }

  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices_rebates.order_id} = ${orders.order_id} ;;
  }

  join: user_companies {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${user_companies.user_id} ;;
  }

  # join: payment_applications {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${invoices.invoice_id}=${payment_applications.invoice_id} ;;
  #   sql_where: ${invoices.customer_rebate_pay_period} = 'Yes';;
  # }

  # join: credit_note_allocations {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${invoices.invoice_id}=${credit_note_allocations.invoice_id} ;;
  #   sql_where: ${invoices.customer_rebate_pay_period} = 'Yes' ;;
  # }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_line_items.branch_id} = ${markets.market_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: line_items_with_customer_rates {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices_rebates.invoice_id} = ${line_items_with_customer_rates.invoice_id} ;;
  }

  join: v_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${line_items_with_customer_rates.line_item_id} = ${v_line_items.line_item_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_line_items.rental_id} = ${rentals.rental_id};;
  }

  # join: company_rental_rates {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${invoices_rebates.company_id} = ${company_rental_rates.company_id}
  #   and ${rentals.equipment_class_id} = ${company_rental_rates.equipment_class_id}
  #   and ${invoices_rebates.billing_approved_time} >= ${company_rental_rates.date_created_time}
  #   and ${invoices_rebates.billing_approved_time} <= ${company_rental_rates.rate_end_date_time};;
  # }


  join: rebate_amount_per_customer {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer_rebates.customer_id} = ${rebate_amount_per_customer.customer_id}
          and ${customer_rebates.rebate_start_period_date} = ${rebate_amount_per_customer.rebate_start_period_date}
          and ${customer_rebates.rebate_end_period_date} = ${rebate_amount_per_customer.rebate_end_period_date} ;;
  }
  join: customer_rebates_line_item_details {


    type: left_outer
    relationship: one_to_one
    sql_on: ${v_line_items.line_item_id} = ${customer_rebates_line_item_details.line_item_id} ;;



  }
}
