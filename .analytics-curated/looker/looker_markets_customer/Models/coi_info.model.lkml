connection: "es_snowflake_c_analytics"

include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/company_document_types.view.lkml"
include: "/views/ES_WAREHOUSE/company_documents.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/companies_revenue_by_month.view.lkml"
include: "/views/custom_sql/company_salesperson_rank.view.lkml"
include: "/views/custom_sql/general_liability_expired_with_active_rental.view.lkml"
include: "/views/custom_sql/no_general_liability_actively_renting.view.lkml"
include: "/views/custom_sql/no_rental_floater_or_rpp_charge.view.lkml"
include: "/views/custom_sql/no_rental_floater_and_rpp_charges.view.lkml"
include: "/views/custom_sql/rpp_charged_last_90_days.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/customer_region.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"

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
#test commit


explore: company_documents {
  group_label: "Company Info"
  label: "COI Information"
  description: "Find void and coming due COI documents by company"
  sql_always_where:
  ${voided} = false AND ${company_document_type_id} IN (1,3,123456);;

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_documents.company_id} = ${companies.company_id} ;;
  }

  join: company_document_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_documents.company_document_type_id} = ${company_document_types.company_document_type_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.location_id} = ${companies.billing_location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${company_salesperson_rank.company_id} ;;
  }

  join: salesperson {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${salesperson.user_id} = ${company_salesperson_rank.sales_rep_rank_one_id} ;;
  }

  join: company_owner {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }

  join: general_liability_expired_with_active_rental {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${general_liability_expired_with_active_rental.company_id} ;;
  }

  join: customer_region {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_documents.company_id} = ${customer_region.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${national_account_companies.company_id} ;;
  }

}

explore: rpp_charged_last_90_days  {
  group_label: "Company Info"
  label: "RPP Charged Information Lat 90 Days"
  description: "Find how much comapnies got charged for RPP with active rentals based off the last 90 days"
  case_sensitive: no
}

explore: general_liability_expired_with_active_rental {
  group_label: "Company Info"
  label: "Expired Liability but Active Rental"
  description: "Find companies that have an active rental but general liablity is expired"
  case_sensitive: no

  join: companies_revenue_by_month {
    type: left_outer
    relationship: one_to_many
    sql_on: ${general_liability_expired_with_active_rental.company_id} = ${companies_revenue_by_month.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${general_liability_expired_with_active_rental.company_id} = ${companies.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: company_owner {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_one
    sql_on: ${general_liability_expired_with_active_rental.company_id} = ${company_salesperson_rank.company_id};;
  }

  join: customer_region {
    type: left_outer
    relationship: one_to_one
    sql_on: ${general_liability_expired_with_active_rental.company_id} = ${customer_region.company_id} ;;
  }

  join: salesperson {
    from: users
    type: left_outer
    relationship:one_to_one
    sql_on: ${company_salesperson_rank.sales_rep_rank_one_id}= ${salesperson.user_id};;
  }
}

explore: no_rental_floater_and_rpp_charges {
  group_label: "Company Info"
  label: "Expired Rental Floater and RPP Charges"
  description: "Find companies that have an expire rental floater and rpp charge information"
  case_sensitive: no

  join: companies_revenue_by_month {
    type: left_outer
    relationship: one_to_many
    sql_on: ${no_rental_floater_and_rpp_charges.company_id} = ${companies_revenue_by_month.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_and_rpp_charges.company_id} = ${companies.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: company_owner {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_and_rpp_charges.company_id} = ${company_salesperson_rank.company_id};;
  }

  join: customer_region {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_and_rpp_charges.company_id} = ${customer_region.company_id} ;;
  }

  join: salesperson {
    from: users
    type: left_outer
    relationship:one_to_one
    sql_on: ${company_salesperson_rank.sales_rep_rank_one_id}= ${salesperson.user_id};;
  }

}

explore: no_rental_floater_or_rpp_charge {
  group_label: "Company Info"
  label: "No Rental Floater and No RPP Charges"
  description: "Companies with no rental floater and no RPP charge"
  case_sensitive: no

  join: companies_revenue_by_month {
    type: left_outer
    relationship: one_to_many
    sql_on: ${no_rental_floater_or_rpp_charge.company_id} = ${companies_revenue_by_month.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_or_rpp_charge.company_id} = ${companies.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: company_owner {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_or_rpp_charge.company_id} = ${company_salesperson_rank.company_id};;
  }

  join: customer_region {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_rental_floater_or_rpp_charge.company_id} = ${customer_region.company_id} ;;
  }

  join: salesperson {
    from: users
    type: left_outer
    relationship:one_to_one
    sql_on: ${company_salesperson_rank.sales_rep_rank_one_id}= ${salesperson.user_id};;
  }


}

explore: no_general_liability_actively_renting {
  group_label: "Company Info"
  label: "No General Liability Ever and Actively Renting"
  description: "Companies with no general liability ever and actively renting"
  case_sensitive: no

  join: companies_revenue_by_month {
    type: left_outer
    relationship: one_to_many
    sql_on: ${no_general_liability_actively_renting.company_id} = ${companies_revenue_by_month.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_general_liability_actively_renting.company_id} = ${companies.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: company_owner {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_general_liability_actively_renting.company_id} = ${company_salesperson_rank.company_id};;
  }

  join: customer_region {
    type: left_outer
    relationship: one_to_one
    sql_on: ${no_general_liability_actively_renting.company_id} = ${customer_region.company_id} ;;
  }

  join: salesperson {
    from: users
    type: left_outer
    relationship:one_to_one
    sql_on: ${company_salesperson_rank.sales_rep_rank_one_id}= ${salesperson.user_id};;
  }

}

explore: orders {
  group_label: "Company Info"
  label: "RPP Charge Information History"
  description: "Find how much comapnies got charged for RPP"
  case_sensitive: no
  sql_always_where: ${line_items.line_item_type_id} = 9 ;;


  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.order_id} = ${orders.order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: line_item_types {
    type: inner
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
