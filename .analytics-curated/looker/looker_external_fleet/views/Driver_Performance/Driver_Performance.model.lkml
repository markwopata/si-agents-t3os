connection: "reportingc_warehouse"

include: "/views/Driver_Performance/*.view.lkml"
include: "/views/*.view.lkml"
# include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.


explore: driver_performance_agg {
  view_name: driver_performance
  # group_label: "Driver"
  # label: "Tracking Incident Events"
  case_sensitive: no
  persist_for: "30 minutes"
  # sql_always_where: ${company_id} =  {{ _user_attributes['company_id'] }};;

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${driver_performance.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
        AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric
      ;;
  }

}
