connection: "es_snowflake_analytics"


# For more information, the Company Directory model has been documented in Notion here:
# https://www.notion.so/equipmentshare/Company-Directory-2337fb59dad04e9484ddb56fa96d8670


include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/custom_sql/managers_names.view.lkml"
include: "/views/ANALYTICS/ukg_cost_center_market_id_mapping.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/custom_sql/active_employee_orgchart.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/Dashboards/Company_Directory/views/phone_numbers.view.lkml"
include: "/Dashboards/Company_Directory/views/users.view.lkml"
include: "/views/custom_sql/company_directory_with_market_xwalk.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"

datagroup: company_directory_data_update {
  sql_trigger: select max(_es_update_timestamp) from analytics.payroll.company_directory_vault ;;
  max_cache_age: "9 hours"
  description: "Looking at company directory data valut to grab most recent update."
}


explore: active_employee_orgchart {}

explore: company_directory {
  case_sensitive: no
  sql_always_where:
  ${employee_status} not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
  and (${work_email} like '%equipmentshare.com%' or ${work_email} like '%forgeandbuild.com%')
  and ${date_hired2_raw} <= current_date ;;
  persist_with: company_directory_data_update

  join: managers_names {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.direct_manager_employee_id}=${managers_names.manager_id} ;;
  }

  join: manager_reports_to {
    from: company_directory
    type: left_outer
    relationship: one_to_one
    sql_on: ${managers_names.direct_manager_employee_id} = ${manager_reports_to.employee_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: webex_users {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.work_email} = ${webex_users.email} ;;
  }

  join: webex_phone_numbers {
    from: phone_numbers
    type: left_outer
    relationship: one_to_many
    sql_on: ${webex_users.user_id} = ${webex_phone_numbers.user_id} ;;
  }

  join: manager_directory {
    from: company_directory
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.direct_manager_employee_id} = ${manager_directory.employee_id} ;;
  }
}

explore: company_directory_with_market_xwalk {
  label: "Company Directory for Markets Region XWalk"

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory_with_market_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: manager_directory {
    from: company_directory_with_market_xwalk
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory_with_market_xwalk.direct_manager_employee_id} = ${manager_directory.employee_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_many
    sql_on: ${company_directory_with_market_xwalk.market_id} = ${transportation_assets.market_id} ;;
  }
}
