connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: telematics_health_report {
  group_label: "Fleet"
  label: "Telematics Health Report"
  case_sensitive: no
  sql_always_where: ${telematics_health_report.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  persist_for: "10 minutes"


  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_many
    sql_on: ${telematics_health_report.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_mapping.asset_id} = ${telematics_health_report.asset_id} ;;
  }

}
