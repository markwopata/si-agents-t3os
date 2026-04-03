include: "/_base/people_analytics/looker/vehicle_tracking_employee_detail.view.lkml"

view: +vehicle_tracking_employee_detail {

  ############### DIMENSIONS ###############
  dimension: asset_id {
    value_format_name: id
  }
  dimension: user_id {
    value_format_name: id
  }
  dimension: employee_id {
    value_format_name: id
  }
  dimension: current_period_taxable_fringe {
    value_format: "$#,##0.00"
  }
  dimension: year {
    value_format_name: id
  }
  dimension: personal_mileage {
    value_format_name: decimal_2
  }
  dimension: business_mileage {
    value_format_name: decimal_2
  }
  dimension: total_mileage {
    value_format_name: decimal_2
  }
  dimension: vehicle_cost {
    value_format: "$#,##0.00"
  }
  dimension: asset_annual_lease_value {
    value_format: "$#,##0.00"
  }

  ############### DATES ###############
  dimension_group: start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${start};;
  }
  dimension_group: end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${end};;
  }
  dimension_group: purchase_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${purchase};;
  }

  ############### DRILL FIELDS ###############
  set: taxable_fringe_drills {
    fields: [employee_id,
      user_id,
      first_name,
      last_name,
      asset_id,
      year,
      make,
      model,
      start_date_date,
      end_date_date,
      days_with_vehicle,
      years_day,
      calendar_day_proration,
      personal_mileage,
      business_mileage,
      total_mileage,
      personal_use_percentage,
      purchase_date_date,
      vehicle_cost,
      asset_annual_lease_value,
      current_period_personal_use_lease_value,
      current_period_personal_use_fuel,
      current_period_taxable_fringe]
  }
}
