connection: "snowflake_quotes"

# connection: "es_snowflake"

include: "/views/*.view.lkml"
include: "/weekly_quotes_summary/*.view.lkml"
include: "/views/quotes_dashboard/*.view.lkml"

explore: quotes  {
  group_label: "Quotes"
  label: "Quotes"

  from: quote


  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${quotes.branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }
}

# commenting out unused explore 5/22/24
# explore: salesrep_first_quote_location  {
#   group_label: "Quotes"
#   label: "Sales Rep First Quote Location"
# }


explore: weekly_ad_hoc_quotes  {
  group_label: "Quotes"
  label: "Weekly Ad Hoc Query"
  case_sensitive: no
}


explore: testing_quotes {
  group_label: "Quotes Dashboard"
  label: "Quote Dashboard Info"


  join: stg_t3__national_account_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${stg_t3__national_account_assignments.company_id} = ${testing_quotes.company_id} ;;
  }
}

explore: quote_high_level {
  group_label: "Quotes Dashboard"
  label: "Quotes High Level"
}

explore: before_after_esmax {}

explore: prior_vs_this_year_esmax {}

explore: total_orders_vs_esmax_orders {}

explore: conversion_rate_testing {}

explore: cancelled_rentals { group_label: "Quotes Dashboard"}

explore: cancelled_rentals_incl_unquoted { group_label: "Quotes Dashboard"

  join: stg_t3__national_account_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${stg_t3__national_account_assignments.company_id} = ${cancelled_rentals_incl_unquoted.company_id} ;;
  }

  }

explore: escalations {
  group_label: "Quotes Dashboard"
  label: "Quote Escalation Info"

  join: stg_t3__national_account_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${stg_t3__national_account_assignments.company_id} = ${escalations.company_id} ;;
  }
}

include: "/views/platform/*.view.lkml"
include: "/views/business_intelligence/*.view.lkml"

datagroup: quote_update {
  sql_trigger: select max(_updated_recordtimestamp)
    from business_intelligence.gold.v_fact_quotes;;
  max_cache_age: "24 hours"
  description: "Looking at business_intelligence.gold.v_fact_quotes to get most recent update."
}

include: "/views/orders.view.lkml"
include: "/views/rentals.view.lkml"
include: "/views/guarantees_commissions_status.view.lkml"
include: "/views/orders_from_quotes.view.lkml"

