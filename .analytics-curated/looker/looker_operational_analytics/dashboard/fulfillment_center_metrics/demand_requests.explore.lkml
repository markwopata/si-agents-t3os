include: "/_standard/inventory/inventory/demand_requests.layer.lkml"
include: "/_standard/inventory/inventory/demand_request_line_items.layer.lkml"
include: "/_base/es_warehouse/inventory/inventory_locations.view.lkml"
include: "/_base/analytics/public/market_region_xwalk.view.lkml"
include: "/_base/es_warehouse/inventory/parts.view.lkml"
include: "/_base/es_warehouse/inventory/part_types.view.lkml"
include: "/_base/inventory/inventory/reservation_target_types.view.lkml"
include: "/_base/analytics/parts_inventory/fulfillment_parts_attributes.view.lkml"
include: "/_standard/es_warehouse/public/users.view.lkml"

explore: demand_requests {
  label: "Demand Requests"
  description: "Demand requests with line items, target type lookup, part, and requesting inventory location details."

  join: demand_request_line_items {
    type: inner
    sql_on: ${demand_requests.demand_request_id} = ${demand_request_line_items.demand_request_id} ;;
    relationship: one_to_many
  }

  join: inventory_locations {
    type: left_outer
    sql_on: ${demand_requests.requesting_inventory_id} = ${inventory_locations.inventory_location_id} ;;
    relationship: many_to_one
  }

  join: market_region_xwalk {
    type: left_outer
    sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
    relationship: many_to_one
  }

  join: parts {
    type: left_outer
    sql_on: ${demand_request_line_items.product_id} = ${parts.part_id} ;;
    relationship: many_to_one
  }

  join: part_types {
    type: left_outer
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
    relationship: many_to_one
  }

  join: reservation_target_types {
    type: left_outer
    sql_on: ${demand_request_line_items.target_type_id} = ${reservation_target_types.reservation_target_type_id};;
    relationship: many_to_one
  }

  join: fulfillment_parts_attributes {
    type: left_outer
    sql_on:
    ${demand_request_line_items.product_id} = ${fulfillment_parts_attributes.part_id}
    AND ${fulfillment_parts_attributes.end_date} = '2999-01-01' ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on:  ${demand_requests.completed_by_user_id} = ${users.user_id} ;;
    relationship: many_to_one
  }
}
