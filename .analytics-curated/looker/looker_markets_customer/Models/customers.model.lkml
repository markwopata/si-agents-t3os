connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/ANALYTICS/company_region.view.lkml"
include: "/views/custom_sql/dormant_customer_accounts.view.lkml"
include: "/views/custom_sql/customer_activity_last_36_hours.view.lkml"
include: "/views/custom_sql/company_look_up_info.view.lkml"
include: "/views/custom_sql/company_salesperson_rank.view.lkml"
include: "/views/custom_sql/customer_activity_feed.view.lkml"
include: "/views/custom_sql/new_customers.view.lkml"
include: "/views/ANALYTICS/new_customers_rolling_90_days.view.lkml"
include: "/views/custom_sql/companies_revenue_by_month.view.lkml"
include: "/views/custom_sql/command_audit_create_company.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/company_notes.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/company_erp_refs.view.lkml"
include: "/views/GS/credit_app_master_list.view.lkml"
include: "/views/custom_sql/command_audit_create_company.view.lkml"
include: "/views/custom_sql/top_50_customers_by_revenue.view.lkml"
include: "/views/custom_sql/credit_specialist_onboarding.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/billing_contacts.view.lkml"
include: "/views/ES_WAREHOUSE/billing_company_preferences.view.lkml"
include: "/views/ES_WAREHOUSE/company_contracts.view.lkml"
include: "/views/custom_sql/customer_on_rent_rolling_90.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/custom_sql/legal_companies.view.lkml"
include: "/views/Business_Intelligence/stg_t3__on_rent.view.lkml"
include: "/location_permissions/location_permissions.view.lkml"
include: "/national_accounts/assigned_nam_to_company_mapping.view.lkml"
include: "/p66_ad_hoc/p66_rental_history.view.lkml"
include: "/p66_ad_hoc/p66_rental_asset_assignment.view.lkml"
include: "/views/Business_Intelligence/stg_t3__national_account_assignments.view.lkml"
include: "/views/Business_Intelligence/dim_companies_bi.view.lkml"

datagroup: t3_on_rent_source {
  sql_trigger: select max(data_refresh_timestamp) from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ON_RENT ;;
  max_cache_age: "2 hours"
  description: "Looking at business_intelligence.triage.stg_t3__on_rent to get most recent on rent update."
}


#Dormant Customers
explore: dormant_customer_accounts {
  group_label: "Company Info"
  label: "Dormant Customer Accounts"
  description: "Companies with no rental equal or over 120 days"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dormant_customer_accounts.market_name} = ${market_region_xwalk.market_name} ;;
  }

  join: company_salesperson_rank {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dormant_customer_accounts.company_id} = ${company_salesperson_rank.company_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dormant_customer_accounts.company_id} = ${companies.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_many
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: legal_companies {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dormant_customer_accounts.company_id} = ${legal_companies.company_id} ;;
  }
}

#Company Info - Customer Activity Last 36 Hours
explore: customer_activity_last_36_hours {
  group_label: "Company Info"
  label: "Customer Activity Last 36 Hours"
  description: "Gives on rent and off rent counts for last 36 hours on top of total units on rent"
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer_activity_last_36_hours.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

#Company Info - Company Look Up
explore: company_look_up_info {
  group_label: "Company Info"
  label: "Company Look Up"
  description: "Explore supplies info for the company look up tool"
  case_sensitive: no

  join: national_accounts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_look_up_info.company_id}=${national_accounts.company_id} ;;
  }

  join: billing_contacts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_look_up_info.company_id} = ${billing_contacts.company_id} ;;
  }

  join: billing_contact_user {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${billing_contacts.contact_user_id} = ${billing_contact_user.user_id} ;;
  }
}

#Company Info - Company Notes
explore: company_notes{
  label: "Company Notes"
  group_label: "Company Info"
  description: "Use this explore for pulling notes by company"
  case_sensitive: no

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${company_notes.company_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${company_notes.user_id} ;;
  }
}

#Company Info - Explore is used for customer ticker/activity feed
explore: customer_activity_feed {
  group_label: "Company Info"
  description: "Explore is used for customer ticker/activity feed"
  case_sensitive: no

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${customer_activity_feed.asset_id} ;;
  }

  join: markets {
    type: inner
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${assets.rental_branch_id} ;;
  }
}

