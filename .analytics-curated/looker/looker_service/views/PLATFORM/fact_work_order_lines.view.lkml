view: fact_work_order_lines {
  sql_table_name: "PLATFORM"."GOLD"."FACT_WORK_ORDER_LINES" ;;

  dimension: work_order_line_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WORK_ORDER_LINE_AMOUNT" ;;
  }
  measure: total_line_amount {
    type: sum
    value_format_name: usd
    sql: ${work_order_line_amount} ;;
  }
  dimension: work_order_line_date_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_DATE_KEY" ;;
  }
  dimension: work_order_line_key {
    type: string
    primary_key: yes
    sql: ${TABLE}."WORK_ORDER_LINE_KEY" ;;
  }
  dimension: work_order_line_number_of_units {
    type: number
    sql: ${TABLE}."WORK_ORDER_LINE_NUMBER_OF_UNITS" ;;
  }
  dimension: work_order_line_part_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_PART_KEY" ;;
  }
  dimension: work_order_line_part_master_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_PART_MASTER_KEY" ;;
  }
  dimension_group: work_order_line_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."WORK_ORDER_LINE_RECORDTIMESTAMP" ;;
  }
  dimension: work_order_line_source {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_SOURCE" ;;
  }
  dimension: work_order_line_time_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_TIME_KEY" ;;
  }
  dimension: work_order_line_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_TYPE" ;;
  }
  dimension: work_order_line_wac_snapshot_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_WAC_SNAPSHOT_KEY" ;;
  }
  dimension: work_order_line_work_order_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_WORK_ORDER_KEY" ;;
  }
  measure: count {
    type: count
  }
  measure: total_parts_cost {
    type: sum
    value_format_name: usd
    sql: ${work_order_line_amount} ;;
    filters: [work_order_line_type: "Parts"]
  }
}
