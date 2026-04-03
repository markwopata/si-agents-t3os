include: "/_base/analytics/public/line_item_types.view.lkml"

view: +line_item_types {

  dimension: name {
    label: "Line Item Type"
    type:  string
    sql: ${TABLE}."NAME" ;;
  }

}
