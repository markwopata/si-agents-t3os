connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/late_deliveries_test.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/ANALYTICS/rentals_with_swaps.view.lkml"
include: "/views/ANALYTICS/int_equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"

explore: delivery_timeliness {

  from: deliveries
  sql_always_where: ${completed_date} >= DATE('2025-01-01') ;;
  join: late_deliveries_test {
    relationship: one_to_one
    sql_on: ${delivery_timeliness.delivery_id} = ${late_deliveries_test.delivery_id} ;;
  }

  join: orders {
    relationship: one_to_one
    sql_on: ${delivery_timeliness.order_id} = ${orders.order_id} ;;
  }
  join: v_markets {
    relationship: many_to_one
    sql_on: ${orders.market_id} =  ${v_markets.market_id};;
  }

  join: companies {
    relationship: one_to_many
    sql_on: ${orders.company_id} = ${companies.company_id} ;;
  }
}
