view: pending_branch_approval {
  sql_table_name: "CONCUR"."PENDING_BRANCH_APPROVAL" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }
  dimension_group: cognos {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COGNOS_DATE" ;;
  }
  dimension: cost_object_approver {
    type: string
    sql: ${TABLE}."COST_OBJECT_APPROVER" ;;
  }
  dimension: days_pending_approval {
    type: number
    sql: ${TABLE}."DAYS_PENDING_APPROVAL" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: expense_type_name {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE_NAME" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension_group: latest_submit {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LATEST_SUBMIT_DATE" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }
  dimension: requested_total {
    type: number
    sql: ${TABLE}."REQUESTED_TOTAL" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [branch_name, expense_type_name, vendor_name]
  }
}
