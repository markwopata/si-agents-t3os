connection: "es_snowflake_analytics"

include: "/views/custom_sql/pending_branch_approval.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

explore: pending_branch_approval {
  join: market_region_xwalk {
    relationship: many_to_one
    sql_on: try_cast(${pending_branch_approval.branch_id} as INTEGER) = ${market_region_xwalk.market_id} ;;
  }
}
