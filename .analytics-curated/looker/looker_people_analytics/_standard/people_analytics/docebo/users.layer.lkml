include: "/_base/people_analytics/docebo/users.view.lkml"

view: +users {

  ########## DIMENSIONS ##########
  dimension: employee_id_corrected {
    value_format_name: id
    description: "Employee IDs with the CW replaced with an empty string"
    sql: REPLACE(${employee_id},'CW','') ;;
  }
  ########## DATES ##########

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${_fivetran_synced} ;;
  }

  dimension_group: last_access_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${last_access} ;;
  }

  dimension_group: hire_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${hire_date} ;;
  }

  dimension_group: last_update_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${last_update} ;;
  }

  dimension_group: creation_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${creation_date} ;;
  }

  dimension_group: job_last_changed_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_last_changed_date} ;;
  }
}
