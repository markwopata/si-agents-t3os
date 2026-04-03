connection: "es_snowflake_analytics"

# include: "/views/ES_WAREHOUSE/users.view.lkml"
# include: "/views/ES_WAREHOUSE/companies.view.lkml"
# include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
# include: "/views/ES_WAREHOUSE/locations.view.lkml"
# include: "/views/ES_WAREHOUSE/states.view.lkml"
# include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
# include: "/views/ES_WAREHOUSE/orders.view.lkml"
# include: "/views/ES_WAREHOUSE/invoices.view.lkml"
# include: "/views/ES_WAREHOUSE/markets.view.lkml"
# include: "/views/ANALYTICS/collector_customer_assignments.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
# include: "/views/ANALYTICS/national_accounts.view.lkml"
# include: "/views/custom_sql/existing_companies_mapping_query.view.lkml"
# include: "/views/ANALYTICS/collector_mktassignments.view.lkml"
# include: "/views/ANALYTICS/national_accounts.view.lkml"
# include: "/views/ANALYTICS/prospects__notes__v3.view.lkml"
# include: "/views/ANALYTICS/prospects__mapping__v3.view.lkml"
# include: "/views/custom_sql/market_region_sales_manager.view.lkml"
# include: "/views/custom_sql/prospects_folders_v2.view.lkml"
# include: "/views/custom_sql/company_prospect_lookup_v2.view.lkml"
# include: "/views/custom_sql/company_by_market.view.lkml"
# include: "/views/custom_sql/prospect_notes_v4.view.lkml"
# include: "/views/ANALYTICS/prospects__mapping__v4.view.lkml"
# include: "/views/custom_sql/company_prospect_lookup_v4.view.lkml"
# include: "/views/custom_sql/prospects_company_lookup_info.view.lkml"
# include: "/views/custom_sql/existing_companies_mapping_v4.view.lkml"
# include: "/views/ANALYTICS/national_accounts.view.lkml"
# #include: "/views/ANALYTICS/sales_track_logins.view.lkml"
# include: "/views/ES_WAREHOUSE/sales_track_logins.view.lkml"
# include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
# include: "/views/custom_sql/market_region_salesperson_email.view.lkml"
# include: "/views/custom_sql/sales_rep_company_access_pl.view.lkml"
# include: "/views/ANALYTICS/crm__project__mapping__v4.view.lkml"
# include: "/views/custom_sql/company_prospects_actions.view.lkml"
# include: "/views/custom_sql/project_notes.view.lkml"
# include: "/views/custom_sql/projects_customers.view.lkml"
# include: "/views/custom_sql/recent_main_menu.view.lkml"
# include: "/views/custom_sql/company_prospect_actions_by_ee.view.lkml"
# include: "/views/custom_sql/company_prospects_actions.view.lkml"
# include: "/views/ANALYTICS/crm__prospects__merged__v4.view.lkml"
# include: "/views/ANALYTICS/crm__missed__rental__v4.view.lkml"

include: "/views/custom_sql/existing_companies_folders.view.lkml"


explore: existing_companies_folders {
  case_sensitive: no
  # persist_for: "2 minutes"
}


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


# explore: existing_companies_mapping_query {
#   case_sensitive: no
#   # persist_for: "2 minutes"
#   sql_always_where: ${market_region_salesperson_email.email_address} =  LOWER('{{ _user_attributes['email'] }}')  ;;

#   join: orders {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${existing_companies_mapping_query.user_id} = ${orders.salesperson_user_id} ;;
#   }

#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.order_id} = ${invoices.order_id} ;;
#   }

#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
#   }

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) = ${users.user_id} ;;
#   }

#   join: user_companies {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.user_id} = ${user_companies.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${user_companies.company_id} = ${companies.company_id} ;;
#   }

#   join: collector_customer_assignments {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
#   }

#   join: net_terms {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
#   }



#   join: own_companies {
#     from: companies
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${user_companies.company_id} = ${own_companies.company_id} ;;
#   }



#   join: sales_track_logins {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.market_id} = ${markets.market_id};;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders.market_id} = ${market_region_xwalk.market_id} ;;
#   }


#   join: national_accounts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
#   }

#   join: national_account_reps {
#     from: national_accounts
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
#   }

