view: daily_work_order_info {
  sql_table_name: "SERVICE"."DAILY_WORK_ORDER_INFO" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: asset_ownership {
    type: string
    sql: ${TABLE}."ASSET_OWNERSHIP" ;;
  }
  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }
  dimension: cause_group {
    type: string
    sql: ${TABLE}."CAUSE_GROUP" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }
  dimension: complaint_group {
    type: string
    sql: ${TABLE}."COMPLAINT_GROUP" ;;
  }
  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }
  dimension: correction_group {
    type: string
    sql: ${TABLE}."CORRECTION_GROUP" ;;
  }
  dimension_group: date_billed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: expense {
    type: number
    sql: ${TABLE}."EXPENSE" ;;
    value_format_name: usd
  }
  dimension_group: the_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }
  dimension: hours_cost {
    type: number
    sql: ${TABLE}."HOURS_COST" ;;

    value_format_name: usd
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: originator_type {
    type: string
    sql: ${TABLE}."ORIGINATOR_TYPE" ;;
  }
  dimension: overtime_hour {
    type: number
    sql: ${TABLE}."OVERTIME_HOUR" ;;
  }
  dimension: parts_cost {
    type: number
    sql: ${TABLE}."PARTS_COST" ;;
    value_format_name: usd
  }
  dimension: parts_qty {
    type: number
    sql: ${TABLE}."PARTS_QTY" ;;
  }
  dimension: problem_group {
    type: string
    sql: ${TABLE}."PROBLEM_GROUP" ;;
  }
  dimension: regular_hour {
    type: number
    sql: ${TABLE}."REGULAR_HOUR" ;;
  }
  dimension: sub_category {
    type: string
    sql: ${TABLE}."SUB_CATEGORY" ;;
  }
  dimension: total_hours {
    type: number
    sql: ${TABLE}."TOTAL_HOURS" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE_NAME" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [work_order_type_name]
  }
  measure: sum_expense {
    type: sum
    sql: ${expense} ;;
    value_format_name: usd
  }
  measure: sum_total_hours {
    type: sum
    sql: ${total_hours} ;;
  }
  measure: sum_parts_cost {
    type: sum
    sql: ${parts_cost} ;;
    value_format_name: usd
  }
  measure: sum_parts_quantity {
    type: sum
    sql: ${parts_qty} ;;
  }
}
