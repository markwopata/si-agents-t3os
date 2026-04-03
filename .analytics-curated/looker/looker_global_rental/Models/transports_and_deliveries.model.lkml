connection: "es_warehouse_global"

include: "/views/ES_WAREHOUSE/*.view.lkml"
include: "/views/ES_WAREHOUSE_GLOBAL/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

explore: transport_details {
  label: "RentOps Transport Details"
  group_label: "Global Transports Information"
  case_sensitive: no
  sql_always_where: ${transport_details.transport_status} <> 'Cancelled' ;;

  join: line_items {
    type: left_outer
    relationship: one_to_one
    sql_on: ${transport_details.transport_id} = ${line_items.transport_id};;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${line_items.invoice_id} = ${invoices.id};;
  }

  join: rental_details {
    type: left_outer
    relationship: many_to_many
    sql_on: ${rental_details.rental_id} = ${transport_details.rental_id}  ;;
  }

  join: asset_class_customer_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.asset_id} = ${asset_class_customer_branch.asset_id} ;;
  }

  }

explore: transport_month_series {
  label: "RentOps Transport Scheduled Completed Counts"
  group_label: "Global Transports Information"
  case_sensitive: no
  }
