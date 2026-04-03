connection: "es_warehouse"

include: "/views/*.view.lkml"
include: "/views/work_orders_by_branch/*.view.lkml"

explore: work_orders_by_branch {
  group_label: "Work Orders"
  label: "Work Orders By Branch"
  case_sensitive: no

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${work_orders_by_branch.work_order_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${work_orders.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

}
