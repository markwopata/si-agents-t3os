connection: "es_snowflake_analytics"

include: "/markets_dashboard/*.view.lkml"
include: "/markets_dashboard/actively_renting_customers_views/*.view.lkml"
include: "/markets_dashboard/revenue_views/*.view.lkml"
include: "/markets_dashboard/outside_hauling_po_no_delivery/*.view.lkml"
include: "/market_open_date.view.lkml"
include: "/location_permissions/location_permissions.view.lkml"

datagroup: revenue_gold_update {
  sql_trigger: select max(line_item_recordtimestamp) from platform.gold.v_line_items ;;
  max_cache_age: "12 hours"
  description: "Looking at platform.gold.v_line_items for Latest Update. Will update data when it detects a new update time."
}

datagroup: market_action_item_update {
  sql_trigger: select max(_update_timestamp) from analytics.bi_ops.market_action_items ;;
  max_cache_age: "3 hours"
  description: "Looking at the market action items table in bi ops for refresh time."
}

datagroup: total_month_oec{
  sql_trigger: select max(record_upload_timestamp) from analytics.bi_ops.asset_status_and_rsp_daily_snapshot ;;
  max_cache_age: "12 hours"
  description: "Looking at analytics.bi_ops.asset_status_and_rsp_daily_snapshot for the latest update. Will update data when it detects a new update time."
}

explore: rental_revenue_per_day_with_goal {
  group_label: "Markets Dashboard"
  label: "Current Month Rental Revenue by Day with Goal"
  case_sensitive: no
  persist_with: revenue_gold_update

  join: current_month_rental_revenue_drill {
    relationship: many_to_one
    type: inner
    sql_on: ${current_month_rental_revenue_drill.market_id} = ${rental_revenue_per_day_with_goal.market_id} ;;
  }

  join: prior_month_rental_revenue_drill {
    relationship: many_to_one
    type: inner
    sql_on: ${prior_month_rental_revenue_drill.market_id} = ${rental_revenue_per_day_with_goal.market_id} ;;
  }
}

explore: market_ancillary_revenue {
  group_label: "Markets Dashboard"
  label: "Ancillary Revenue by Market"
  case_sensitive: no
}

explore: markets_on_rent_asset_locations {
  group_label: "Markets Dashboard"
  label: "On Rent Asset Locations by Market"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${markets_on_rent_asset_locations.market_id} ;;
  }
}

# explore: actively_renting_customers {
#   group_label: "Markets Dashboard"
#   label: "Actively Renting Customers"
#   case_sensitive: no
#
#   join: actively_renting_customers_drill {
#     relationship: many_to_one
#     type: inner
#     sql_on: ${actively_renting_customers_drill.market_id} = ${actively_renting_customers.market_id} ;;
#   }
# }

explore: asset_inventory_status_duration {
  group_label: "Markets Dashboard"
  label: "Asset Inventory Status Duration"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${asset_inventory_status_duration.market_id} ;;
  }
}

explore: overdue_inspections {
  group_label: "Markets Dashboard"
  label: "Overdue Inspection Count"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${overdue_inspections.market_id} ;;
  }
}

explore: market_action_items {
  group_label: "Markets Dashboard"
  label: "Market Action Items"
  case_sensitive: no
  persist_with: market_action_item_update
  sql_always_where: (
      ${location_permissions.market_access}
      OR ${location_permissions.district_access}
      OR ${location_permissions.region_access}
    )

    AND
    {% condition market_action_items.region_name_filter_mapping %}
      ${market_action_items.region_name}
    {% endcondition %}

    AND
    {% condition market_action_items.district_filter_mapping %}
      ${market_action_items.district}
    {% endcondition %}

    AND
    {% condition market_action_items.market_name_filter_mapping %}
      ${market_action_items.market_name}
    {% endcondition %}

    AND
    {% condition market_action_items.market_type_filter_mapping %}
      ${market_action_items.market_type}
    {% endcondition %}
  ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${market_action_items.market_id} ;;
  }
}

explore: unreceived_pos_action_items {
  group_label: "Markets Dashboard"
  label: "Unreceived POs"
  case_sensitive: no
}

explore: invoices_awaiting_approval_action_items {
  group_label: "Markets Dashboard"
  label: "Invoices Awaiting Approval"
  case_sensitive: no
  persist_for: "1 hour"
}

explore: unsigned_company_contracts_action_items {
  group_label: "Markets Dashboard"
  label: "Unsigned Company Contracts"
  case_sensitive: no
  persist_for: "1 hour"

}

explore: unapproved_branch_invoices_action_items {
  group_label: "Markets Dashboard"
  label: "Unapproved Branch Invoices"
  case_sensitive: no
  persist_for: "1 hour"

}

explore: employee_and_vehicle_accidents {
  group_label: "Markets Dashboard"
  label: "Employee and Vehicle Accident Rates"
  description: "Last 12 months"
  case_sensitive: no
  persist_for: "1 hour"

}

explore: future_market_goals {
  group_label: "Markets Dashboard"
  label: "Future Market Goals"
  description: "Only pulling next 6 months of goals"
  case_sensitive: no
  persist_for: "10 hours"
}

explore: in_out_market_revenue {
  group_label: "Markets Dashboard"
  label: "In/Out of Market Revenue"
  case_sensitive: no
}

explore: current_previous_month_oec {
  group_label: "Markets Dashboard"
  label: "Current and Previous Month OEC"
  case_sensitive: no
  persist_with: total_month_oec
}

# explore: new_accounts_leaderboard {
#   group_label: "Markets Dashboard"
#   label: "New Accounts Leaderboard"
#   case_sensitive: no
# }

explore: 9_month_market_revenue_and_goal {
  group_label: "Markets Dashboard"
  label: "Last 9 Month Market Revenue & Goal"
  case_sensitive: no
  persist_with: revenue_gold_update
}

explore: outside_hauling_po_no_delivery {
  group_label: "Markets Dashboard"
  label: "Outside Hauling POs with an Invoice but No Matching Delivery"
  description: "Outside Hauling POs with an Invoice but No Matching Delivery"
  case_sensitive: no
}

explore: market_open_date {
  group_label: "Markets Dashboard"
  label: "Market Information Cards"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${market_open_date.market_id} ;;
  }
}

explore: cod_outstanding_action_items {
  group_label: "Markets Dashboard"
  label: "COD Outstanding"
  case_sensitive: no
  persist_for: "1 hour"

}
