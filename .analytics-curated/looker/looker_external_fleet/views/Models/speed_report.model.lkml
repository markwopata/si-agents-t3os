connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: speed_report_incident_log {
  group_label: "Fleet"
  label: "Speed Report"
  case_sensitive: no

  # join: assets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${speed_report_incident_log.asset_id} = ${assets.asset_id} ;;
  # }

  # join:asset_types {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  # }

  # join:markets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${speed_report_incident_log.inventory_branch_id} = ${markets.market_id} ;;
  # }

  # join: categories {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${categories.category_id} = ${assets.category_id} ;;
  # }

  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${speed_report_incident_log.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} AND ${organization_asset_xref.asset_id} = ${organizations.asset_id} ;;
  }

 }