explore: fact_quotes {
  label: "Quote Details"
  persist_with: quote_update
  case_sensitive: no

  join: dim_quotes {
    type: inner
    view_label: "Quote Attributes"
    relationship: many_to_one
    sql_on: ${fact_quotes.quote_key} = ${dim_quotes.quote_key} ;;
  }

  join: quote_created_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Created Date"
    relationship: many_to_one
    sql_on: ${fact_quotes.created_date_key} = ${quote_created_date.date_key};;
  }

  join: quote_updated_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Updated Date"
    relationship: many_to_one
    sql_on: ${fact_quotes.updated_date_key} = ${quote_updated_date.date_key};;
  }

  join: quote_customers {
    from: dim_quote_customers
    type: inner
    view_label: "Quote Cusomer Attributes"
    relationship: many_to_one
    sql_on: ${fact_quotes.quote_customer_key} = ${quote_customers.quote_customer_key};;
  }

  join: dim_markets {
    view_label: "Market Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.market_key} = ${dim_markets.market_key} ;;
  }

  join: quote_contact_user {
    from: dim_users_bi
    view_label: "Quote Contact User Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.quote_contact_user_key} = ${quote_contact_user.user_key} ;;
  }

  join: dim_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${quote_contact_user.user_company_key} = ${dim_companies.company_key} ;;
  }

  join: converted_to_order_by_user {
    from: dim_users_bi
    view_label: "Converted to Order By User Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.converted_to_order_by_user_key} = ${converted_to_order_by_user.user_key} ;;
  }

  join: bridge_quote_salesperson {
    view_label: "Quote Salesperson Type"
    type: inner
    relationship: one_to_many
    sql_on: ${fact_quotes.quote_key} = ${bridge_quote_salesperson.quote_key} ;;
  }

  join: salesperson {
    from: dim_users_bi
    view_label: "Quote Salesperson"
    type: inner
    relationship: many_to_one
    sql_on: ${bridge_quote_salesperson.salesperson_user_key} = ${salesperson.user_key} ;;
  }

  join: guarantees_commissions_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson.user_id} = ${guarantees_commissions_status.salesperson_user_id} ;;
  }

  join: dim_orders {
    view_label: "Order Attributes"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_quotes.order_key} = ${dim_orders.order_key} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_orders.order_id} = ${orders.order_id} ;;
  }

  join: orders_from_quotes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_quotes.quote_key} = ${orders_from_quotes.quote_key} ;;
  }

  join: fact_quote_line_items {
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.quote_key} = ${fact_quote_line_items.quote_key} ;;
  }

  join: dim_equipment_classes {
    view_label: "Equipment Class Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.equipment_class_key} = ${dim_equipment_classes.equipment_class_key} ;;
  }

  join: requested_start_date {
    view_label: "Requested Start Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.requested_start_date_key} = ${requested_start_date.date_key} ;;
  }

  join: requested_start_time {
    view_label: "Requested Start Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.requested_start_time_key} = ${requested_start_time.time_key} ;;
  }

  join: requested_end_date {
    view_label: "Requested End Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.requested_end_date_key} = ${requested_end_date.date_key} ;;
  }

  join: requested_end_time {
    view_label: "Requested End Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.requested_end_time_key} = ${requested_end_time.time_key} ;;
  }

  join: expiration_date {
    view_label: "Expiration Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.expiration_date_key} = ${expiration_date.date_key} ;;
  }

  join: expiration_time {
    view_label: "Expiration Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.expiration_time_key} = ${expiration_time.time_key} ;;
  }

  # join: fact_quote_escalations {
  #   view_label: "Quote Escalations"
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${fact_quotes.quote_key} = ${fact_quote_escalations.quote_key} ;;
  # }

  # join: quote_escalated_date {
  #   from: dim_dates_bi
  #   view_label: "Quote Escalated Date"
  #   relationship: many_to_one
  #   sql_on: ${fact_quote_escalations.quote_escalated_date_key} = ${quote_escalated_date.date_key} ;;
  # }

  join: rentals {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_orders.order_id} = ${rentals.order_id} ;;
  }

  join: int_rental_floor_rate_analysis {
    view_label: "Rental Floor Rates"
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_id} = ${int_rental_floor_rate_analysis.rental_id} ;;
  }
}

explore: fact_quote_line_items {
  label: "Quote Line Item Details"
  persist_with: quote_update
  case_sensitive: no

  join: dim_quotes {
    view_label: "Quote Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.quote_key} = ${dim_quotes.quote_key} ;;
  }

  join: quote_line_item_created_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Line Item Created Date"
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.created_date_key} = ${quote_line_item_created_date.date_key};;
  }

  join: quote_customers {
    from: dim_quote_customers
    type: inner
    view_label: "Quote Customer Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.quote_customer_key} = ${quote_customers.quote_customer_key};;
  }

  join: quote_contact_user {
    from: dim_users_bi
    view_label: "Quote Contact User Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.quote_contact_user_key} = ${quote_contact_user.user_key} ;;
  }

  join: dim_markets {
    view_label: "Market Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.market_key} = ${dim_markets.market_key} ;;
  }

  join: dim_orders {
    view_label: "Order Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.order_key} = ${dim_orders.order_key} ;;
  }

  join: dim_parts {
    view_label: "Parts Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.part_key} = ${dim_parts.part_key} ;;
  }

  join: dim_equipment_classes {
    view_label: "Equipment Class Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.equipment_class_key} = ${dim_equipment_classes.equipment_class_key} ;;
  }

  join: requested_start_date {
    view_label: "Requested Start Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.requested_start_date_key} = ${requested_start_date.date_key} ;;
  }

  join: requested_start_time {
    view_label: "Requested Start Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.requested_start_time_key} = ${requested_start_time.time_key} ;;
  }

  join: requested_end_date {
    view_label: "Requested End Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.requested_end_date_key} = ${requested_end_date.date_key} ;;
  }

  join: requested_end_time {
    view_label: "Requested End Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.requested_end_time_key} = ${requested_end_time.time_key} ;;
  }

  join: expiration_date {
    view_label: "Expiration Date"
    from: dim_dates_bi
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.expiration_date_key} = ${expiration_date.date_key} ;;
  }

  join: expiration_time {
    view_label: "Expiration Time"
    from: dim_times
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quote_line_items.expiration_time_key} = ${expiration_time.time_key} ;;
  }
}

