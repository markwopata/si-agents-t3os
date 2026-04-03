connection: "reportingc_warehouse"

include: "/views/impact_location_report/*.view.lkml"
include: "/views/organization_asset_xref.view.lkml"
include: "/views/organizations*.view.lkml"

explore: impact_location_report{
  group_label: "Impact Location Report"
  label: "Impact Location Report"
  case_sensitive: no
  persist_for: "30 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_many
    sql_on: ${impact_location_report.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }
}
