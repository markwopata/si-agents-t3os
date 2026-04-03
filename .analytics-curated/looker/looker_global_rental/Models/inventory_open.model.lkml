connection: "es_warehouse_global"

include: "/markets_dashboard.dashboard"
include: "/views/ES_WAREHOUSE/*.view.lkml"
include: "/views/ES_WAREHOUSE_GLOBAL/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

explore: assets_inventory {
  from: assets
  label: "Global Inventory Information - No RR - Open Access"
  group_label: "Global Asset Information"
  case_sensitive: no
  sql_always_where: ${markets.company_id} = {{ _user_attributes['company_id'] }}
    AND ((SUBSTR(TRIM(${serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${serial_number}), 1, 2) != 'RR') or ${serial_number} is null) ;;

  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.rental_branch_id} = ${markets.market_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets_inventory.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_inventory.asset_id}=${assets_aggregate.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_inventory.company_id}=${companies.company_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_inventory.asset_id}=${asset_purchase_history.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_purchase_history_facts_final.asset_id} = ${assets_inventory.asset_id} ;;
  }

  join: units_on_rent_rolling_180_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${units_on_rent_rolling_180_days.asset_id} = ${assets_inventory.asset_id} ;;
  }

  join: asset_class_customer_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${asset_class_customer_branch.asset_id} ;;
  }

}

  #Asset Information - Summarized Asset Information by Market
  explore: market_inventory_information {
    label: "Global Summarized Asset Information by Market"
    group_label: "Global Asset Information"

  join: asset_class_customer_branch {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_inventory_information.asset_id} = ${asset_class_customer_branch.asset_id} ;;
  }
}

#Asset Information - Inventory Information
explore: market_class_inventory_status_count {
  group_label: "Global Asset Information"
  label: "Asset Status Count for Each Market and Class"
  case_sensitive: no

  join: financial_utilization {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_class_inventory_status_count.category_id} = ${financial_utilization.category_id} ;;
   }

  join:equipmentclass_category_parentcategory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${financial_utilization.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
  }
}

  #Asset Information - Inventory Information
  explore: assets {
    group_label: "Global Asset Information"
    label: "Current Inventory Status"
    case_sensitive: no
    sql_always_where: ${asset_class_customer_branch.rsp_company_id} = {{ _user_attributes['company_id'] }}
    AND ((SUBSTR(TRIM(${serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${serial_number}), 1, 2) != 'RR') or ${serial_number} is null)
    AND ${cross_hire} = 'No';;

    join: asset_class_customer_branch {
      type: left_outer
      relationship: one_to_one
      sql_on: ${assets.asset_id} = ${asset_class_customer_branch.asset_id} ;;
    }

    join: last_delivery_location {
      type: left_outer
      relationship: one_to_one
      sql_on: ${assets.asset_id} = ${last_delivery_location.asset_id} ;;
    }

    join: current_location_status {
      type: left_outer
      relationship: one_to_one
      sql_on: ${assets.asset_id} = ${current_location_status.asset_id} ;;
    }

    join: asset_status_key_values_hours {
      ##Only joining asset hours from this table
      type: left_outer
      relationship: one_to_one
      sql_on: ${assets.asset_id} = ${asset_status_key_values_hours.asset_id};;
    }
    }

  explore: inventory_to_onrent_assetclass_counts {
  group_label: "Global Asset Information"
  label: "Global Inventory and OnRent Information"
  case_sensitive: no

    join:equipmentclass_category_parentcategory {
      type: left_outer
      relationship: many_to_one
      sql_on: ${inventory_to_onrent_assetclass_counts.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
    }
  }

  explore: asset_util_eff_rate_rolling180 {
    group_label: "Global Asset Information"
    label: "Est. Rolling 180 Day Count and Financial Utilization"
    case_sensitive: no

    join: asset_status_key_values {
      type: left_outer
      relationship: many_to_one
      sql_on: ${asset_util_eff_rate_rolling180.asset_id} = ${asset_status_key_values.asset_id};;
    }

    join: asset_class_customer_branch {
      type: left_outer
      relationship: many_to_one
      sql_on: ${asset_util_eff_rate_rolling180.asset_id} = ${asset_class_customer_branch.asset_id} ;;
    }

    join: assets {
      type: left_outer
      relationship: many_to_one
      sql_on: ${asset_util_eff_rate_rolling180.asset_id} = ${assets.asset_id} ;;
    }
  }
