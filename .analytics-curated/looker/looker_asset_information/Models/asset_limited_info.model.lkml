connection: "es_snowflake_c_analytics"

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ANALYTICS/national_accounts.view.lkml"
include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/rental_rate_by_company.view.lkml"
include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"
include: "/views/custom_sql/last_complete_delivery.view.lkml"
include: "/views/custom_sql/order_salespersons_pivot.view.lkml"
include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/custom_sql/active_branch_rental_rates_pivot.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/rentals_rates_refresh.view.lkml"
include: "/views/custom_sql/units_on_rent_rolling_90_days.view.lkml"
include: "/views/custom_sql/bulk_on_rent_rolling_90_days.view.lkml"
include: "/views/custom_sql/bulk_rentals.view.lkml"
include: "/views/custom_sql/bulk_on_rent_details.view.lkml"
include: "/views/ANALYTICS/user_created_assets.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/custom_sql/proposed_rates_2024q1.view.lkml"
include: "/views/ES_WAREHOUSE/rental_protection_plans.view.lkml"
include: "/views/FLEET_OPTIMIZATION/utilization_asset_market_historical.view.lkml"
include: "/views/ANALYTICS/salesperson_rentals_and_reservations.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/custom_sql/rentals_with_billing_logic.view.lkml"


# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }

#Asset Information - Units on Rent With Limited Access
explore: orders {
  group_label: "Asset Information"
  label: "Units on Rent Information Limited Access"
  case_sensitive: no
  # always_join: [active_branch_rental_rates_pivot]##,rates_refresh] - comment out outdated table. !! MB COMMENT OUT 12/6 THIS IS A COSTLY VIEW -- IVE MADE MOVE TO SHIFT LOGIC/MEASURES OUT OF RENTALS VIEW INTO PIVOT VIEW MENTIONED
  sql_always_where: ((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null)
  AND ((('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} ILIKE '{{ _user_attributes['email'] }}' )) OR ${market_region_xwalk.District_Region_Market_Access});;


  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }

  join: rentals_with_billing_logic {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_id} = ${rentals_with_billing_logic.rental_id} ;;
  }

  join: invoices {
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.order_id} = ${orders.order_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} and ${equipment_assignments.asset_id} = ${rentals.asset_id};;
  }

  join: assets  {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${deliveries.rental_id} = ${rentals.rental_id} and ${rentals.asset_id} = ${deliveries.asset_id} ;;
  }

  join: locations {
    type: inner
    relationship: many_to_one
    sql_on:  ${deliveries.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id}  ;;
  }

  join: order_salespersons_pivot {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${order_salespersons_pivot.order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${orders.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

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

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id};;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  }

  join: national_account_reps {
    from: national_accounts
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: rental_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: last_complete_delivery {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${last_complete_delivery.rental_id} = ${rentals.rental_id} and ${rentals.asset_id} = ${last_complete_delivery.asset_id};;
  }

  join: requested_by_user {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.user_id} = ${requested_by_user.user_id} ;;
  }

  join: active_branch_rental_rates_pivot {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.market_id} = ${active_branch_rental_rates_pivot.branch_id} and ${assets_aggregate.equipment_class_id} = ${active_branch_rental_rates_pivot.equipment_class_id} ;;
  }

  join: bulk_rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.order_id} = ${bulk_rentals.order_id} ;;
  }

  # temporary additions for 2024 rate refresh
  join: proposed_rates_2024q1 {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${proposed_rates_2024q1.market_id}
      and ${rentals.equipment_class_id} = ${proposed_rates_2024q1.equipment_class_id};;
  }

  join: rentals_rates_refresh {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals_rates_refresh.rental_id} = ${rentals.rental_id} ;;
  }

  join: rental_protection_plans {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_protection_plan_id} = ${rental_protection_plans.rental_protection_plan_id} ;;
  }

}

