view: pay_changes {
  derived_table: {sql:
       WITH gp AS (
                  SELECT employee_id,
                         LAST_VALUE(first_name) OVER (PARTITION BY employee_id ORDER BY DATE_FROM) AS first_name,
                         LAST_VALUE(last_name) OVER (PARTITION BY employee_id ORDER BY DATE_FROM)  AS last_name,
                         DATE_TRUNC('minute', DATE_FROM)                                           AS effective_date,
                         REPLACE("%_INCREASE", '''', '') AS INCREASE,
                         RANK() OVER (PARTITION BY employee_id, INCREASE ORDER BY _es_update_timestamp) AS change_num
                    FROM PEOPLE_ANALYTICS.LOOKER.BASE_COMPENSATION_HISTORY cd_v
                   WHERE employee_id IS NOT NULL
                 QUALIFY change_num = 1)
SELECT employee_id,
       first_name,
       last_name,
       effective_date,
       INCREASE as current_increase,
       LEAD(INCREASE, 1) OVER (PARTITION BY employee_id ORDER BY effective_date DESC) AS previous_increase
  FROM gp
 WHERE employee_id IS NOT NULL
 AND CURRENT_INCREASE !='nan'
 ORDER BY effective_date
 ;;}

  dimension: primary_key {
    primary_key: yes
    type: number
    sql: concat(${TABLE}."EMPLOYEE_ID", ${TABLE}."CURRENT_INCREASE", ${TABLE}."PREVIOUS_INCREASE", ${TABLE}."EFFECTIVE_DATE") ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;


  }

  dimension: current_increase {
    type: string
    sql: ${TABLE}."CURRENT_INCREASE" ;;
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

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: prior_increase {
    type: string
    sql: ${TABLE}."PREVIOUS_INCREASE" ;;
  }



  measure: total_count {
    type: count
    sql: ${employee_id} ;;
    #drill_fields: [source,amount]
  }

  measure: average_increase {
    type: average
    sql: ${TABLE}."CURRENT_INCREASE" ;;
  }

  measure: average_previous_increase {
    type: average
    sql: ${TABLE}."PREVIOUS_INCREASE" ;;
  }

  set: detail {
    fields: [employee_id, first_name, last_name, current_increase, prior_increase, pay_change_effective_date_date, pay_change_effective_date_month, pay_change_effective_date_week, total_count]
  }

}
