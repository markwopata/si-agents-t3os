view: pending_cost_object_by_expense_type {
  sql_table_name: "ANALYTICS"."TREASURY"."PENDING_COST_OBJECT_BY_EXPENSE_TYPE"
    ;;

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


  dimension: latest_submit_date {
    type: date
    sql: ${TABLE}."LATEST_SUBMIT_DATE" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: timestamp {
    type: date
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [pending_details*]
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: total_requested {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [pending_details*]
    sql: ${TABLE}."TOTAL_REQUESTED" ;;
  }

  measure: count {
    type: count
    value_format: "#,##0"
    drill_fields: [pending_details*]
  }

  set: pending_details {
    fields: [cost_object_approver,employee_id,invoice_number,vendor_name,po_number,latest_submit_date,days_pending_approval,location,expense_type_name,timestamp,
                  request_total, total_requested]
  }


}
