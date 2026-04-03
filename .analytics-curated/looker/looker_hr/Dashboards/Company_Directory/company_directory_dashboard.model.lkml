connection: "es_snowflake_analytics"

include: "/Dashboards/Company_Directory/views/company_directory.view.lkml"
include: "/Dashboards/Company_Directory/views/markets.view.lkml"
include: "/Dashboards/Company_Directory/views/market_region_xwalk.view.lkml"
include: "/Dashboards/Company_Directory/views/locations.view.lkml"

include: "/Dashboards/Company_Directory/views/users.view.lkml"
include: "/Dashboards/Company_Directory/views/phone_numbers.view.lkml"

datagroup: company_directory_data_update {
  sql_trigger: select max(_es_update_timestamp) from analytics.payroll.company_directory_vault ;;
  max_cache_age: "9 hours"
  description: "Looking at company directory data valut to grab most recent update."
}

explore: company_directory {
  case_sensitive: no
  sql_always_where:
  ${employee_status} = 'Active'
  and ${work_email} like '%equipmentshare.com%'
  and ${date_hired} <= CURRENT_DATE();;

  join: managers {
    from: company_directory
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.direct_manager_employee_id}=${managers.employee_id} ;;
  }

  join: manager_reports_to {
    from: company_directory
    type: left_outer
    relationship: one_to_one
    sql_on: ${managers.direct_manager_employee_id} = ${manager_reports_to.employee_id} ;;
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

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.location_id} = ${locations.location_id} ;;
  }

  join: webex_users {
    from: users
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.work_email} ILIKE ${webex_users.email} ;;
  }

  join: webex_phone_numbers {
    from: phone_numbers
    type: left_outer
    relationship: one_to_many
    sql_on:
    ${webex_users.user_id} = ${webex_phone_numbers.user_id};;
  }
}

explore: market_directory {
  from: market_region_xwalk
  case_sensitive: no
  persist_with: company_directory_data_update

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_directory.market_id} = ${markets.market_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.location_id} = ${locations.location_id} ;;
  }

  join: managers {
    from: company_directory
    type: left_outer
    relationship: one_to_one
    sql_on:
    ${market_directory.market_id} = ${managers.market_id}
    and ${managers.employee_status} = 'Active'
    and ${managers.employee_title} ilike 'General Manager%'
    and ${managers.date_hired} <= current_date()
    ;;
  }

  join: service_managers {
    from: company_directory
    type: left_outer
    relationship: one_to_one
    sql_on:
    ${market_directory.market_id} = ${service_managers.market_id}
    and ${service_managers.employee_status} = 'Active'
    and ${service_managers.employee_title} ilike 'Service Manager%'
    and ${service_managers.date_hired} <= current_date()
    ;;
  }
}
