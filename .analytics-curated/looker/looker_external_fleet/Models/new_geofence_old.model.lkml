connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project

# explore: new_geofence_old {
#   label: "New Geofence Dashboard"
#   description: "Time in Geofence per asset per day"
# }
