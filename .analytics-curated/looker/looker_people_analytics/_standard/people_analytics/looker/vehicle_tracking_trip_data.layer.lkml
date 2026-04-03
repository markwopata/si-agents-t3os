include: "/_base/people_analytics/looker/vehicle_tracking_trip_data.view.lkml"

view: +vehicle_tracking_trip_data {

  ############### DIMENSIONS ###############
  dimension: trip_tax_classification_id {
    value_format_name: id
  }
  dimension: trip_id {
    value_format_name: id
  }
  dimension: asset_id {
    value_format_name: id
  }
  dimension: start_address_zip {
    value_format_name: id
  }
  dimension: end_address_zip {
    value_format_name: id
  }
  dimension: user_id {
    value_format_name: id
  }
  dimension: employee_id {
    value_format_name: id
  }

  ############### DATES ###############
  dimension_group: trip_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${trip};;
  }
  dimension_group: approval_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${approval};;
  }
  dimension_group: report_start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${report_start};;
  }
  dimension_group: report_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${report_end};;
  }
  dimension_group: lower_bound {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${lower_bound};;
  }
  dimension_group: upper_bound {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${upper_bound};;
  }
}