#   join: market_region_salesperson {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
#   }

#   join: market_region_salesperson_email {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.email_address} = ${market_region_salesperson_email.email_address} ;;
#   }

#   join: market_region_sales_manager {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
#   }

#   }

# explore: company_prospect_lookup_v2 { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "2 minutes"
#   #sql_always_where:  ${users.email_address} =  '{{ _user_attributes['email'] }}'  ;;

#   join: prospects__mapping__v3 {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_prospect_lookup_v2.company_prospect_id} = ${prospects__mapping__v3.prospect_id} ;;
#   }

#   join: company_by_market {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_prospect_lookup_v2.company_prospect_id} = ${company_by_market.m_company_id} ;;
#   }

#   join: national_accounts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${national_accounts.company_id_string} = ${company_prospect_lookup_v2.company_prospect_id} ;;
#   }

#   join: prospects_folders_v2 {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_prospect_lookup_v2.company_prospect_id} = ${prospects_folders_v2.prospect_id} ;;
#   }

#   join: prospects__notes__v3 {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_prospect_lookup_v2.company_prospect_id} = ${prospects__notes__v3.prospect_id} ;;
#   }

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.email_address} = ${prospects__mapping__v3.sales_representative_email_address} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.company_id} = ${users.company_id} ;;
#   }

#   join: net_terms {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${net_terms.net_terms_id} = ${companies.net_terms_id} ;;
#   }

# }

# explore: prospects_folders_v2 {
#   case_sensitive: no
#   # persist_for: "2 minutes"
#   sql_always_where:   ('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
#   OR
#   ('developer' = {{ _user_attributes['department'] }} OR 'collectors' = {{ _user_attributes['department'] }} OR 'god view' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }})
#   OR
#   ${market_region_salesperson.Salesperson_District_Region_Market_Access};;

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${prospects_folders_v2.sales_representative_email_address} = ${users.email_address} ;;
#   }

#   join: market_region_salesperson {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
#   }

