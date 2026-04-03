include: "/_base/analytics/monday/master_markets.view.lkml"

view: +master_markets {

  ############### DIMENSIONS ###############


  dimension: board_id {
    value_format_name: id
    description: "Id for the monday board. This will match what's in the url."
  }
  dimension: item_id {
    value_format_name: id
    description: "Unique id for the item. An item is a row in a board."
  }
  dimension: market_id {
    value_format_name: id
    description: "Market ID of the branch, if null then they are not ready for hire"
  }

  ############### DATES ###############

  dimension_group: actual_first_rental_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${actual_first_rental_date};;
  }
  dimension_group: basic_operational_readiness_completed_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${basic_operational_readiness_completed_date};;
  }
  dimension_group: basic_operational_readiness_target_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${basic_operational_readiness_target_date};;
  }
  dimension_group: due_dilligence_end_date {
    type: time
    description: "This date indicates when we need a TAM hired by"
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${due_diligence_end_date};;
  }
  dimension_group: close_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${close_date};;
  }
  dimension_group: last_updated_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${last_updated_date};;
  }
  dimension_group: possession_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${possession_date};;
  }
  dimension_group: target_construction_completion_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${target_construction_completion_date};;
  }
  dimension_group: washbay_completion_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${washbay_completion_date};;
  }
}
