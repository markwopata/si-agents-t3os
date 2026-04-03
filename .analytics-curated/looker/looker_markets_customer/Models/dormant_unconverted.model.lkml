connection: "es_snowflake_c_analytics"

include: "/views/ANALYTICS/dormant_unconverted_companies.view.lkml"
include: "/views/ANALYTICS/dormant_unconverted_quotes.view.lkml"
include: "/views/ANALYTICS/dormant_unconverted_market_map.view.lkml"
include: "/location_permissions/location_permissions.view.lkml"
include: "/views/ANALYTICS/user_district_pull.view.lkml"
# include: "/location_permissions/location_permissions.view.lkml"

datagroup: dormant_data_refresh {
  sql_trigger: select max(DATA_REFRESH_TIMESTAMP) from business_intelligence.triage.stg_bi__dormant_unconverted_companies ;;
  max_cache_age: "25 hours"
  description: "Clears cache and refreshes when data_refresh_timestamp is updated or current cache is older than 25 hours "
}

explore: dormant_unconverted_companies {
  group_label: "Dormant and Unconverted Companies"
  label: "Dormant and Unconverted"
  case_sensitive: no
  description: "View of dormant, inactive, and unconverted companies"
  persist_with: dormant_data_refresh


    join: dormant_unconverted_quotes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dormant_unconverted_companies.company_id} = ${dormant_unconverted_quotes.company_id};;
  }

  join: dormant_unconverted_market_map {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dormant_unconverted_companies.company_id} = ${dormant_unconverted_market_map.company_id};;
  }


  join: user_district_pull {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_district_pull.assigned_district} = ${dormant_unconverted_companies.closest_district} ;;
  }

  join: user_district_pull_district {
    from: user_district_pull
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_district_pull_market.assigned_district} = ${dormant_unconverted_companies.district};;
  }

  join: user_district_pull_market {
    from: user_district_pull
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_district_pull_market.assigned_district} = ${dormant_unconverted_market_map.district};;
  }



  }
