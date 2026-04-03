include: "/_base/analytics/branch_earnings/market.view.lkml"




view: +market {

  ############### DATES ###############
  dimension_group: date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_updated};;
  }

  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${branch_earnings_start_month};;
  }

  dimension_group: market_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${market_start_month};;
  }

  ############### DIMENSIONS ###############
  dimension: child_market_id {
    value_format_name: id
  }

  dimension: market_id {
    value_format_name: id
  }

  dimension: area_code {
    value_format_name: id
  }

  dimension: _id_dist {
    value_format_name: id
  }

  dimension: market_type_id {
    value_format_name: id
  }

  dimension: general_manager_employee_id {
    value_format_name: id
  }

  dimension: zip_code {
    value_format_name: id
  }
}
