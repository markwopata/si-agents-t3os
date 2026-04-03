connection: "es_snowflake_analytics"

include: "./*.view.lkml"

explore: auction_list {
  group_label: "Fleet"
  label: "Auction List"
  case_sensitive: no
}
