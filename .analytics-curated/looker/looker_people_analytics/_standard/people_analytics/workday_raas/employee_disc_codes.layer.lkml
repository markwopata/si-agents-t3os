include: "/_base/people_analytics/workday_raas/employee_disc_codes.view.lkml"


view: +employee_disc_codes {
  label: "Employee Disc Codes"

  ############### DIMENSIONS ###############

  dimension: employee_id {
    value_format_name: id
    description: "Employee ID used to differentiate employees in Workday"
  }

  dimension: greenhouse_application_id {
    value_format_name: id
    description: "Application ID of the employee in Greenhouse"
  }


  ############### DATES ###############

  dimension_group: fivetran_synced {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${fivetran_synced} ;;
  }

  dimension_group: date_hired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_hired} ;;
  }

  dimension_group: date_terminated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_terminated} ;;
  }
}
