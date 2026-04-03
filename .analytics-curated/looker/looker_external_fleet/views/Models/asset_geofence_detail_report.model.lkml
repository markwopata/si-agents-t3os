connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/DBT_Triage_Tables/*.view.lkml"                # include all views in the views/ folder in this project

explore: asset_geofence_details {
  sql_always_where:
  (${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  OR
  ${asset_id} in  (select asset_id from
  table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
        '{{ _user_attributes['user_timezone'] }}')))
  )
  AND ${geofences.company_id} = {{ _user_attributes['company_id'] }}::numeric
  AND ${geofences.deleted} = FALSE
  ;;
  group_label: "Fleet"
  label: "Asset Geofence Detail Report"
  case_sensitive: no
  # persist_for: "30 minutes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.asset_id} = ${assets.asset_id} ;;
  }

  join: stg_t3__operator_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.asset_id} = ${stg_t3__operator_assignments.asset_id}
    and ${asset_geofence_details.entry} >= ${stg_t3__operator_assignments.assignment_time_raw}
    and coalesce(${asset_geofence_details.exit},CURRENT_DATE()) <= ${stg_t3__operator_assignments.unassignment_raw}
    and ${stg_t3__operator_assignments.asset_company_id} = {{ _user_attributes['company_id'] }}::numeric;;
  }

  # join: rental_asset_list_10_days {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${rental_asset_list_10_days.asset_id} = ${assets.asset_id} ;;
  # }

  join:asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: geofences {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.geofence_id} = ${geofences.geofence_id} ;;
  }

  join:purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_mapping.asset_id} = ${assets.asset_id} ;;
  }

}
