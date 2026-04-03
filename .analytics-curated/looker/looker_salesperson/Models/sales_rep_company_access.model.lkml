connection: "es_snowflake_c_analytics"

include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/credit_notes.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/payments.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
#include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/ES_WAREHOUSE/sales_track_logins.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/ar_monthly_outstandings.view.lkml"
include: "/views/ANALYTICS/ar_monthly_past_due.view.lkml"
include: "/views/ANALYTICS/ar_weekly_dso.view.lkml"
include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
include: "/views/ANALYTICS/collector_cust_flags.view.lkml"
include: "/views/ANALYTICS/rateachievement_points.view.lkml"
include: "/views/custom_sql/existing_companies_mapping_query.view.lkml"
include: "/views/custom_sql/credit_amount_summarized.view.lkml"
include: "/views/custom_sql/collectors_customer_flag_list.view.lkml"
include: "/views/custom_sql/market_region_sales_manager.view.lkml"
include: "/views/custom_sql/max_invoice_and_rental_id.view.lkml"
include: "/views/custom_sql/unapplied_payments_by_company.view.lkml"
include: "/views/ES_WAREHOUSE/company_keypad_codes.view.lkml"
include: "/views/ES_WAREHOUSE/keypad_codes.view.lkml"
include: "/views/custom_sql/dormant_customer_accounts.view.lkml"
include: "/views/ES_WAREHOUSE/company_documents.view.lkml"
include: "/views/ES_WAREHOUSE/company_document_types.view.lkml"
include: "/views/custom_sql/general_liability_expired_with_active_rental.view.lkml"
include: "/views/custom_sql/salesperson_company_activity_feed.view.lkml"
include: "/views/ANALYTICS/collector_remove_customers.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/custom_sql/active_renting_companies.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/dim_companies_bi.view.lkml"

# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }

#Company Info - Sales Rep Access to Companies
explore: sales_rep_access {
  from: orders
  label: "Sales Rep Access to Companies"
  group_label: "Company Info"
  description: "Pulling companies that specific sales reps have done work with"
  case_sensitive: no
  sql_always_where:(
  ('collectors' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'rental coordinators' = {{ _user_attributes['department'] }}
  OR 'telematics' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }})
  or ${market_region_xwalk.District_Region_Market_Access})
  OR ((('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}') )))
;;

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.order_id} = ${invoices.order_id} ;;
  }

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.order_id} = ${order_salespersons.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${sales_rep_access.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: user_companies {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.user_id} = ${user_companies.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_companies.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${national_account_companies.company_id} ;;
  }

  join: collector_cust_flags {
    type: left_outer
    relationship: one_to_one
    sql_on: TRIM(${companies.company_id}::text) =TRIM(${collector_cust_flags.customer_id}) ;;
  }

  join: collector_customer_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: items {
    from: max_invoice_and_rental_id
    type: left_outer
    relationship: many_to_one
    sql_on: ${items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: rentals {
    type:  left_outer
    relationship:  many_to_one
    sql_on: ${items.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }

  join: own_companies {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_companies.company_id} = ${own_companies.company_id} ;;
  }

  join: collector_mktassignments {
    view_label: "Collector Market Assignments"
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.market_id}::text = ${collector_mktassignments.market_id};;
  }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.market_id} = ${markets.market_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_rep_access.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: ar_weekly_dso {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_weekly_dso.market_id} = ${markets.market_id} ;;
  }

  join: ar_monthly_past_due {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_past_due.market_id} =  ${markets.market_id} ;;
  }

  join: ar_monthly_outstandings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ar_monthly_outstandings.market_id} =  ${markets.market_id} ;;
  }

  join: credit_notes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_notes.company_id} = ${companies.company_id} ;;
  }

  join: collectors_customer_flag_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${collectors_customer_flag_list.company_id} = ${companies.company_id} ;;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  }

  join: credit_amount_summarized {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_amount_summarized.company_id} = ${companies.company_id} ;;
  }

  join: rateachievement_points {
    type: left_outer
    relationship: many_to_many
    sql_on: ${rateachievement_points.salesperson_user_id} = ${sales_rep_access.salesperson_user_id}  ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  }

  join: market_region_sales_manager {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${users.employee_id}::number = ${company_directory.employee_id} ;;
  }

  join: salesperson_market_info {
    from: market_region_xwalk
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.market_id} = ${salesperson_market_info.market_id} ;;
  }

  join: existing_companies_mapping_query {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${existing_companies_mapping_query.company_id} ;;
  }

  join: company_keypad_codes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${company_keypad_codes.company_id} ;;
  }

  join: keypad_codes {
    type: inner
    relationship: one_to_one
    sql_on: ${company_keypad_codes.keypad_code_id} = ${keypad_codes.keypad_code_id} ;;
  }

  join: dormant_customer_accounts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${dormant_customer_accounts.company_id} ;;
  }

  join: company_documents {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${company_documents.company_id} ;;
  }

  join: company_document_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_documents.company_document_type_id} = ${company_document_types.company_document_type_id} ;;
  }

  join: general_liability_expired_with_active_rental {
    type: left_outer
    relationship: many_to_one
    sql_on: ${own_companies.company_id} = ${general_liability_expired_with_active_rental.company_id} ;;
  }

  join: salesperson_company_activity_feed {
    type: left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${salesperson_company_activity_feed.company_id} ;;
  }

  join: collector_remove_customers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${collector_remove_customers.customer_id} ;;
  }

  join: unapplied_payments_by_company {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${unapplied_payments_by_company.company_id} ;;
  }

  join: active_renting_companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${active_renting_companies.company_id} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${dim_companies_bi.company_id} ;;
  }
}
