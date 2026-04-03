connection: "es_snowflake_analytics"

include: "/views/custom_sql/unreceived_pos.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

explore: unreceived_pos {
  case_sensitive: no
  description: "Used to pull list of unapproved POs that have an invoice in Concur"

  join: market_region_xwalk {
    view_label: "Requesting branch"
    type: inner
    relationship: many_to_one
    sql_on: try_cast(${unreceived_pos.requesting_branch} as INTEGER) = ${market_region_xwalk.market_id} ;;
  }
}
