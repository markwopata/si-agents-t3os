connection: "es_snowflake_analytics"

########### ANALYTICS ###########
include: "/views/ANALYTICS/dvir_detail.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
########### custom_sql ###########
include: "/views/custom_sql/company_directory_with_vehicle.view.lkml"
include: "/views/custom_sql/completed_pm_work_orders.view.lkml"
include: "/views/custom_sql/daily_asset_usage.view.lkml"
include: "/views/custom_sql/driver_portal_vs_t3.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
########### ES_WAREHOUSE ###########
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/tracking_diagnostic_codes.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
########### SCD ###########
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/SCD/scd_asset_odometer.view.lkml"
include: "/views/SCD/scd_asset_hours.view.lkml"
########### WORK_ORDERS ###########
include: "/views/WORK_ORDERS/work_orders.view.lkml"
########### PLATFORM ###########
include: "/views/PLATFORM/v_assets.view.lkml"
########### BUSINESS_INTELLIGENCE ###########
include: "/views/business_intelligence/stg_t3__telematics_health.view.lkml"
include: "/views/business_intelligence/fact_operator_assignments.view.lkml"


explore: assets {
  label: "Asset Roster"
  sql_always_where: ${markets.active} = TRUE and ${markets.company_id} = 1854 and ${transportation_assets.transportation_asset} = 'YES';;

  join: transportation_assets {
    type: inner
    relationship: one_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: coalesce(${assets.rental_branch_id},${assets.inventory_branch_id})=${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: tracking_diagnostic_codes {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${tracking_diagnostic_codes.asset_id} ;;
  }

  join: dvir_detail_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${dvir_detail_aggregate.asset_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: scd_asset_odometer {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${scd_asset_odometer.asset_id} ;;
    sql_where: ${scd_asset_odometer.current_flag} = 1 ;;
  }

  join: scd_asset_hours {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${scd_asset_hours.asset_id} ;;
    sql_where: ${scd_asset_hours.current_flag} = 1 ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: completed_pm_work_orders {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets.asset_id} = ${completed_pm_work_orders.asset_id}
      and ${transportation_assets.asset_id} = ${completed_pm_work_orders.asset_id};;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
    # sql_where: ${asset_status_key_values.name} = 'driver_user_id' ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: CAST(${users.user_id} as string) = ${asset_status_key_values.value} ;;
    # sql_where: ${asset_status_key_values.name} = 'driver_user_id' ;;
  }

  join: daily_asset_usage {
    type: left_outer
    relationship: one_to_many
    sql_on: ${transportation_assets.asset_id} = ${daily_asset_usage.asset_id} ;;
  }

  join: asset_utilization_last_30days {
    type: left_outer
    relationship: one_to_many
    sql_on: ${transportation_assets.asset_id} = ${asset_utilization_last_30days.asset_id} ;;
  }

  join: driver_portal_vs_t3 {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${driver_portal_vs_t3.asset_id} ;;
  }

  # join: asset_nbv_all_owners {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id} = ${asset_nbv_all_owners.asset_id} ;;
  # }

  join: company_directory_with_vehicle {
    type: left_outer
    relationship: one_to_many
    sql_on: ${markets.market_id} = ${company_directory_with_vehicle.market_id} and ${assets.license_type} = ${company_directory_with_vehicle.license_type};;
  }

  join: fact_operator_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${fact_operator_assignments.asset_id} and ${fact_operator_assignments.current_assignment} ;;
  }

  join: rental_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.rental_branch_id} = ${rental_market.market_id} ;;
  }

  join: inventory_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.inventory_branch_id} = ${inventory_market.market_id} ;;
  }

  join: service_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.service_branch_id} = ${service_market.market_id} ;;
  }

  join: stg_t3__telematics_health {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${stg_t3__telematics_health.asset_id} ;;
  }

  join: v_assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${assets.asset_id} ;;
  }
}
