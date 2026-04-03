connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/fleet_utilization/*.view.lkml"

explore: asset_utilization_by_day {
#   sql_always_where:
# ${asset_utilization_by_day.company_id} in
# (
#   SELECT company_id
#   FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
#   where (parent_company_id =  18395::integer
#   or company_id =  18395::integer)
# )
# ;;
  # join: orders {
  #   relationship: many_to_one
  #   sql_on: ${asset_utilization_by_day.id} = ${order_items.order_id} ;;
  # }
}
