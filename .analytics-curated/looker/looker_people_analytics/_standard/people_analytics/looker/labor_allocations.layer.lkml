include: "/_base/people_analytics/looker/labor_allocations.view.lkml"

view: +labor_allocations {

  dimension_group: snapshot_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${snapshot_timestamp} ;;
    description: "When the records were updated."
  }

  parameter: timeframe_picker {
    label: "Effective Date"
    type: date

  }
}
