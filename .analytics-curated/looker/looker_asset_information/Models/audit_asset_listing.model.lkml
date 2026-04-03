connection: "es_snowflake_analytics"

include: "/views/custom_sql/audit_asset_listing.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"


explore: audit_asset_listing {
  group_label: "Asset Listing"
  label: "Audit Asset Listing"
  case_sensitive: no

  join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${market_region_xwalk.market_id}=${audit_asset_listing.market_id} ;;
  }

  join: companies {
      type: left_outer
      relationship: many_to_one
      sql_on: ${audit_asset_listing.company_id}=${companies.company_id} ;;
  }
}
