include: "/_base/people_analytics/looker/base_compensation_history.view.lkml"


view: +base_compensation_history {
  label: "Base Compensation History"


  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }

  # dimension: increase {
  #   type: number
  #   sql: CAST(RTRIM(REPLACE(${"%_INCREASE"}, '''', ''), '%') AS INTEGER) ;;
  # }

  # dimension: increase {
  #   type: number
  #   sql: try_to_number(RTRIM(REPLACE(${TABLE}."%_INCREASE", '''', ''), '%'))
  #   sql_where: ${TABLE}."%_INCREASE" != nan ;;
  # }
  dimension: increase {
    type: number
    sql: CASE
         WHEN ${TABLE}."%_INCREASE" = 'nan' THEN NULL
         ELSE TRY_CAST(REPLACE(${TABLE}."%_INCREASE", '%', '') AS INTEGER) / 100.0
       END ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd_0
  }

  # dimension: amount_per {
  #   type: string
  #   sql: ${TABLE}."AMOUNT_PER" ;;
  #   description: ""
  # }

  dimension: annual_salary {
    type: number
    value_format_name: usd_0
    sql: ${annual} ;;
  }

  dimension_group: first_payroll {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: CAST(${first_payroll} AS TIMESTAMP_NTZ);;
  }

  # dimension: employee_id {
  #   value_format_name: id
  # }

  # dimension: employee_status {
  #   type: string
  #   sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  # }

  # dimension: first_name {
  #   type: string
  #   sql: ${TABLE}."FIRST_NAME" ;;
  # }

  # dimension: last_name {
  #   type: string
  #   sql: ${TABLE}."LAST_NAME" ;;
  # }

  # dimension: primary_key {
  #   primary_key: yes
  #   type: number
  #   sql: concat(${employee_id}, ${increase}, ${first_payroll} ;;
  #   }

  # dimension: reason_code {
  #   type: string
  #   sql: ${TABLE}."REASON_CODE" ;;
  # }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }

  measure: max_annual_salary {
    type: max
    sql: ${annual_salary} ;;
    value_format_name: usd_0
  }

  measure: min_annual_salary {
    type: min
    sql: ${annual_salary} ;;
    value_format_name: usd_0
  }

  measure: total_amount {
    type:  sum
    sql: try_to_number(${amount}) ;;
    drill_fields: [first_name, last_name]
  }
}