# New Customer Metrics
explore: new_customers {
  group_label: "New Customer Information"
  label: "All New Customers"
  sql_always_where: (('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  '{{ _user_attributes['email'] }}' ) OR 'salesperson' != {{ _user_attributes['department'] }})
    OR (('collectors' = {{ _user_attributes['department'] }} OR 'developer' = {{ _user_attributes['department'] }} OR 'rental coordinators' = {{ _user_attributes['department'] }}) or ${market_region_xwalk.District_Region_Market_Access}) ;;

  join: market_region_xwalk {
    view_label: "Customer Market Region Xwalk"
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_customers.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_customers.salesperson_user_id} = ${users.user_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.employee_id} = ${company_directory.employee_id};;
  }

  join: sales_rep_market_region_xwalk {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${sales_rep_market_region_xwalk.market_id} ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_customers.company_id} = ${companies.company_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: company_owner{
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.owner_user_id} = ${company_owner.user_id} ;;
  }
}

#new_customers_rolling_90_days for 30 day conversion rate
explore: new_customers_rolling_90_days {
  group_label: "New Customer Information"
  label: "New Customers Rolling Ratio"
  sql_always_where: (('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  '{{ _user_attributes['email'] }}' ) OR 'salesperson' != {{ _user_attributes['department'] }});;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_customers_rolling_90_days.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${new_customers_rolling_90_days.salesperson_user_id} = ${users.user_id} ;;
  }
}

#Submit notes
explore: users {
  group_label: "Company Info"
  label: "Submit Notes"
  case_sensitive: no

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${national_account_companies.company_id} = ${companies.company_id} ;;
  }

  join: authorized_signer {
    from: users
    type: inner
    relationship: one_to_one
    sql_on: ${authorized_signer.user_id} = ${companies.authorized_signer_id} ;;
  }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  }

  join: states {
    sql_table_name: ES_WAREHOUSE.PUBLIC.STATES ;;
    type: left_outer
    relationship: one_to_one
    sql_on: ${locations.state_id} = ${states.state_id} ;;
  }

  join: billing_company_preferences {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${billing_company_preferences.company_id} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${dim_companies_bi.company_id} ;;
  }

}

explore: company_salesperson_rank {
  label: "Company Salesperson Rank"
  group_label: "Company Info"
  description: "Ranks the top salespeople for each company based off last invoice start date"
  case_sensitive: no

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_salesperson_rank.company_id} = ${invoices.company_id} and ${company_salesperson_rank.salesperson_user_id} = ${invoices.salesperson_user_id};;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }
}


#Company Info - Company Revenue by Month
explore: companies_revenue_by_month {
  label: "Company Revenue by Month"
  group_label: "Company Info"
  case_sensitive: no
  # sql_always_where: (('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  '{{ _user_attributes['email'] }}' ) OR 'salesperson' != {{ _user_attributes['department'] }});;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${companies_revenue_by_month.user_id} ;;
  }
}

# explore: credit_app_master_list {
#   label: "Credit Specialists"
#   group_label: "Company Info"
#   case_sensitive: no
#
#   join: command_audit_create_company {
#     type: full_outer
#     relationship: one_to_one
#     sql_on: ${command_audit_create_company.company_id}=${credit_app_master_list.customer_id} ;;
#   }
#
#   join: users {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.USERS ;;
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
#   }
#
#   join: markets {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.MARKETS ;;
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${credit_app_master_list.market_id} = ${markets.market_id} ;;
#   }
#
#   join: companies {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.COMPANIES ;;
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${command_audit_create_company.company_id}::TEXT=${companies.company_id}::TEXT ;;
#   }
# }

