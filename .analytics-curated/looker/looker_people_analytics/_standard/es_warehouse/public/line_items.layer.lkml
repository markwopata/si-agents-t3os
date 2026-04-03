include: "/_base/es_warehouse/public/line_items.view.lkml"

view: +line_items {
  label: "Line Items"

  dimension_group: _es_update_timestamp {
    label: "_ES Update Timestamp"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${_es_update_timestamp} ;;
    description: "_es update timestamp"
  }

  dimension_group: date_updated {
    label: "Date Updated"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_updated} ;;
    description: "date_updated"
  }

  dimension_group: date_created {
    label: "Date Created"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_created} ;;
    description: "date_created"
  }



}
