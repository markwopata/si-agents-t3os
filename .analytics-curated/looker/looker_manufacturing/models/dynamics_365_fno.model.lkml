connection: "es_snowflake_analytics"

# MBY PURCHASING ANALYTICS VIEWS
include: "/custom_sql/purchase_order_headers_mby.view.lkml"
include: "/custom_sql/purchase_order_lines_mby.view.lkml"

# MBY PURCHASING ANALYTICS
explore: purchase_order_lines_mby {
  label: "purchase_order_lines_mby"
  case_sensitive: no

  join: purchase_order_headers_mby {
    type: left_outer
    relationship: one_to_one
    sql_on: ${purchase_order_lines_mby.PO_NUMBER} = ${purchase_order_headers_mby.PO_NUMBER};;
  }
}
