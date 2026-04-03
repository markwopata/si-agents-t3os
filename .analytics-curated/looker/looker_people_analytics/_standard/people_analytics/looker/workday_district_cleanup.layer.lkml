include: "/_base/people_analytics/looker/workday_district_cleanup.view.lkml"

view: +workday_district_cleanup {

  dimension: employee_id {
    value_format_name: id
  }

  # dimension: full_name {
  #   type: string
  #   sql: ${TABLE}."FULL_LEGAL_NAME" ;;
  # }

  dimension: market_id {
    value_format_name: id
  }

  # dimension: market_name {
  #   type: string
  #   sql: ${TABLE}."MARKET_NAME" ;;
  # }

  # dimension: workday_district {
  #   type: string
  #   sql: ${TABLE}."WORKDAY_DISTRICT" ;;
  # }

  # dimension: organization_district {
  #   type: string
  #   sql: ${TABLE}."ORGANIZATION_DISTRICT" ;;
  # }
  dimension_group: date_hired {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_hired} ;;
  }
  dimension_group: date_rehired {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_rehired} ;;
  }
  dimension_group: date_terminated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_terminated} ;;
  }
  # dimension: employee_status {
  #   type: string
  #   sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  # }
}
