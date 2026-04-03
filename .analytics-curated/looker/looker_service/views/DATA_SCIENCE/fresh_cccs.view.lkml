view: fresh_cccs {
  sql_table_name: "DATA_SCIENCE"."WOKB"."FRESH_CCCS" ;;

  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension_group: extraction {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EXTRACTION_DATE" ;;
  }
  dimension: extraction_type {
    type: string
    sql: ${TABLE}."EXTRACTION_TYPE" ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  # measure: count {
  #   type: count
  # }
}
