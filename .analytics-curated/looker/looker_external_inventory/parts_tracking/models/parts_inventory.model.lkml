connection: "es_warehouse"

include: "/parts_tracking/views/transactions.view.lkml"
include: "/parts_tracking/views/parts.view.lkml"
include: "/parts_tracking/views/part_types.view.lkml"
include: "/parts_tracking/views/part_categories.view.lkml"
include: "/parts_tracking/views/users.view.lkml"
include: "/parts_tracking/views/stores.view.lkml"
include: "/parts_tracking/views/store_parts.view.lkml"
include: "/parts_tracking/views/transaction_types.view.lkml"
include: "/parts_tracking/views/transaction_statuses.view.lkml"




explore: transactions {
  group_label: "Inventory Tracking"
  case_sensitive: no
  sql_always_where: ${stores.company_id} = 7978 ;;

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions.part_id} = ${parts.part_id} ;;
  }

  join: part_types {
    type: inner
    relationship: many_to_one
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }

  join: part_categories {
    type: left_outer
    relationship: one_to_one
    sql_on: ${part_types.part_category_id} = ${part_categories.part_category_id} ;;
  }

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions.created_by} = ${users.user_id} ;;
  }

  join: stores {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions.store_id} = ${stores.store_id} ;;
  }

  join: store_parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions.store_id} = ${store_parts.store_id} and ${transactions.part_id} = ${store_parts.part_id};;
  }

  join: transaction_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${transactions.transaction_type_id} = ${transaction_types.transaction_type_id} ;;
  }

  join: transaction_statuses {
    type: inner
    relationship: many_to_one
    sql_on: ${transactions.transaction_status_id} = ${transaction_statuses.transaction_status_id} ;;
  }

}
