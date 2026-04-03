connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/retail_quote_request_mapping.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_makes.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/custom_sql/salesperson_to_market.view.lkml"
include: "/views/custom_sql/market_region_sales_manager.view.lkml"
include: "/views/ANALYTICS/asset_nbv_all_owners.view.lkml"
include: "/views/ANALYTICS/asset_nbv.view.lkml"
include: "/views/ANALYTICS/asset_retail_tool_sales_reps.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/custom_sql/retail_sales_goals.view.lkml"
include: "/views/custom_sql/retail_salesperson_summary.view.lkml"
include: "/views/custom_sql/retail_salesperson_invoice_detail.view.lkml"
include: "/views/custom_sql/retail_salesperson_simple.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/salesperson_permissions.view.lkml"

# #Retail Salesperson - Retail Salesperson Information
explore: invoices {
  group_label: "Salesperson Information"
  label: "Retail Salesperson"
  description: "Use this explore to investigate information relating to the Retail Sales Team"
  case_sensitive: no
  persist_for: "1 hour"
  sql_always_where:
    (('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }}
  AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}') ))
  --AND ('salesperson' != {{ _user_attributes['department'] }})
  OR ('developer' = {{ _user_attributes['department'] }} OR 'god view' = {{ _user_attributes['department'] }} OR 'managers' = {{ _user_attributes['department'] }} )
  OR ${market_region_salesperson.Salesperson_District_Region_Market_Access};;


  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.order_id}=${orders.order_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.asset_id} = ${assets.asset_id} ;;
  }

    # join: asset_statuses {
    #   type:  left_outer
    #   relationship: one_to_one
    #   sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
    # }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: retail_quote_request_mapping {
    type: full_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id}=${retail_quote_request_mapping.asset_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets.equipment_model_id} =${equipment_models.equipment_model_id};;
  }

  join: equipment_makes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets.equipment_make_id} =${equipment_makes.equipment_make_id};;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${line_items.branch_id},${orders.market_id},${assets.rental_branch_id},${assets.inventory_branch_id}) = ${markets.market_id} ;;
#      sql_on: ${markets.market_id} = ${assets.rental_branch_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${invoices.salesperson_user_id}, ${orders.salesperson_user_id}) = ${users.user_id} ;;
  }

  # join: collector_mktassignments {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${collector_mktassignments.market_id} = ${markets.market_id} ;;
  # }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${customer.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${companies.company_id} ;;
  }

  # join: net_terms {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  # }

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

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  }

  join: credit_app_master_list {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  # join: rateachievement_points {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${orders.salesperson_user_id} = ${rateachievement_points.salesperson_user_id} and ${line_items.invoice_id} = ${rateachievement_points.invoice_id}  ;;
  # }

  join: salesperson_to_market {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${salesperson_to_market.salesperson_user_id} ;;
  }

  # join: collector_customer_assignments {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${companies.company_id}=${collector_customer_assignments.company_id} ;;
  # }

  join: asset_nbv_all_owners {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id}=${asset_nbv_all_owners.asset_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: try_to_number(${users.employee_id}) = ${company_directory.employee_id};;
  }

   }

    explore: retail_salesperson_simple {
      case_sensitive: no
      sql_always_where:
      ('{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email}
      OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
      OR {{ _user_attributes['job_role'] }} = 'developer'
      OR {{ _user_attributes['job_role'] }} = 'hrbp'
      OR {{ _user_attributes['job_role'] }} = 'leadership'
      OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
      OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR
      (case
      when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
      when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
      END))
      ;;

      join: salesperson_permissions {
        type: inner
        relationship: many_to_one
        sql_on: ${retail_salesperson_simple.user_id} = ${salesperson_permissions.employee_user_id} ;;
      }

    }

    explore: retail_salesperson_summary {
      case_sensitive: no
      sql_always_where:
      ('{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email}
      OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
      OR {{ _user_attributes['job_role'] }} = 'developer'
      OR {{ _user_attributes['job_role'] }} = 'hrbp'
      OR {{ _user_attributes['job_role'] }} = 'leadership'
      OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
      OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
      OR
      (case
      when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
      when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
      when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
      END))
      ;;

      join: salesperson_permissions {
        type: inner
        relationship: many_to_one
        sql_on: ${retail_salesperson_summary.user_id} = ${salesperson_permissions.employee_user_id} ;;
      }
    }
