
connection: "es_snowflake_analytics"

include: "/Dashboards/rental_rate_achievement/views/*.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"


# view: rental_rate_achievement {
#   extends: ["rental_rate_achievement"]
# }

explore: rental_rate_achievement {
  case_sensitive: no
  label: "Rental Rate Achievement"

join: market_region_xwalk {
  type: inner
  relationship: many_to_one
  sql_on: ${rental_rate_achievement.market_id} = ${market_region_xwalk.market_id} ;;
}

join: rentals {
  type: inner
  relationship: one_to_one
  sql_on: ${rental_rate_achievement.rental_id} = ${rentals.rental_id} ;;
}

join: assets_aggregate {
  type: inner
  relationship: many_to_one
  sql_on: ${rentals.asset_id} = ${assets_aggregate.asset_id} ;;
}

join: users { ## only added b/c of a lookml warning
  type: left_outer
  relationship: many_to_one
  sql_on: ${rentals.borrower_user_id} = ${users.user_id} ;;
}
  }