#   join: market_region_sales_manager {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
#   }
#   }




  # explore: prospects__notes__v3 {
  #   case_sensitive: no
  #   persist_for: "2 minutes"

  #   join: prospects__mapping__v3 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${prospects__notes__v3.prospect_id} = ${prospects__mapping__v3.prospect_id} ;;
  #   }
  #   }

  # explore:project_notes {
  #   case_sensitive: no
  #   persist_for: "1 minutes"}


  # explore:projects_customers {
  #   case_sensitive: no
  #   persist_for: "1 minutes"}


  # explore:prospects_notes_v4 { --MB comment out 10-10-23 due to inactivity
  #   case_sensitive: no
  #   persist_for: "1 minutes"
  #   sql_always_where: ${prospects_notes_v4.note_created_by} = '{{ _user_attributes['email'] }}' ;;


  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.email_address} = ${prospects_notes_v4.note_created_by} ;;
  #   }

  #   join: market_region_salesperson {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  #   }

  #   join: market_region_sales_manager {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  #   }

  #   }

  # explore: prospects__mapping__v4 {
  #   case_sensitive: no
  #   persist_for: "1 minutes"
  #   sql_always_where: ${prospects__mapping__v4.sales_representative_email_address} = '{{ _user_attributes['email'] }}' ;;


  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.email_address} = ${prospects__mapping__v4.sales_representative_email_address} ;;
  #   }

  #   join: market_region_salesperson {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  #   }

  #   join: market_region_sales_manager {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  #   }
  # }

  # explore: crm__project__mapping__v4 {
  #   case_sensitive: no
  #   persist_for: "1 minutes"
  #   sql_always_where: ${crm__project__mapping__v4.sales_representative_email_address} = '{{ _user_attributes['email'] }}' ;;


  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.email_address} = ${crm__project__mapping__v4.sales_representative_email_address} ;;
  #   }

  #   join: market_region_salesperson {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  #   }

  #   join: market_region_sales_manager {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  #   }
  # }

  # explore: company_look_up_info { --MB comment out 10-10-23 due to inactivity
  #   case_sensitive: no
  #   persist_for: "1 minutes"


  #   join: existing_companies_mapping_query {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_look_up_info.company_id} = ${existing_companies_mapping_query.company_id} ;;
  #   }
  #   join: national_accounts {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${existing_companies_mapping_query.company_id} = ${national_accounts.company_id} ;;
  #   }

  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${national_accounts.user_id} = ${users.user_id} ;;
  #   }
  #   join: order_salespersons {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${order_salespersons.user_id} = ${users.user_id} ;;
  #   }
  #   join: sales_track_logins {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_look_up_info.company_id} = ${sales_track_logins.company_id} ;;
  #   }
  #   join: companies {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_look_up_info.company_id} = ${companies.company_id} ;;
  #   }
  #   join: locations {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  #     }
  #     join: states {
  #       type: left_outer
  #       relationship: many_to_one
  #       sql_on: ${locations.state_id} = ${states.state_id} ;;
  #   }
  #   join: orders {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${orders.user_id} = ${users.user_id} ;;
  #   }
  #   join: market_region_salesperson {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  #   }

  #   join: market_region_sales_manager {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${market_region_salesperson.salesperson_user_id} = ${market_region_sales_manager.salesperson_user_id} ;;
  #   }
  # }

  # explore: company_look_up_info_v4 {
  #   from:  company_look_up_info
  #   case_sensitive: no
  #   persist_for: "1 minutes"

  #   join: existing_companies_mapping_query_v4 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_look_up_info_v4.company_id} = ${existing_companies_mapping_query_v4.company_id} ;;
  #   }
  # }

  # explore: company_prospect_lookup_v4 {
  #   case_sensitive: no
  #   persist_for: "1 minutes"
  #   sql_always_where: ${crm__prospects__merged__v4.prospect_id} is null  ;;


  #   join: prospects__mapping__v3 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospect_lookup_v4.company_prospect_id} = ${prospects__mapping__v3.prospect_id} ;;
  #   }

  #   join: company_by_market {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospect_lookup_v4.company_prospect_id} = ${company_by_market.m_company_id} ;;
  #   }

  #   join: national_accounts {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${national_accounts.company_id_string} = ${company_prospect_lookup_v4.company_prospect_id} ;;
  #   }

  #   join: prospects_folders_v2 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospect_lookup_v4.company_prospect_id} = ${prospects_folders_v2.prospect_id} ;;
  #   }

  #   join: prospects__notes__v3 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospect_lookup_v4.company_prospect_id} = ${prospects__notes__v3.prospect_id} ;;
  #   }

  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${users.email_address} = ${prospects__mapping__v3.sales_representative_email_address} ;;
  #   }

  #   join: companies {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.company_id} = ${users.company_id} ;;
  #   }

  #   join: net_terms {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${net_terms.net_terms_id} = ${companies.net_terms_id} ;;
  #   }
  #   join: crm__prospects__merged__v4 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${crm__prospects__merged__v4.prospect_id} = ${company_prospect_lookup_v4.company_prospect_id} ;;
  #   }
  # }

#   explore: existing_companies_mapping_query_2 {
#     from:  existing_companies_mapping_query
#     case_sensitive: no
#     persist_for: "2 minutes"

# }


  # explore: company_prospects_actions {
  #   case_sensitive: no
  #   persist_for: "2 minutes"
  #   sql_always_where: ${crm__prospects__merged__v4.prospect_id} is null  ;;




  #   join: sales_track_logins {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospects_actions.company_prospect_project_id} = ${sales_track_logins.company_id_string} ;;
  #   }

  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospects_actions.email} = ${users.email_address} ;;
  #   }

  #   join: sales_rep_company_access_pl {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospects_actions.company_prospect_project_id} = ${sales_rep_company_access_pl.company_id_string} ;;
  #   }

  #   join: companies {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${company_prospects_actions.company_prospect_project_id} = ${companies.company_id} ;;
  #   }

  #   join: crm__prospects__merged__v4 {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${crm__prospects__merged__v4.prospect_id} = ${company_prospects_actions.company_prospect_project_id} ;;
  #   }



  #   }

  # explore: existing_companies_mapping_query_3 {
  # from: existing_companies_mapping_query
  #   case_sensitive: no
  #   persist_for: "2 minutes"



  #   join: sales_track_logins {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${existing_companies_mapping_query_3.company_id} = ${sales_track_logins.company_id} ;;
  #   }

  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${existing_companies_mapping_query_3.email_address} = ${users.email_address} ;;
  #   }

  #   join: companies {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${existing_companies_mapping_query_3.company_id} = ${companies.company_id} ;;
  #   }

  #   join: locations {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  #   }
  #   join: states {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${locations.state_id} = ${states.state_id} ;;    }

  #   join: sales_rep_company_access_pl {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.company_id} = ${sales_rep_company_access_pl.company_id} ;;
  #   }
  # }

