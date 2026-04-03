connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project


explore: jobsite_usage_report {
  group_label: "Utilization"
  label: "Jobsite Usage Report"
  case_sensitive: no
  persist_for: "10 minutes"
  sql_always_where: ${geofences.deleted} = FALSE ;;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobsite_usage_report.asset_id} = ${assets.asset_id} ;;
  }

  join:asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: geofences {
    type: inner
    relationship: many_to_one
    sql_on: ${geofences.geofence_id} = ${jobsite_usage_report.geofence_id} ;;
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

}
