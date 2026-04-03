include: "/_base/analytics/branch_earnings/parent_market.view.lkml"

view: +parent_market {
  label: "Parent Market"

  dimension: parent_market_id {
    value_format_name: id
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: coalesce(${end},'2099-12-31'::date) ;;
  }
  dimension: market_id {
    value_format_name: id
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${start} ;;
  }
  # measure: count {
  #   type: count
  #   drill_fields: [parent_market_id]
  # }
}
