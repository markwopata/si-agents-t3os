include: "/_base/people_analytics/looker/compensation_details.view.lkml"

view: +compensation_details {



  dimension_group: pay_period_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${pay_period_start};;
    description: "Start date for pay period."
  }


  dimension_group: pay_period_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${pay_period_end};;
    description: "End date for pay period."
  }

  dimension_group: pay_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${pay_date};;
    description: "Pay date for pay period."
  }

  dimension_group: position_effective_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${position_effective_date};;
    description: "Effective Date of their position."
  }

  measure: employee_distinct_count {
    type: count_distinct
    sql: ${employee_id} ;;
    drill_fields: [first_name, last_name, employee_id, total_debit, total_credit, total_amount]
  }

  measure: total_debit {
    type: sum
    sql: ${debit};;
    value_format_name: usd

  }

  measure: total_credit {
    type: sum
    sql: ${credit} ;;
    value_format_name: usd_0
  }

  measure: total_amount {
    type: sum
    sql:CASE WHEN ${debit} IS NULL THEN 0 ELSE ${debit} END - CASE WHEN  ${credit} IS NULL THEN 0 ELSE ${credit} END ;;
    value_format_name: usd_0
  }

}