#Asset Information - Re-Rent Units on Rent With Limited Access
explore: orders_rerent {
  from: orders
  group_label: "Asset Information"
  label: "Units on Re-Rent Information Limited Access"
  case_sensitive: no
  sql_always_where: (SUBSTR(TRIM(${assets.serial_number}), 1, 3) = 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) = 'RR')
    AND ((('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  '{{ _user_attributes['email'] }}' )) OR ${market_region_xwalk.District_Region_Market_Access});;

  join: order_salespersons {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_rerent.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders_rerent.order_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets  {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  # join: asset_statuses {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id}=${asset_statuses.asset_id} ;;
  # }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders_rerent.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${orders_rerent.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

  join: customer {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders_rerent.user_id} = ${customer.user_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${customer.company_id} = ${companies.company_id} ;;
  }

  join: sales_track_logins {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.company_id} = ${users.xero_salesperson_account_code} ;;
  }

  join: asset_company {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_company.company_id} = ${assets.company_id} ;;
  }

  # join: net_terms {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  # }

  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id};;
  }

  join: national_accounts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: many_to_many
    sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
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

}

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
#Rate Achievement - Rate by Company
# explore: rental_rate_by_company {
#   group_label: "Rate Achievement"
#   label: "Rate by Company"
#   case_sensitive: no
#   sql_always_where: (('salesperson' = {{ _user_attributes['department'] }}
#   AND ${users.email_address} =  '{{ _user_attributes['email'] }}' ) OR 'salesperson' != {{ _user_attributes['department'] }});;

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rental_rate_by_company.salesperson_user_id}=${users.user_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rental_rate_by_company.market_id}=${markets.market_id};;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id}=${market_region_xwalk.market_id} ;;
#   }

#     join: national_account_reps {
#     from: national_accounts
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
#   }

#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${rental_rate_by_company.asset_id}=${asset_status_key_values.asset_id} ;;
#   }

#   join: equipment_assignments {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${rental_rate_by_company.asset_id}=${equipment_assignments.asset_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rental_rate_by_company.company_id} = ${companies.company_id} ;;
#   }

# }


#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: assets_inventory_for_markets {
#   from: assets
#   sql_table_name: ES_WAREHOUSE.PUBLIC.assets ;;
#   label: "Inventory Information with no Benchmark Rate (For Market Dashboard)"
#   group_label: "Asset Information"
#   case_sensitive: no
#   sql_always_where: ${market_region_xwalk.District_Region_Market_Access} AND (SUBSTR(TRIM(${serial_number}, 1, 3) != 'RR-' and SUBSTR(TRIM(${serial_number}, 1, 2) != 'RR' OR ${assets_inventory_for_markets.serial_number} is null) ;;

#   join: markets {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.markets ;;
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${assets_inventory_for_markets.rental_branch_id},${assets_inventory_for_markets.inventory_branch_id})=${markets.market_id} ;;
#   }

#   join: asset_statuses {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.asset_statuses ;;
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets_inventory_for_markets.asset_id}=${asset_statuses.asset_id} ;;
#   }

#   join: asset_purchase_history {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.asset_purchase_history ;;
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${assets_inventory_for_markets.asset_id}=${asset_purchase_history.asset_id} ;;
#   }

#   join: equipment_models {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.equipment_models ;;
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${assets_inventory_for_markets.equipment_model_id} ;;
#   }

#   join: equipment_classes_models_xref {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.equipment_classes_models_xref ;;
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
#   }

#   join: equipment_classes {
#     sql_table_name: ES_WAREHOUSE.PUBLIC.equipment_classes ;;
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
#   }

#   join: asset_purchase_history_facts_final {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${asset_purchase_history_facts_final.asset_id} = ${assets_inventory_for_markets.asset_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

