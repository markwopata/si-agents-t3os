connection: "reportingc_warehouse"

include: "/views/Tracking_Incident_Dashboard/*.view.lkml"
include: "/views/*.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
 explore: tracking_incidents_events {
  view_name: tracking_incident_view
  group_label: "Fleet"
  label: "Tracking Incident Events"
  case_sensitive: no
  persist_for: "30 minutes"
  sql_always_where: ${company_id} =  {{ _user_attributes['company_id'] }};;

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_incident_view.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }
}
