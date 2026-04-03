include: "/_base/analytics/corporate_budget/budget_sub_departments.view.lkml"


view: +budget_sub_departments {

  ############### DIMENSIONS ###############
  dimension: sub_department_id {
    value_format_name: id
  }

  dimension: cost_capture_id {
    value_format_name: id
  }

  dimension: division {
    type: string
    sql: SPLIT_PART(${cost_center_string},'/','1') ;;
  }

  dimension: region {
    type: string
    sql: SPLIT_PART(${cost_center_string},'/','2') ;;
  }

  dimension: district {
    type: string
    sql: SPLIT_PART(${cost_center_string},'/','3') ;;
  }

  ############### DATES ###############
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_fivetran_synced} ;;
  }
}
