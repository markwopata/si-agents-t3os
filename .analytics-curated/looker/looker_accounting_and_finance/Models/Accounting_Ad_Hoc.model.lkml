connection: "es_snowflake_analytics"

include: "/views/custom_sql/Asset_Lat_Long.view.lkml"
include: "/views/custom_sql/assets_with_jj_twin.view.lkml"
include: "/views/custom_sql/assets_with_duplicate_ids.view.lkml"
include: "/views/custom_sql/crockett_revenue.view.lkml"
include: "/views/custom_sql/rental_rev_earned_btw_dt.view.lkml"
include: "/views/custom_sql/inventory_balance.view.lkml"
include: "/views/custom_sql/recently_added_schedules.view.lkml"
include: "/views/custom_sql/T3_revenue_support.view.lkml"
include: "/views/custom_sql/T3_revenue_support_low.view.lkml"
include: "/views/custom_sql/T3_revenue_support_all.view.lkml"
include: "/views/custom_sql/T3_revenue_support_data.view.lkml"
include: "/views/custom_sql/6b_copy.view.lkml"
include: "/views/custom_sql/po_lifecycle_postings.view.lkml"


explore: asset_lat_long {}

# Commented out due to low usage on 2026-03-30
# explore: assets_with_jj_twin {
#   case_sensitive: no
# }

# Commented out due to low usage on 2026-03-30
# explore: assets_with_duplicate_ids {
#   case_sensitive: no
# }
explore: crockett_revenue {
  case_sensitive: no
}
explore: rental_rev_earned_btw_dt {
  case_sensitive: no
}

# Commented out due to low usage on 2026-03-30
# explore: inventory_balance{
#   case_sensitive: no
# }
explore: recently_added_schedules{
  case_sensitive: no
}
explore: t3_revenue_support{
  case_sensitive: no
}
explore: t3_revenue_support_low{
  case_sensitive: no
}
explore: t3_revenue_support_all{
  case_sensitive: no
}
explore: t3_revenue_support_data{
  case_sensitive: no
}
explore: 6b_copy{
  case_sensitive: no
}
explore: po_lifecycle_postings {
  case_sensitive: no
}
