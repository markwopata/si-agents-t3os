connection: "es_snowflake"

include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/Dashboards/Service/Inspections/Views/overdue_inspections.view.lkml"
include: "/Dashboards/Service/Inspections/Views/overdue_inspection_totals.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/asset_service_intervals.view.lkml"
include: "/Dashboards/Service/Views/Analytics/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/Dashboards/Service/Views/Custom/asset_location.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/custom_sql/assets_with_multiple_open_wos.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/fact_monday_transportation_audit.view.lkml"
include: "/views/FLEET_OPTIMIZATION/v_dim_monday_transportation_audit.view.lkml"
include: "/views/SAASY/PUBLIC/asset_maintenance_status.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"

explore: overdue_inspections {
  group_label: "Service"
  case_sensitive: no

  join: service_branch {
    from: market_region_xwalk
    type: inner
    relationship: many_to_one
    sql_on: ${overdue_inspections.service_branch_id} = ${service_branch.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${overdue_inspections.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: asset_location {
    type: inner
    relationship: one_to_one
    sql_on: ${overdue_inspections.asset_id} = ${asset_location.asset_id} ;;
  }

}


# Commented out due to low usage on 2026-03-27
# explore: overdue_inspection_totals {
#   group_label: "Service"
#   case_sensitive: no
#
#   join: service_branch {
#     from: market_region_xwalk
#     type: inner
#     relationship: many_to_one
#     sql_on: ${overdue_inspection_totals.asset_service_branch_id} = ${service_branch.market_id} ;;
#
#   }
# }

explore: fact_monday_transportation_audit {
  label: "Transportation Audit"
  # hidden: yes

  join: v_dim_monday_transportation_audit {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_monday_transportation_audit.pk_audit_id} = ${v_dim_monday_transportation_audit.pk_audit_id} ;;
  }
  join: dim_dates_fleet_opt {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_monday_transportation_audit.fk_date_key} = ${dim_dates_fleet_opt.dt_key} ;;
  }
  join: dim_markets_fleet_opt {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_monday_transportation_audit.fk_market_key} = ${dim_markets_fleet_opt.market_key} ;;
  }
  join: branch_audit_rank {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_monday_transportation_audit.pk_audit_id} = ${branch_audit_rank.pk_audit_id} ;;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${dim_markets_fleet_opt.market_id} ;;
  }
}

explore: asset_service_intervals_with_exxon_inspections {
  from: asset_maintenance_status_with_exxon_inspections
  group_label: "Service"
  label: "Inspections - Asset Maintenance Status with Exxon Inspections"
  description: "Base Explore for all things Asset Inspections for the Service Dashboard as of 9/2025"

  join: asset_location {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_location.asset_id} = ${asset_service_intervals_with_exxon_inspections.asset_id} ;;
  }

  join: transportation_assets { #Added for Transp DB filtering
    type: left_outer
    relationship: one_to_one
    sql_on: ${transportation_assets.asset_id} = ${asset_service_intervals_with_exxon_inspections.asset_id} ;;
  }

  join: market_region_xwalk { #Using Xwalk because everything on the dashboard is still built on xwalk. keeping the same for filtering on Transpo DB
    type: full_outer
    relationship: many_to_one
    sql_on: ${asset_service_intervals_with_exxon_inspections.market_id} = ${market_region_xwalk.market_id};;
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_service_intervals_with_exxon_inspections.asset_id} = ${dim_assets_fleet_opt.asset_id}  ;;
  }

  join: assets {  #Using assets because everything on the dashboard is still built on assets. keeping the same for filtering on Transpo DB
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${asset_service_intervals_with_exxon_inspections.asset_id} ;;
  }

  join: company_purchase_order_line_items { #Added for filtering on Transpo DB
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_purchase_order_line_items.asset_id} = ${asset_service_intervals_with_exxon_inspections.asset_id} ;;
  }

  join: market_service_oec {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_service_oec.market_id} = ${market_region_xwalk.market_id} ;;
      # and ${market_service_oec.asset_equipment_make_id} = ${dim_assets_fleet_opt.asset_equipment_make_id}
      # and ${market_service_oec.asset_equipment_class_name} = ${dim_assets_fleet_opt.asset_equipment_class_name};;
  }
}

explore: asset_service_intervals {
  group_label: "Service"
  label: "Inspections - Asset Service Intervals"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_service_intervals.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = coalesce(${assets.service_branch_id}, ${assets.rental_branch_id}) ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id}  ;;
  }

  join: asset_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_location.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} =  ${assets.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transportation_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: CAST(${users.user_id} as string) = ${asset_status_key_values.value} ;;
    # sql_where: ${asset_status_key_values.name} = 'driver_user_id' ;;
  }

  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_service_intervals.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
  }

  join: assets_with_multiple_open_wos {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_with_multiple_open_wos.asset_id} = ${assets.asset_id} ;;
  }
}

explore: total_fleet {
  from:  assets
  group_label: "Service"
  label: "Asset Service Intervals/Total Fleet"

  join: asset_service_intervals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${total_fleet.asset_id} = ${asset_service_intervals.asset_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = coalesce(${total_fleet.service_branch_id}, ${total_fleet.rental_branch_id})  ;;
  }

  join: overdue_inspections {
    type: left_outer
    relationship: one_to_one
    sql_on: ${total_fleet.asset_id}=${overdue_inspections.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${total_fleet.asset_id};;
  }
}
