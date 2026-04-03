view: appaymethod {
  sql_table_name: "INTACCT"."APPAYMETHOD" ;;

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_DATE" ;;
  }
  dimension_group: last_changed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_CHANGED_DATE" ;;
  }
  dimension: pay_method_desc {
    type: string
    sql: ${TABLE}."PAY_METHOD_DESC" ;;
  }
  dimension: paymethodrec {
    type: number
    sql: ${TABLE}."PAYMETHODREC" ;;
  }
  measure: count {
    type: count
  }
}
