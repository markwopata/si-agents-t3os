view: pay_periods {
  sql_table_name: "ANALYTICS"."PAYROLL"."PAY_PERIODS"
    ;;

  dimension_group: pay_date_from {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAY_DATE_FROM" ;;
  }

  dimension_group: pay_date_to {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAY_DATE_TO" ;;
  }

  dimension_group: paycheck_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."PAYCHECK_DATE" ;;
  }

  dimension: comm_check_date {
    type: yesno
    sql: ${TABLE}."COMM_CHECK_DATE" ;;
  }

  dimension: pay_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PAY_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