#Contract Information
explore: order_contracts {
  view_name: orders
  group_label: "Order Contract Information"
  label: "Contract Information Limited Access"
  case_sensitive: no
  always_join: [active_branch_rental_rates_pivot]
  sql_always_where: ((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null)
  AND ((('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  '{{ _user_attributes['email'] }}' )) OR ${market_region_xwalk.District_Region_Market_Access});;

  join: order_salespersons {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${order_salespersons.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }

  join: rentals_with_billing_logic {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_id} = ${rentals_with_billing_logic.rental_id} ;;
  }

  join: bulk_rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.order_id} = ${bulk_rentals.order_id} ;;
  }

  join: equipment_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: assets  {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_purchase_history_facts_final {
    type:  left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: many_to_one
    sql_on: ${deliveries.rental_id} = ${rentals.rental_id} ;;
  }

  join: locations {
    type: inner
    relationship: one_to_many
    sql_on:  ${deliveries.location_id} = ${locations.location_id} ;;
    #coalesce(${deliveries.location_id},${rental_locations.location_id}) = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id}  ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${order_salespersons.user_id},${orders.salesperson_user_id}) = ${users.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${orders.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
  }

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

  join: market_region_salesperson {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id};;
  }

  # join: national_accounts {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${companies.company_id} = ${national_accounts.company_id} ;;
  # }

  # join: national_account_reps {
  #   from: national_accounts
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${users.Full_Name_with_ID_national} = ${national_account_reps.full_name_with_id} ;;
  # }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: rental_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: active_branch_rental_rates_pivot {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.market_id} = ${active_branch_rental_rates_pivot.branch_id} and ${rentals.equipment_class_id} = ${active_branch_rental_rates_pivot.equipment_class_id} ;;
  }
  join: utilization_asset_market_historical {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${assets.asset_id} = ${utilization_asset_market_historical.asset_id} and  ${orders.market_id} = ${utilization_asset_market_historical.market_id};;
  }
  join: salesperson_rentals_and_reservations {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${assets.asset_id} = ${salesperson_rentals_and_reservations.asset_id} and  ${orders.market_id} = ${salesperson_rentals_and_reservations.market_id};;
  }
  join: dim_assets_fleet_opt {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${assets.asset_id} = ${dim_assets_fleet_opt.asset_id} and  ${orders.market_id} = ${dim_assets_fleet_opt.asset_market_id};;
  }
}

explore: rolling_90_day_aggregates {
  label: "Rolling 90 Day Totals by Market"
  description: "Used to get aggregated totals of units (assets on rent) and bulk (parts on rent)"
  from: market_region_xwalk
  view_name: market_region_xwalk
  sql_always_where: 'collectors' = {{ _user_attributes['department'] }} OR
                    'developer' = {{ _user_attributes['department'] }} OR
                    'god view' = {{ _user_attributes['department'] }} OR
                    ('managers' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }}
                      AND ${market_region_xwalk.District_Region_Market_Access}) ;;

  join: units_on_rent_rolling_90_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${units_on_rent_rolling_90_days.rental_branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: bulk_on_rent_rolling_90_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${bulk_on_rent_rolling_90_days.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
#Asset Information - Units on Rent With Limited Access including Bulk
# explore: orders_bulk {
#   from: orders
#   group_label: "Asset Information"
#   label: "Units on Rent Information Limited Access with Bulk"
#   hidden: yes
#   case_sensitive: no
#   always_join: [active_branch_rental_rates_pivot]
#   sql_always_where: ((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null)
#     AND ((('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  '{{ _user_attributes['email'] }}' )) OR ${market_region_xwalk.District_Region_Market_Access});;


#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_bulk.order_id} = ${order_salespersons.order_id} ;;
#   }

#   join: rentals {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.order_id} = ${orders_bulk.order_id} ;;
#   }

#   join: equipment_assignments {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} and ${equipment_assignments.asset_id} = ${rentals.asset_id};;
#   }

#   join: assets  {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
#   }

#   join: asset_purchase_history {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
#   }

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${order_salespersons.user_id},${orders_bulk.salesperson_user_id}) = ${users.user_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${orders_bulk.market_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
#   }

#   join: customer {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_bulk.user_id} = ${customer.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${customer.company_id} = ${companies.company_id} ;;
#   }

#   join: rental_statuses {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
#   }

#   join: active_branch_rental_rates_pivot {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${orders_bulk.market_id} = ${active_branch_rental_rates_pivot.branch_id} and ${assets.equipment_class_id} = ${active_branch_rental_rates_pivot.equipment_class_id} ;;
#   }

#   join: bulk_rentals {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${rentals.order_id} = ${bulk_rentals.order_id} ;;
#   }

#   join: bulk_parts_on_rent {
#     from: bulk_on_rent_details
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rentals.rental_id} = ${bulk_parts_on_rent.rental_id};;
#   }

# }

explore: user_created_assets {
  group_label: "Fleet"
  case_sensitive: no
}