# explore: intacct_companies {
#   from: users
#   label: "Credit Specialist"
#
#     join: companies {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${intacct_companies.company_id}::INT = ${companies.company_id}::INT ;;
#     }
#
#     join: credit_app_master_list {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.company_id}::INT=${credit_app_master_list.customer_id}::INT ;;
#     }
#
#     join: net_terms {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
#     }
#
#     join: market_region_xwalk {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${credit_app_master_list.market_id} = ${market_region_xwalk.market_id} ;;
#     }
#
#     join: credit_app_master_list_sales_reps {
#       from: credit_app_master_list
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${intacct_companies.user_id}=${credit_app_master_list_sales_reps.salesperson_user_id} ;;
#     }
#
#     join: locations {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.billing_location_id}=${locations.location_id} ;;
#     }
#
#     join: states {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${locations.state_id}=${states.state_id} ;;
#     }
#
#     join: command_audit_create_company {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.company_id}=${command_audit_create_company.company_id} ;;
#     }
#
#     join: company_erp_refs {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.company_id}=${company_erp_refs.company_id} ;;
#     }
#
#     join: credit_specialist_onboarding {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${companies.company_id}=${credit_specialist_onboarding.company_id} ;;
#     }
#
#     join: users {
#       type: left_outer
#       relationship: one_to_one
#       sql_on: ${users.company_id}=${companies.company_id} ;;
#     }
#
#     join: orders {
#       type: left_outer
#       relationship: many_to_one
#       sql_on: ${orders.user_id}=${users.user_id} ;;
#     }
#   }

  explore: top_50_customers_by_revenue {
    always_join: [companies, market_region_xwalk, owners]
    join: companies {
      type: left_outer
      relationship: many_to_one
      sql_on: ${top_50_customers_by_revenue.company_id} = ${companies.company_id} ;;
    }

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${top_50_customers_by_revenue.branch_id} = ${market_region_xwalk.market_id} ;;
    }

    join: owners {
      from: users
      type: left_outer
      relationship: many_to_one
      sql_on: ${companies.owner_user_id} = ${owners.user_id} ;;
    }
  }

  explore: company_region {

    join: companies {
      type: inner
      relationship: one_to_one
      sql_on: ${company_region.company_id} = ${companies.company_id} ;;
    }
  }

# explore: invoices {
#   label: "Customer Retention and Satisfaction"
#   sql_always_where: ${line_items.line_item_type_id} IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 20, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 37, 43, 44, 46, 49, 50, 74, 80, 81, 84, 98, 99, 100, 101, 108, 109, 110, 111, 118, 120);;
#   case_sensitive: no
#
#   join: line_items {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id};;
#   }
#
#   join: line_item_types {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
#   }
#
#   join: new_customers {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${invoices.company_id} = ${new_customers.company_id} ;;
#   }
# }

explore: company_details {
  from: companies
  description: "Basic explore for searching company details. No filtering or custom SQL."
  case_sensitive: no

  join: billing_contacts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_details.company_id} = ${billing_contacts.company_id} ;;
  }

  join: billing_contact_users {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${billing_contacts.contact_user_id} = ${billing_contact_users.user_id} ;;
  }

  join: company_locations {
    from: locations
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_details.company_id} = ${company_locations.company_id} ;;
  }


  join: company_owner {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_details.owner_user_id} = ${company_owner.user_id} ;;
  }


}

# explore: company_contracts {
#   group_label: "Company"
#   label: "Company Contracts"
#   case_sensitive: no
#   # persist_for: "10 minutes"
#
#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_contracts.company_id} = ${companies.company_id} ;;
#   }
# }

explore: customer_on_rent_rolling_90 {}

explore: stg_t3__national_account_assignments {
  group_label: "National Accounts"
  label: "On Rent Report"
  case_sensitive: no
  persist_with: t3_on_rent_source

  join: stg_t3__on_rent {
    type: inner
    relationship: many_to_one
    sql_on: ${stg_t3__national_account_assignments.company_id} = ${stg_t3__on_rent.company_id} ;;
  }

  join: companies {
    type:  left_outer
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${stg_t3__on_rent.parent_company_id} ;;
  }
}

explore: p66_rental_history {
  group_label: "P66 Reporting"
  label: "P66 Rental History"
  case_sensitive: no

  join: p66_rental_asset_assignment {
    type:  inner
    relationship: one_to_many
    sql_on: ${p66_rental_history.rental_id} = ${p66_rental_asset_assignment.rental_id} ;;
  }

}
