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


datagroup: stg_t3_on_rent_data_update {
  sql_trigger: select max(data_refresh_timestamp) from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ON_RENT ;;
  max_cache_age: "8 hours"
  description: "Looking at STG_T3__ON_RENT to get most recent update."
}

explore: stg_t3__on_rent {
  label: "On Rent Report - Salesperson"
  case_sensitive: no
  persist_with: stg_t3_on_rent_data_update
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

  join: salesperson_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${stg_t3__on_rent.primary_salesperson_id} = ${salesperson_permissions.employee_user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__on_rent.company_id} = ${companies.company_id} ;;
  }

  join: national_account_companies {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${companies.company_id} = ${national_account_companies.company_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__on_rent.purchase_order_id} =  ${purchase_orders.purchase_order_id};;
  }

  join: rentals_solo {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__on_rent.rental_id} =  ${rentals_solo.rental_id};;
  }

  join: rental_protection_plans {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_solo.rental_protection_plan_id} =  ${rental_protection_plans.rental_protection_plan_id};;
  }



}
