connection: "es_snowflake_analytics"

include: "/views/BUSINESS_INTELLIGENCE/*.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/*.view.lkml"
include: "/national_accounts/national_account_companies.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ES_WAREHOUSE/rentals_solo.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/rental_protection_plans.view.lkml"

datagroup: fact_company_customer_start_update {
  sql_trigger: select max(_updated_recordtimestamp) from business_intelligence.gold.fact_company_customer_start ;;
  max_cache_age: "8 hours"
  description: "Looking at business_intelligence.gold.fact_company_customer_start to get most recent update."
}

explore: fact_company_customer_start {
  label: "Rental Salesperson - New Account Report"
  case_sensitive: no
  persist_with: fact_company_customer_start_update
  sql_always_where:
           (( {{ _user_attributes['job_role'] }} = 'tam' AND '{{ _user_attributes['email'] }}' = ${salesperson_permissions.employee_email})
        OR contains(${salesperson_permissions.manager_access_emails}, '{{ _user_attributes['email'] }}')
        OR {{ _user_attributes['job_role'] }} = 'developer'
        OR {{ _user_attributes['job_role'] }} = 'hrbp'
        OR {{ _user_attributes['job_role'] }} = 'leadership'
        OR {{ _user_attributes['job_role'] }} = 'legal'
        OR ('bobbi.malone@equipmentshare.com' = '{{ _user_attributes['email'] }}' )
        OR ('jay.mitchell@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('kate.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}')
        OR ('mandy.peters@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('5-8', '5-4') OR (${salesperson_permissions.region_name_dated} IN ('Southeast') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('victor.otalora@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('2-3') OR (${salesperson_permissions.region_name_dated} IN ('Mountain West') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mj.mason@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR ('mike.k.smith@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions')))) -- requested by kyle stout in help looker
        OR ('kyle.stout@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.district_dated} IN ('1-4') OR (${salesperson_permissions.region_name_dated} IN ('Pacific') and ${salesperson_permissions.business_segment} IN ('Advanced Solutions'))))
        OR
          (case
            when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'karen.hubbard@equipmentshare.com')
            when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'zach@equipmentshare.com')
            when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'arianna.olson@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions.manager_access_emails}, 'brian.kniffen@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'mike.galvan@equipmentshare.com' = '{{ _user_attributes['email'] }}' and ${salesperson_permissions.region_name_dated} = 2 then contains(${salesperson_permissions.manager_access_emails},'justin.ingold@equipmentshare.com')
            when 'conner.bradley@equipmentshare.com' = '{{ _user_attributes['email'] }}' AND (${salesperson_permissions.employee_id} IN ('3102', '3654', '12795', '18434', '10321', '14194', '4275', '18691', '13644', '3644', '18880')) then contains(${salesperson_permissions.manager_access_emails},'toby.fischer@equipmentshare.com') OR contains(${salesperson_permissions.manager_access_emails},'kyle.stout@equipmentshare.com')
            END))


    ;;

  join: new_account_date {
    from: v_dim_dates_bi
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.first_account_date_ct_key} = ${new_account_date.date_key} ;;
  }

  join: dim_companies_bi {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_company_customer_start.company_key} = ${dim_companies_bi.company_key} ;;
  }

  join: dim_users_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.salesperson_user_key} = ${dim_users_bi.user_key} ;;
  }

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.salesperson_user_key} = ${salesperson_permissions.user_key} ;;
  }

  join: dim_salesperson_enhanced_historical {
    from: dim_salesperson_enhanced
    view_label: "Historical Salesperson Info"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_company_customer_start.salesperson_key} = ${dim_salesperson_enhanced_historical.salesperson_key} ;;
  }

  join: market_region_xwalk_historical {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on:  ${dim_salesperson_enhanced_historical.market_id_hist} = ${market_region_xwalk_historical.market_id} ;;
  }




}