#Company Info - Sales Rep Access to Companies

  # explore: sales_rep_access_prospects {
  #   from: orders
  #   label: "Sales Rep Access to Companies_Prospects"
  #   group_label: "Company Info"
  #   description: "Pulling companies that specific sales reps have done work with"
  #   case_sensitive: no




  #   join: invoices {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${sales_rep_access_prospects.order_id} = ${invoices.order_id} ;;
  #   }

  #   join: order_salespersons {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${sales_rep_access_prospects.order_id} = ${order_salespersons.order_id} ;;
  #   }

  #   join: users {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: coalesce(${order_salespersons.user_id},${sales_rep_access_prospects.salesperson_user_id}) = ${users.user_id} ;;
  #   }

  #   join: user_companies {
  #     from: users
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${sales_rep_access_prospects.user_id} = ${user_companies.user_id} ;;
  #   }

  #   join: market_region_xwalk {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${sales_rep_access_prospects.market_id} = ${market_region_xwalk.market_id} ;;
  #   }


  #   join: companies {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${user_companies.company_id} = ${companies.company_id} ;;
  #   }

  #   join: sales_track_logins {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  #   }

  #   join: existing_companies_mapping_query {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${existing_companies_mapping_query.company_id} = ${companies.company_id} ;;
  #   }

  #   join: locations {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.billing_location_id} = ${locations.location_id} ;;
  #   }
  #   join: states {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${locations.state_id} = ${states.state_id} ;;    }

  #   join: sales_rep_company_access_pl {
  #     type: left_outer
  #     relationship: many_to_one
  #     sql_on: ${companies.company_id} = ${sales_rep_company_access_pl.company_id} ;;
  #   }}

    # explore: recent_main_menu {
    #   case_sensitive: no
    #   persist_for: "1 minutes"
    #   sql_always_where: ${crm__prospects__merged__v4.prospect_id} is null ;;

    #   join: company_prospects_actions {
    #     type: left_outer
    #     relationship: many_to_one
    #     sql_on: ${recent_main_menu.id} = ${company_prospects_actions.company_prospect_project_id};;
    #   }

    #   join: sales_track_logins {
    #     type: left_outer
    #     relationship: many_to_one
    #     sql_on: ${recent_main_menu.id} = ${sales_track_logins.company_id_string} ;;
    #   }

    #   join: crm__prospects__merged__v4 {
    #     type: left_outer
    #     relationship: many_to_one
    #     sql_on: ${recent_main_menu.id} = ${crm__prospects__merged__v4.prospect_id} ;;
    #   }

    #   }

    # explore: crm__missed__rental__v4 {
    #   case_sensitive: no
    #   persist_for: "2 minutes"
    # }


    # explore: company_prospect_actions_by_ee {
    #   case_sensitive: no
    #   persist_for: "2 minutes"
    #   sql_always_where:   ('salesperson' = {{ _user_attributes['department'] }} AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
    #   OR
    #   ('developer' = {{ _user_attributes['department'] }} OR 'collectors' = {{ _user_attributes['department'] }} OR 'god view' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }});;

    #   join: users {
    #     type: left_outer
    #     relationship: many_to_one
    #     sql_on: ${users.email_address} = ${company_prospect_actions_by_ee.email};;
    #       }

    #     join: sales_track_logins {
    #       type: left_outer
    #       relationship: many_to_one
    #       sql_on: ${company_prospect_actions_by_ee.company_prospect_project_id} = ${sales_track_logins.company_id_string} ;;

    #   }

    #   join: recent_main_menu {
    #     type: left_outer
    #     relationship: many_to_one
    #     sql_on: ${recent_main_menu.id} = ${company_prospect_actions_by_ee.company_prospect_project_id} ;;

    #   }
    #   }
