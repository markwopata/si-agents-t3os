include: "/_base/es_warehouse/time_tracking/time_entries.view.lkml"

view: +time_entries {
  label: "Time Entries"

  dimension: total_hours {
    type: number
    sql: ${regular_hours} + ${overtime_hours} ;;
  }

  dimension: labor_cost {
    type: number
    sql: ${total_hours} * 175 ;;
    value_format_name: usd
  }
  dimension: warranty_labor_cost {
    type: number
    sql: ${total_hours} * 100 ;;
    value_format_name: usd
  }
  measure: total_total_hours {
    type: sum
    sql: ${total_hours} ;;
    value_format_name: decimal_2
  }

  measure: total_labor_cost {
    type: sum
    sql: ${labor_cost} ;;
    value_format_name: usd
  }

  measure: warranty_total_labor_cost {
    type: sum
    sql: ${warranty_labor_cost} ;;
    value_format_name: usd
  }

  measure: last_labor_completed {
    type: date
    sql: max(${end_raw}) ;;
  }
}
