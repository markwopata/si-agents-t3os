connection: "es_warehouse"
#testing
#testing pull

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: orders {
  group_label: "Rentals"
  label: "DelekUS Rentals"
  description: "Used for DelekUS Rentals"
  case_sensitive: no
  sql_always_where: ${assets.asset_id} in (select asset_id from table(assetlist(57398)))
  OR
  ${assets.asset_id} in (select asset_id from table(rental_asset_list(57398, convert_timezone('UTC', 'America/Chicago', current_date::timestamp_ntz), convert_timezone('America/Chicago', 'UTC', current_date::timestamp_ntz), 'America/Chicago')));;
  # ${asset_id} in ${rental_asset_list_10_days.asset_id}
  # ${assets.asset_id} in (select asset_id from table(assetlist(57398))) ;;

  join: rentals {
    type:  inner
    relationship:  many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: admin_cycle {
    type: left_outer
    relationship: one_to_one
    sql_on: ${admin_cycle.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} AND ${line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: equipment_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
  }

  join: remaining_rental_cost {
    type: left_outer
    relationship: one_to_one
    sql_on: ${remaining_rental_cost.rental_id} = ${rentals.rental_id} ;;
  }

}
