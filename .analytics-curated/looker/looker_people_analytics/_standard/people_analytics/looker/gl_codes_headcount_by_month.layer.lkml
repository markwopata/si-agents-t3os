include: "/_base/people_analytics/looker/gl_codes_headcount_by_month.view.lkml"

view: +gl_codes_headcount_by_month {

  ############### DIMENSIONS ###############
  dimension: gl_account_no {
    value_format_name: id
  }
  dimension: employee_id {
    value_format_name: id
  }

  ############### DATES ###############
  dimension_group: date_month {
    type: time
    timeframes: [month]
    sql: ${date_month};;
  }

  ############### MEASURES ###############
  measure: count_distinct_employee_id {
    type: count_distinct
    sql: ${employee_id} ;;
    drill_fields: [drills*]
  }

  ############### DRILL FIELDS ###############
  set: drills {
    fields: [employee_id,
      first_name,
      last_name,
      employee_title,
      location]
  }

}
