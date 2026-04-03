connection: "es_snowflake"

include: "/views/ANALYTICS/asset_swaps.view.lkml"
include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/PLATFORM/v_markets.view.lkml"
include: "/views/ANALYTICS/rentals_with_swaps.view.lkml"
include: "/views/ANALYTICS/int_equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/work_order_company_tags.view.lkml"
include: "/views/ES_WAREHOUSE/company_tags.view.lkml"
include: "/views/ANALYTICS/cccs.view.lkml"
include: "/views/ANALYTICS/ccc_entries.view.lkml"

explore: rentals {
  group_label: "Rentals with Swaps"
  sql_always_where: ${rentals.start_date} >= DATE('2025-01-01') ;;
  join: rentals_with_swaps {
    relationship: many_to_one
    type: left_outer
    sql_on: ${rentals.rental_id} = ${rentals_with_swaps.rental_id} ;;
  }

  join: int_equipment_assignments {
    relationship: one_to_many
    sql_on: ${rentals_with_swaps.rental_id} = ${int_equipment_assignments.rental_id} ;;
  }


  join: deliveries {
    relationship: many_to_one
    type: left_outer

    sql_on:
    ${int_equipment_assignments.drop_off_delivery_id} = ${deliveries.delivery_id}
  ;;
  }

  join: work_orders {
    relationship: many_to_many
    type: left_outer
    view_label: "Work Order Details"

    sql_on:
    ${work_orders.asset_id} = ${int_equipment_assignments.asset_id}

          /* enforce: WO must be after delivery */
          AND ${work_orders.date_created_raw} >= ${deliveries.completed_date}

      AND ${work_orders.date_created_raw} <
      CASE
      WHEN ${rentals.rental_status_id} = 5
      THEN DATEADD(day, 2, ${int_equipment_assignments.asset_end})
      ELSE ${rentals.end_raw}
      END
      ;;
  }

  join: work_order_company_tags {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_company_tags.work_order_id} ;;
  }

  join: company_tags {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  }

  join: cccs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${cccs.work_order_id} ;;
  }

  join: ccc_entries {
    view_label: "Work Order CCCs"
    type: left_outer
    relationship: many_to_one
    sql_on: ${cccs.ccc_id} = ${ccc_entries.ccc_id} ;;
  }

  join: rental_statuses {
    relationship: one_to_one
    type: inner
    sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
  }

  join: orders {
    relationship: one_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
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
