connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/ASSETS/int_asset_historical.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_companies_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_asset_inventory_status_pit.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_asset_inventory_status_pit.view.lkml"
include: "/Dashboards/Service/Views/Custom/asset_location.view.lkml"
include: "/Dashboards/Service/Views/Analytics/wo_updates.view.lkml"
include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/delivery_types.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/custom_sql/wos_within_24hrs_of_delivery.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ANALYTICS/ASSETS/int_equipment_assignments.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_work_orders_fleet_opt.view.lkml"
include: "/views/custom_sql/work_orders_during_rentals.view.lkml"

explore: rentals {
  case_sensitive: no

  join: orders {
    type: inner
    relationship: one_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: dim_companies_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_companies_fleet_opt.company_id} = ${orders.company_id} ;;
  }

  join: int_equipment_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: int_equipment_assignments_assets {
    from: dim_assets_fleet_opt
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_equipment_assignments.asset_id} = ${int_equipment_assignments_assets.asset_id} ;;
  }

  join: work_orders_during_rentals {
    type: left_outer
    relationship: many_to_many
    sql_on: ${work_orders_during_rentals.rental_id} = ${rentals.rental_id}
      and ${work_orders_during_rentals.asset_id} = ${int_equipment_assignments.asset_id}  ;;
  }

  join: dim_work_orders_fleet_opt {
    type: left_outer
    relationship: many_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${work_orders_during_rentals.work_order_id} ;;
  }
}

explore: asset_deliveries {
  from: deliveries
  case_sensitive: no

  join: delivery_types {
    type: inner
    relationship: many_to_one
    sql_on: ${delivery_types.delivery_type_id} = ${asset_deliveries.delivery_type_id} ;;
  }

  join: orders {
    type: inner
    relationship: one_to_one
    sql_on: ${orders.order_id} = ${asset_deliveries.order_id} ;;
  }

  join: dim_companies_fleet_opt {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_companies_fleet_opt.company_id} = ${orders.company_id} ;;
  }

  join: dim_assets_fleet_opt {
    type: inner
    relationship: one_to_many
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${asset_deliveries.asset_id} ;;
  }

  join: wos_within_24hrs_of_delivery {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wos_within_24hrs_of_delivery.delivery_id} = ${asset_deliveries.delivery_id} ;;
  }
}

datagroup: market_level_hourly_data_update {
  sql_trigger: select max(daily_timestamp) from analytics.assets.market_level_asset_metrics_daily ;;
  max_cache_age: "4 hours"
  description: "Looking at analytics.assets.market_level_asset_metrics_daily to get most recent update."
}

explore: asset_scoring { #In DIM ASSETS FLEET OPT
  case_sensitive: no

  join: all_equipment_rouse_estimates {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${asset_scoring.asset_id} = ${all_equipment_rouse_estimates.asset_id} ;;
  }
}

explore: current_unavailable_oec {
  from: int_asset_historical
  persist_with: market_level_hourly_data_update
  sql_always_where: ${current_unavailable_oec.daily_timestamp_date} = current_date;;

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${current_unavailable_oec.asset_id} ;;
  }

  join: dim_markets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_markets_fleet_opt.market_id} = ${current_unavailable_oec.rental_branch_id} ;;
  }

  join: asset_company {
    from: dim_companies_fleet_opt
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_company.company_id} = ${current_unavailable_oec.asset_company_id} ;;
  }

  join: unavailable_timestamp_date {
    from:  dim_dates_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${unavailable_timestamp_date.dt_date} = ${current_unavailable_oec.daily_timestamp_date} ;;
  }

  join: asset_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_location.asset_id} = ${current_unavailable_oec.asset_id} ;;
  }

  join: last_wo_update {
    from: wo_updates
    type: left_outer
    relationship: one_to_one
    sql_on: ${current_unavailable_oec.asset_id} = ${last_wo_update.asset_id} and
            ${last_wo_update.wo_update_num} = 1 and
            ${last_wo_update.asset_sequence_num} = 1 ;;
  }
}

explore: int_asset_historical {
  description: "Full int_asset_histroical table with a couple helpful tables joined in"

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${int_asset_historical.asset_id} ;;
  }

  join: dim_markets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_markets_fleet_opt.market_id} = ${int_asset_historical.rental_branch_id} ;;
  }

  join: asset_company {
    from: dim_companies_fleet_opt
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_company.company_id} = ${int_asset_historical.asset_company_id} ;;
  }

  join: unavailable_timestamp_date {
    from:  dim_dates_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${unavailable_timestamp_date.dt_date} = ${int_asset_historical.daily_timestamp_date} ;;
  }
}
