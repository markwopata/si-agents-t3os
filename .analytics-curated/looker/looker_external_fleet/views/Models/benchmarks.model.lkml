connection: "es_warehouse"

include: "/views/Benchmarks/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: utilization_benchmarking {
  group_label: "Benchmarking"
  label: "Utilization Benchmarking"
  case_sensitive: no
  persist_for: "30 minutes"
}

explore: utilization_grading {
  group_label: "Benchmarking"
  label: "Utilization Grading"
  case_sensitive: no
  persist_for: "30 minutes"

  # join: assets {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${utilization_grading.asset_id} = ${assets.asset_id} ;;
  # }

}
