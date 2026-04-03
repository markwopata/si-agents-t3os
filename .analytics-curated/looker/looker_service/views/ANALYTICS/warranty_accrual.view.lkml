view: warranty_accrual {
  sql_table_name: "WARRANTIES"."WARRANTY_ACCRUAL" ;;

  dimension: average_labor_billed {
    type: number
    sql: ${TABLE}."AVERAGE_LABOR_BILLED" ;;
  }
  dimension: average_parts_billed {
    type: number
    sql: ${TABLE}."AVERAGE_PARTS_BILLED" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: date_completed {
    type: string
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }
  dimension: date_created {
    type: string
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: estimated_labor_accrual {
    type: number
    sql: ${TABLE}."ESTIMATED_LABOR_ACCRUAL" ;;
  }
  dimension: estimated_parts_accrual {
    type: number
    sql: ${TABLE}."ESTIMATED_PARTS_ACCRUAL" ;;
  }
  dimension: identifier {
    type: string
    sql: ${TABLE}."IDENTIFIER" ;;
  }
  dimension: multiplier {
    type: number
    sql: ${TABLE}."MULTIPLIER" ;;
  }
  dimension: report_month {
    type: string
    sql: ${TABLE}."REPORT_MONTH" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
  }
}
