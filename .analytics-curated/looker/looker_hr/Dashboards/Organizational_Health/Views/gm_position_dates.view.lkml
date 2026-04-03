view: gm_position_dates {
  sql_table_name: "GREENHOUSE"."GM_POSITION_DATES"
    ;;

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: position_start_date {
    type: date
    sql: TO_DATE(${TABLE}."POSITION_START_DATE", 'MM/DD/YY') ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_name, market_name]
  }
}
