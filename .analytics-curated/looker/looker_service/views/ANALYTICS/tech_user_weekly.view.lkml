view: tech_user_weekly {
  sql_table_name: "ANALYTICS"."PUBLIC"."TECH_USER_WEEKLY"
    ;;

  dimension: admin_id {
    type: number
    sql: ${TABLE}."ADMIN_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension_group: first_wo_completed {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIRST_WO_COMPLETED" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: ${TABLE}."FULL_EMPLOYEE_NAME" ;;
  }

  dimension_group: last_wo_completed {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_WO_COMPLETED" ;;
  }

  dimension: paycor_id {
    type: number
    sql: ${TABLE}."PAYCOR_ID" ;;
  }

  dimension: report_end_date {
    type: string
    sql: ${TABLE}."REPORT_END_DATE" ;;
  }

  dimension_group: report_run {
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
    sql: CAST(${TABLE}."REPORT_RUN_DATE" AS TIMESTAMP_NTZ) ;;
  }


  dimension: report_start_date {
    type: string
    sql: ${TABLE}."REPORT_START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [full_employee_name]
  }
}
