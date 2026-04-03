include: "/_base/procurement/public/purchase_order_line_items.view.lkml"

view: +purchase_order_line_items {
  label: "Purchase Order Line Items"

  measure: outside_pos {
    type: sum
    sql: ${total_accepted} * ${price_per_unit} ;;
    value_format_name: usd
  }
}
