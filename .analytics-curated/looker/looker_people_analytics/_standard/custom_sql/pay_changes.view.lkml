view: pay_changes {
  derived_table: {sql:
    WITH gp AS (
    SELECT employee_id,
    LAST_VALUE(first_name) OVER (PARTITION BY employee_id ORDER BY DATE_FROM) AS first_name,
    LAST_VALUE(last_name) OVER (PARTITION BY employee_id ORDER BY DATE_FROM)  AS last_name,
    DATE_FROM                                           AS effective_date,
    REPLACE("%_INCREASE", '''', '') AS INCREASE,
    RANK() OVER (PARTITION BY employee_id, INCREASE ORDER BY _es_update_timestamp) AS change_num
    FROM PEOPLE_ANALYTICS.LOOKER.BASE_COMPENSATION_HISTORY cd_v
    WHERE employee_id IS NOT NULL
    QUALIFY change_num = 1)
    , gp2 AS (SELECT employee_id,
    first_name,
    last_name,
    effective_date,
    INCREASE as current_increase,
    LEAD(INCREASE, 1) OVER (PARTITION BY employee_id ORDER BY effective_date DESC) AS previous_increase
    FROM gp
    WHERE employee_id IS NOT NULL
    AND CURRENT_INCREASE !='nan'
    ORDER BY effective_date)
    SELECT
    employee_id,
    first_name,
    last_name,
    effective_date,
    RTRIM(current_increase, '%') as current_increase,
    RTRIM(previous_increase, '%') as previous_increase
    FROM gp2
    ;;}

  dimension: primary_key {
    primary_key: yes
    type: number
    sql: concat(${TABLE}."EMPLOYEE_ID", ${TABLE}."CURRENT_INCREASE", ${TABLE}."PREVIOUS_INCREASE", ${TABLE}."EFFECTIVE_DATE") ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id


  }

  dimension: current_increase {
    type: number
    sql: CAST(${TABLE}."CURRENT_INCREASE" as INTEGER)/100;;
    value_format_name: percent_2
  }

  dimension_group: pay_change_effective_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: cast(${TABLE}."EFFECTIVE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_12_month_pay_changes {
    type: yesno
    sql: ${pay_change_effective_date_date} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
      and ${pay_change_effective_date_date} <= dateadd('second',-1,date_trunc('month',current_date));;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: prior_increase {
    type: number
    sql: CAST(${TABLE}."PREVIOUS_INCREASE" as INTEGER)/100;;
    value_format_name: percent_2
  }

  dimension: promotion {
    type: yesno
    sql: ${job_changes.effective_date_month} = ${pay_change_effective_date_month} ;;
  }

  measure: total_count {
    type: count_distinct
    sql: ${employee_id};;
    drill_fields: [pay_change_effective_date_date,
      employee_id,
      first_name,
      last_name,
      current_increase,
      prior_increase]
  }

  measure: average_increase {
    type: average
    sql: ${TABLE}."CURRENT_INCREASE" / 100.00;;
    value_format_name: percent_2
  }

  measure: average_previous_increase {
    type: average
    sql: ${TABLE}."PREVIOUS_INCREASE" / 100.00 ;;
    value_format_name: percent_3
  }

  set: detail {
    fields: [employee_id, first_name, last_name, current_increase, prior_increase, pay_change_effective_date_date, pay_change_effective_date_month, pay_change_effective_date_week, total_count]
  }

}
