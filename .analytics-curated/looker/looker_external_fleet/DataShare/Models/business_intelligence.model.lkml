connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/fleet_utilization/*.view.lkml"
include: "/DataShare/views/*.view.lkml"
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: asset_info {

  join: company_values {
    relationship: one_to_many
    sql_on: ${asset_info.asset_id} = ${company_values.asset_id} ;;
  }


  join: asset_utilization_by_day {
    relationship: one_to_many
    sql_on: ${asset_info.asset_id} = ${asset_utilization_by_day.asset_id} ;;
   }

  }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: csv_upload_test {
  }
