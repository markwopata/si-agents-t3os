view: fact_work_order_lines {
  sql_table_name: "PLATFORM"."GOLD"."V_WORK_ORDER_LINES" ;;

  dimension: work_order_line_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_KEY" ;;
    hidden: yes
  }

  dimension: work_order_line_source {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_SOURCE" ;;
  }

  dimension: work_order_line_work_order_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_WORK_ORDER_KEY" ;;
    hidden: yes
  }

  dimension: work_order_line_date_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: work_order_line_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_TYPE" ;;
  }

  dimension: work_order_line_part_key {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_PART_KEY" ;;
    description: "FK to dim_parts"
  }

  measure: work_order_line_number_of_units {
    type: number
    sql: ${TABLE}."WORK_ORDER_LINE_NUMBER_OF_UNITS" ;;
    value_format_name: decimal_2
  }

  measure: work_order_line_amount {
    type: number
    sql: ${TABLE}."WORK_ORDER_LINE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: work_order_line_recordtimestamp {
    type: string
    sql: ${TABLE}."WORK_ORDER_LINE_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
