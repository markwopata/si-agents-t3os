connection: "es_snowflake_analytics"

include: "/views/retail_salesperson/dealership_and_fleet_sales.view.lkml"
include: "/views/retail_salesperson/retail_sales_quote_detail.view.lkml"
include: "/views/retail_salesperson/retail_sales_asset_detail.view.lkml"
include: "/views/retail_salesperson/retail_sales_invoice_detail.view.lkml"
include: "/views/BUSINESS_INTELLIGENCE/v_dim_salesperson_enhanced.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/salesperson_permissions.view.lkml"
include: "/Dashboards/Market_Operations_1378/salesperson_permissions/salesperson_permissions_include_inactive.view.lkml"
include: "/views/ANALYTICS/v_market_t3_analytics.view.lkml"
include: "/views/PLATFORM/dim_invoices.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"


explore: retail_sales_quote_detail {
  label: "Retail Sales Quote Detail"
  case_sensitive: no
  symmetric_aggregates: yes
  description: "Central explore for analyzing retail sales quotes from the Retool retail quotes app
  https://equipmentshare.retool-hosted.com/app/retail-sales/quotes"

  sql_always_where:
  ('{{ _user_attributes['email'] }}' = ${salesperson_permissions_include_inactive.employee_email}
  OR contains(${salesperson_permissions_include_inactive.manager_access_emails}, '{{ _user_attributes['email'] }}')
  OR {{ _user_attributes['job_role'] }} = 'developer'
  OR {{ _user_attributes['job_role'] }} = 'hrbp'
  OR {{ _user_attributes['job_role'] }} = 'leadership'
  OR '{{ _user_attributes['email'] }}' in('jay.mitchell@equipmentshare.com',
                                          'bobbi.malone@equipmentshare.com',
                                          'william.woodruff@equipmentshare.com',
                                          'elijah.greenwell@equipmentshare.com',
                                          'brandy.cogdill@equipmentshare.com',
                                          'amanda.vollmering@equipmentshare.com',
                                          'kim.misher@equipmentshare.com',
                                          'alistair.tyrrell@equipmentshare.com',
                                          'lewis.hornsby@equipmentshare.com',
                                          'kim.johnson@equipmentshare.com',
                                          'sherri.miller@equipmentshare.com',
                                          'alyssa.quinlan@equipmentshare.com',
                                          'rosette.le@equipmentshare.com',
                                          'brayden.mcginnis@equipmentshare.com',
                                          'don.heaton@equipmentshare.com',
                                          'lorena.bonillavalle@equipmentshare.com')
  OR
  (case
  when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions_include_inactive.manager_access_emails},'karen.hubbard@equipmentshare.com')
  when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'justin.ingold@equipmentshare.com')
  END))
  ;;

  join: salesperson_permissions_include_inactive {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_quote_detail.salesperson_user_id} = ${salesperson_permissions_include_inactive.employee_user_id} ;;
  }

  join: retail_sales_asset_detail {
    type: left_outer
    relationship: one_to_many
    sql_on: ${retail_sales_quote_detail.quote_id} = ${retail_sales_asset_detail.quote_id} ;;
  }

  join: dim_invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${retail_sales_quote_detail.invoice_id} = ${dim_invoices.invoice_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_quote_detail.parent_market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: v_dim_salesperson_enhanced {
    type: full_outer
    relationship: many_to_one
    sql_on: ${retail_sales_quote_detail.salesperson_user_id} = ${v_dim_salesperson_enhanced.user_id}
      and ${v_dim_salesperson_enhanced._is_current} = true;;
  }
}

