connection: "es_snowflake_analytics"

include: "/views/FINOPS_ACCTS/warranty_accounts.view.lkml"
include: "/views/FINOPS_ACCTS/revenue_to_goal.view.lkml"
include: "/views/FINOPS_ACCTS/parts_inventory_oec.view.lkml"
include: "/views/FINOPS_ACCTS/parts_write_offs.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: warranty_accounts {}

# Commented out due to low usage on 2026-03-27
# explore: revenue_to_goal {}

# Commented out due to low usage on 2026-03-27
# explore: parts_inventory_oec {}

# Commented out due to low usage on 2026-03-27
# explore: parts_write_offs {
#   join: market_region_xwalk {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${parts_write_offs.market_id}=${market_region_xwalk.market_id} ;;
#   }
# }