explore: fact_quote_escalations {
  label: "Quote Escalation Details"
  persist_with: quote_update
  case_sensitive: no

  join: dim_quotes {
    type: inner
    view_label: "Quote Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_escalations.quote_key} = ${dim_quotes.quote_key} ;;
  }

  join: quote_created_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Created Date"
    relationship: many_to_one
    sql_on: ${fact_quote_escalations.quote_created_date_key} = ${quote_created_date.date_key};;
  }

  join: quote_escalated_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Escalated Date"
    relationship: many_to_one
    sql_on: ${fact_quote_escalations.quote_escalated_date_key} = ${quote_escalated_date.date_key};;
  }

  join: quote_customers {
    from: dim_quote_customers
    type: inner
    view_label: "Quote Customer Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_escalations.quote_customer_key} = ${quote_customers.quote_customer_key};;
  }

  join: escalated_by_user {
    from: dim_users_bi
    type: inner
    view_label: "Quote Escalated By User Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_escalations.escalated_by_user_key} = ${escalated_by_user.user_key};;
  }

  join: fact_quotes {
    type: inner
    relationship: one_to_one
    sql_on: ${fact_quotes.quote_key} = ${fact_quote_escalations.quote_key} ;;
  }

  join: orders_from_quotes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_quotes.quote_key} = ${orders_from_quotes.quote_key} ;;
  }

  join: dim_markets {
    view_label: "Market Attributes"
    type: inner
    relationship: many_to_one
    sql_on: ${fact_quotes.market_key} = ${dim_markets.market_key} ;;
  }
}

explore: fact_quote_customer_conversion {
  label: "Quote Customer Conversion Details"
  persist_with: quote_update
  case_sensitive: no

  join: dim_quotes {
    type: inner
    view_label: "Quote Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_customer_conversion.quote_key} = ${dim_quotes.quote_key} ;;
  }

  join: converted_date {
    from: dim_dates_bi
    type: inner
    view_label: "Quote Customer Converted Date"
    relationship: many_to_one
    sql_on: ${fact_quote_customer_conversion.converted_date_key} = ${converted_date.date_key};;
  }

  join: converted_time {
    from: dim_times
    type: inner
    view_label: "Quote Customer Converted Time"
    relationship: many_to_one
    sql_on: ${fact_quote_customer_conversion.converted_time_key} = ${converted_time.time_key};;
  }

  join: company {
    from: dim_companies
    type: inner
    view_label: "Converted to Company Attributes"
    relationship: many_to_one
    sql_on: ${fact_quote_customer_conversion.company_key} = ${company.company_key};;
  }
}

explore: salesperson_quotes {
  label: "Salesperson Quotes"
  extends: [fact_quotes]          # inherits all joins/sets/access filters
  from: fact_quotes            # defensive: prevents fallback to from:salesperson_invoices
  view_label: "Quote Details"
  view_name: fact_quotes
  persist_with: quote_update

  join: bridge_quote_salesperson {
    view_label: "Saleperson Type"
    type: inner
    sql_on: ${fact_quotes.quote_key} = ${bridge_quote_salesperson.quote_key} ;;
    relationship: many_to_one
  }

  join: dim_salesperson_enhanced {
    type: inner
    view_label: "Salesperson Attributes"
    sql_on: ${bridge_quote_salesperson.salesperson_key} = ${dim_salesperson_enhanced.salesperson_key} ;;
    relationship: many_to_one
  }

  join: salesperson_user {
    from: dim_users_bi
    view_label: "Salesperson User Attributes"
    type: inner
    sql_on: ${bridge_quote_salesperson.salesperson_user_key} = ${salesperson_user.user_key} ;;
    relationship: many_to_one
  }

  join: salesperson_employee {
    view_label: "Salesperson Employee Attributes"
    from: dim_employees_bi
    type: inner
    sql_on: ${salesperson_user.user_employee_key} = ${salesperson_employee.employee_key} ;;
    relationship: one_to_one
  }
}