explore: retail_sales_asset_detail {
  label: "Retail Sales Asset Detail"
  case_sensitive: no

  sql_always_where:
  ('{{ _user_attributes['email'] }}' = ${salesperson_permissions_include_inactive.employee_email}
  OR contains(${salesperson_permissions_include_inactive.manager_access_emails}, '{{ _user_attributes['email'] }}')
  OR {{ _user_attributes['job_role'] }} = 'developer'
  OR {{ _user_attributes['job_role'] }} = 'hrbp'
  OR {{ _user_attributes['job_role'] }} = 'leadership'
  OR '{{ _user_attributes['email'] }}' in('jay.mitchell@equipmentshare.com',
                                          'bobbi.malone@equipmentshare.com',
                                          'william.woodruff@equipmentshare.com',
                                          'elijah.greenwell@equipmentshare.com',
                                          'brandy.cogdill@equipmentshare.com',
                                          'amanda.vollmering@equipmentshare.com',
                                          'kim.misher@equipmentshare.com',
                                          'alistair.tyrrell@equipmentshare.com',
                                          'lewis.hornsby@equipmentshare.com',
                                          'kim.johnson@equipmentshare.com',
                                          'sherri.miller@equipmentshare.com',
                                          'alyssa.quinlan@equipmentshare.com',
                                          'rosette.le@equipmentshare.com',
                                          'brayden.mcginnis@equipmentshare.com',
                                          'don.heaton@equipmentshare.com',
                                          'lorena.bonillavalle@equipmentshare.com')
  OR
  (case
  when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions_include_inactive.manager_access_emails},'karen.hubbard@equipmentshare.com')
  when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
  when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'justin.ingold@equipmentshare.com')
  END))
  ;;

  join: salesperson_permissions_include_inactive {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.salesperson_user_id} = ${salesperson_permissions_include_inactive.employee_user_id} ;;
  }

  join: retail_sales_quote_detail {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.quote_id} = ${retail_sales_quote_detail.quote_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.parent_market_id}::varchar = ${market_region_xwalk.market_id}::varchar ;;
  }

  join: v_dim_salesperson_enhanced {
    type: full_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.salesperson_user_id} = ${v_dim_salesperson_enhanced.user_id}
      and ${v_dim_salesperson_enhanced._is_current} = true;;
  }

  join: v_market_t3_analytics {
    type: left_outer
    relationship: many_to_one
    sql_on: ${retail_sales_asset_detail.parent_market_id}::varchar = ${v_market_t3_analytics.market_id}::varchar ;;
  }
}

explore: retail_sales_invoice_detail {
    label: "Retail Sales Invoice Detail"
    case_sensitive: no

}

explore: dealership_and_fleet_sales {
  label: "Dealership and Fleet Sales"
  case_sensitive: no

 sql_always_where:
   ('{{ _user_attributes['email'] }}' = ${salesperson_permissions_include_inactive.employee_email}
  OR contains(${salesperson_permissions_include_inactive.manager_access_emails}, '{{ _user_attributes['email'] }}')
   OR {{ _user_attributes['job_role'] }} = 'developer'
   OR {{ _user_attributes['job_role'] }} = 'hrbp'
   OR {{ _user_attributes['job_role'] }} = 'leadership'
   OR '{{ _user_attributes['email'] }}' in('jay.mitchell@equipmentshare.com',
                                           'bobbi.malone@equipmentshare.com',
                                           'william.woodruff@equipmentshare.com',
                                           'elijah.greenwell@equipmentshare.com',
                                           'brandy.cogdill@equipmentshare.com',
                                           'amanda.vollmering@equipmentshare.com',
                                           'kim.misher@equipmentshare.com',
                                           'alistair.tyrrell@equipmentshare.com',
                                           'lewis.hornsby@equipmentshare.com',
                                           'kim.johnson@equipmentshare.com',
                                           'sherri.miller@equipmentshare.com',
                                           'alyssa.quinlan@equipmentshare.com',
                                           'rosette.le@equipmentshare.com',
                                           'brayden.mcginnis@equipmentshare.com',
                                           'don.heaton@equipmentshare.com',
                                           'lorena.bonillavalle@equipmentshare.com')
   OR
   (case
   when 'laurenjo.stone@equipmentshare.com' = '{{ _user_attributes['email'] }}' then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
   when 'josh.helmstetler@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'josh.helmstetler@equipmentshare.com') OR contains(${salesperson_permissions_include_inactive.manager_access_emails},'karen.hubbard@equipmentshare.com')
   when 'web.bailey@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
   when 'kelly.adams@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'zach@equipmentshare.com')
   when 'brian.kniffen@equipmentshare.com' = '{{ _user_attributes['email'] }}'  then contains(${salesperson_permissions_include_inactive.manager_access_emails},'justin.ingold@equipmentshare.com')
   END))
   ;;

  join: salesperson_permissions_include_inactive {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dealership_and_fleet_sales.salesperson_id} = ${salesperson_permissions_include_inactive.employee_user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dealership_and_fleet_sales.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: v_dim_salesperson_enhanced {
    type: full_outer
    relationship: many_to_one
    sql_on: ${dealership_and_fleet_sales.salesperson_id} = ${v_dim_salesperson_enhanced.user_id}
      and ${v_dim_salesperson_enhanced._is_current} = true;;
  }
}
