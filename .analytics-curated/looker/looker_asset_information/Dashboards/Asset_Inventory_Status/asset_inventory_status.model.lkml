connection: "es_snowflake_analytics"

# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project


include: "/views/SCD/*.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/Dashboards/Asset_Inventory_Status/Views/*.view.lkml"

# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"


# Commented out — 0 queries in 90 days, no dashboard or Look ties
# explore: asset_inventory_status {
#
#
# }
