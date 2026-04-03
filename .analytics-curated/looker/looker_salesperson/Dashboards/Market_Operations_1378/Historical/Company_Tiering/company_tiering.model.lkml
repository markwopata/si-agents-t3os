connection: "es_snowflake_c_analytics"

include: "/Dashboards/Market_Operations_1378/Historical/Company_Tiering/*.lkml"
include: "/Dashboards/Market_Operations_1378/Historical/Rankings/current_rep_home_market.view.lkml"




explore: tiering_practice {
  group_label: "Tiering"
  label: "Company Tiering"
  description: "Provides recommendations for quarterly gifts to companies by sales rep."

  join:current_rep_home_market {
      type: left_outer
      relationship: one_to_many
      sql_on: ${tiering_practice.primary_sp_user_id} = ${current_rep_home_market.user_id} ;;
}


}
