connection: "es_snowflake"

include: "/analytics/Fleet_Utilization/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
 explore: fleet_utilization_by_asset {
   }

explore: fleet_utilization_by_class {
}

explore: fleet_utilization_by_company_and_class {
}

explore: utilization_by_class {
}
