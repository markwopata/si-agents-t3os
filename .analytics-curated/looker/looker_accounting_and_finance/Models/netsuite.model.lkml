connection: "prod_financial_systems"

include: "/views/FINANCIAL_SYSTEMS__PROD/netsuite_gold/netsuite__t3_tooling_inventory.view.lkml"

explore: netsuite__t3_tooling_inventory {
  label: "netsuite__t3_tooling_inventory"
  view_name: "netsuite__t3_tooling_inventory"
}


include: "/views/FINANCIAL_SYSTEMS__PROD/netsuite_silver/stg_analytics_netsuite__locations.view.lkml"

explore: stg_analytics_netsuite__locations {
  label: "stg_analytics_netsuite__locations"
  view_name: "stg_analytics_netsuite__locations"
}
