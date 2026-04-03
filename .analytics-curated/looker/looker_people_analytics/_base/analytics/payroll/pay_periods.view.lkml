view: pay_periods {
  sql_table_name: "ANALYTICS"."PAYROLL"."PAY_PERIODS" ;;

  dimension: comm_check_date {
    type: yesno
    sql: ${TABLE}."COMM_CHECK_DATE" ;;
  }
  dimension: pay_date_from {
    type: date_raw
    sql: ${TABLE}."PAY_DATE_FROM" ;;
    hidden: yes
  }
  dimension: pay_date_to {
    type: date_raw
    sql: ${TABLE}."PAY_DATE_TO" ;;
    hidden: yes
  }
  dimension: pay_id {
    type: number
    sql: ${TABLE}."PAY_ID" ;;
  }
  dimension: paycheck {
    type: date_raw
    sql: ${TABLE}."PAYCHECK_DATE" ;;
    hidden: yes
  }
  measure: count {
    type: count
  }
}
