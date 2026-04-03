connection: "es_snowflake"

include: "/views/custom_sql/yard_tech_lookup_tool.view.lkml"
include: "/views/custom_sql/yard_tech_users.view.lkml"
include: "/views/custom_sql/asset_rental_status.view.lkml"
include: "/views/ANALYTICS/sales_track_logins.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/active_branch_rental_rates_pivot.view.lkml"


explore: yard_tech_lookup_tool {
  group_label: "Dispatch"
  case_sensitive: no
  # always_join: [active_branch_rental_rates_pivot]
  persist_for: "30 minutes"

  join: yard_tech_users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${yard_tech_users.rental_id}=${yard_tech_lookup_tool.rental_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${yard_tech_lookup_tool.company_id} ;;
  }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }

  join: active_branch_rental_rates_pivot {
    type: left_outer
    relationship: one_to_one
    sql_on: ${yard_tech_lookup_tool.market_id} = ${active_branch_rental_rates_pivot.branch_id} and ${yard_tech_lookup_tool.equipment_class_id} = ${active_branch_rental_rates_pivot.equipment_class_id} ;;
  }

}


explore: asset_rental_status {
  group_label: "Dispatch"
  case_sensitive: no
  persist_for: "30 minutes"
  }
