connection: "es_snowflake_analytics"

include: "/regional_ranking/*.view.lkml"
include: "/location_permissions/location_permissions.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

map_layer: es_regions {
  file: "ES-US-Regions-TopoJSON.json"
  property_key: "Region"
}

datagroup: new_account_update {
  sql_trigger: select max(_update_timestamp) from analytics.bi_ops.new_account_by_type_log ;;
  max_cache_age: "2 hours"
  description: "Looking at analytics.bi_ops.new_account_by_type_log to get most recent update."
}




explore: regional_hierarchy_rental_history_comparison {
  group_label: "Regional/District Ranking"
  label: "Total Units on Rent and OEC by Region Hierarchy"
  case_sensitive: no
}

explore: regional_actively_renting_customers {
  group_label: "Regional/District Ranking"
  label: "Actively Renting Customers by Region Hierarchy"
  case_sensitive: no
}

explore: regional_hierarchy_bulk_history_comparison {
  group_label: "Regional/District Ranking"
  label: "Total Bulk on Rent and Cost by Region Hierarchy"
  case_sensitive: no

  sql_always_where:${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_bulk_history_comparison.market_id};;

  }
}

explore: regional_hierarchy_bulk_history_comparison_market {
  group_label: "Regional/District Ranking"
  label: "Total Bulk on Rent and Cost by Region Hierarchy - Market Highlighting"
  case_sensitive: no
  sql_always_where:${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_bulk_history_comparison_market.market_id};;
  }
}

explore: regional_hierarchy_bulk_history_comparison_district {
  group_label: "Regional/District Ranking"
  label: "Total Bulk on Rent and Cost by Region Hierarchy - District Highlighting"
  case_sensitive: no
  sql_always_where:${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_bulk_history_comparison_district.market_id};;
  }
}

explore: regional_hierarchy_inventory_status {
  group_label: "Regional/District Ranking"
  label: "Inventory Status Breakdown by Region Hierarchy"
  case_sensitive: no
}

explore: regional_hierarchy_rental_revenue {
  group_label: "Regional/District Ranking"
  label: "Rental Revenue by Region Hierarchy"
  case_sensitive: no
}

explore: location_filter {
  group_label: "Regional/District Ranking"
  label: "Location Hierarchy"
  case_sensitive: no
  persist_for: "10 hours"
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${location_filter.market_id};;
  }

}

explore: region_hierarchy_new_accounts {
  group_label: "Regional/District Ranking"
  label: "New Accounts by Region Hierarchy"
  persist_with: new_account_update
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${region_hierarchy_new_accounts.market_id};;
  }
}

explore: region_hierarchy_new_account_market_highlighted {
  group_label: "Regional/District Ranking"
  label: "New Accounts by Region Hierarchy - Market Highlighted"
  persist_with: new_account_update
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${region_hierarchy_new_account_market_highlighted.market_id};;
  }
}

explore: region_hierarchy_new_account_district_highlighted {
  group_label: "Regional/District Ranking"
  label: "New Accounts by Region Hierarchy - District Highlighted"
  persist_with: new_account_update
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${region_hierarchy_new_account_district_highlighted.market_id};;
  }
}

explore: region_hierarchy_net_profit_margin {
  group_label: "Regional/District Ranking"
  label: "Profit Margin by Region Hierarchy"
  case_sensitive: no

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${region_hierarchy_net_profit_margin.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: region_hierarchy_financial_utilization {
  group_label: "Regional/District Ranking"
  label: "Financial Utilization by Region Hierarchy"
  case_sensitive: no
}

explore: region_hierarchy_discount {
  group_label: "Regional/District Ranking"
  label: "Discount by Region Hierarchy"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${region_hierarchy_discount.market_id};;
  }
}

explore: region_hierarchy_time_ute {
  group_label: "Regional/District Ranking"
  label: "Time Utilizaiton by Region Hierarchy"
  case_sensitive: no
}

explore: regional_hierarchy_monthly_oec {
  group_label: "Regional/District Ranking"
  label: "Monthly OEC by Region Hierarchy"
  case_sensitive: no
}

explore: regional_hierarchy_historical_rental_rev  {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Monthly Historical Rental Revenue"
  case_sensitive: no
}



explore: regional_hierarchy_new_accounts_history {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Historical New Accounts by Region Hierarchy"
  persist_with: new_account_update
  case_sensitive: no

  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_new_accounts_history.market_id};;
  }
}


explore: regional_hierarchy_new_accounts_history_market_highlighted {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Historical New Accounts by Region Hierarchy - Market Highlighted"
  case_sensitive: no
  persist_with: new_account_update
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_new_accounts_history_market_highlighted.market_id};;
  }
}

explore: regional_hierarchy_new_accounts_history_district_highlighted {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Historical New Accounts by Region Hierarchy - District Highlighted"
  case_sensitive: no
  persist_with: new_account_update
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${regional_hierarchy_new_accounts_history_district_highlighted.market_id};;
  }
}
