connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: dealership_parts_transactions {
  label: "Dealership Parts Transactions"

  join: dealership_market_map {
    type: inner
    relationship: many_to_one
    sql_on: ${dealership_parts_transactions.market_id} = ${dealership_market_map.market_id}::text ;;
  }

  join: dealership_parts_detail {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dealership_parts_transactions.part_id} = ${dealership_parts_detail.part_id} ;;
  }
}

explore: dealership_parts_inventory {
  label: "Dealership Parts Inventory"

  join: dealership_market_map {
    type: inner
    relationship: many_to_one
    sql_on: ${dealership_parts_inventory.market_id} = ${dealership_market_map.market_id}::text ;;
  }

  join: dealership_parts_detail {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dealership_parts_inventory.part_id} = ${dealership_parts_detail.part_id} ;;
  }
}

explore: dealership_service_revenue {
  label: "Dealership Service Revenue"

   join: dealership_parts_transactions {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dealership_service_revenue.line_item_id}::text = ${dealership_parts_transactions.line_item_id}::text ;;
  }

  join: dealership_market_map {
    type: inner
    relationship: many_to_one
    sql_on: ${dealership_service_revenue.market_id} = ${dealership_market_map.market_id}::text ;;
  }
}

explore: dealership_service_hours {
  label: "Dealership Service Hours"

  join: dealership_market_map {
    type: inner
    relationship: many_to_one
    sql_on: ${dealership_service_hours.market_id} = ${dealership_market_map.market_id}::text ;;
  }
}
