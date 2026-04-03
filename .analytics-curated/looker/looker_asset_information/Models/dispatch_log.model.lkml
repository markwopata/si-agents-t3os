connection: "es_snowflake"

include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ANALYTICS/delivery_facilitator_types.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/PLATFORM/v_assets.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/delivery_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/delivery_types.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/PLATFORM/v_locations.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"

explore: deliveries {
  group_label: "Dispatch Log"
  label: "Delivery Log of all delivery types"
  case_sensitive: no
  sql_always_where: ${rentals.rental_status_id} <> 8 AND ${deliveries.date_created_date} >= DATE_TRUNC('month', DATEADD('year', -1, CURRENT_DATE))  ;;


  join: delivery_facilitator_types {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.facilitator_type_id} = ${delivery_facilitator_types.delivery_facilitator_type_id} ;;
  }
  join: delivery_statuses {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.delivery_status_id} = ${delivery_statuses.delivery_status_id} ;;
  }
  join: delivery_types {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.delivery_type_id} = ${delivery_types.delivery_type_id} ;;
  }
  join: orders {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.order_id} = ${orders.order_id} ;;
  }
  join: v_markets {
    type: inner
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${v_markets.market_id} ;;
  }
  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${orders.company_id} = ${companies.company_id} ;;
  }
  join: v_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${deliveries.asset_id} = ${v_assets.asset_id} ;;
  }
  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.rental_id} = ${rentals.rental_id} ;;
  }
  join: rental_statuses {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }
  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${deliveries.driver_user_id} = ${users.user_id} ;;
  }
  join: origin_location {
    type: left_outer
    from: v_locations
    relationship: many_to_one
    sql_on: ${deliveries.origin_location_id} = ${origin_location.location_id} ;;
  }
  join: destination_location {
    type: left_outer
    from: v_locations
    relationship: many_to_one
    sql_on: ${deliveries.location_id} = ${destination_location.location_id} ;;
  }
}
