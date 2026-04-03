include: "/_base/procurement/public/purchase_orders.view.lkml"

view: +purchase_orders {
  label: "Purchase Orders"

  measure: count_pos {
    type: count_distinct
    sql: ${purchase_order_id} ;;
  }
}
