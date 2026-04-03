view: pending_branch_approval {
  sql_table_name: "ANALYTICS"."CONCUR"."PENDING_BRANCH_APPROVAL"
    ;;

  dimension: cost_object_approver {
    type: string
    sql: ${TABLE}.COST_OBJECT_APPROVER ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: invoice_number{
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.PO_NUMBER ;;
  }

  dimension: latest_submit_date {
    type: date
    sql: ${TABLE}.LATEST_SUBMIT_DATE ;;
  }

  dimension: days_pending_approval {
    type: number
    value_format: "#;(#);-"
    sql: ${TABLE}.DAYS_PENDING_APPROVAL ;;
  }

  dimension: branch_name {
    type: string
    label: "Location"
    sql: ${TABLE}.BRANCH_NAME ;;
  }

  dimension: expense_type_name {
    type: string
    sql: ${TABLE}.EXPENSE_TYPE_NAME  ;;
  }

  measure: request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: requested_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}."REQUESTED_TOTAL" ;;
  }


  measure: count {
    type: count
    drill_fields: [drill_details*]
  }

  measure: cost_object_approver_count {
    type: count_distinct
    label: "Count of Cost Object Approver"
    value_format: "#;(#);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}.COST_OBJECT_APPROVER ;;
  }

  set: drill_details {
    fields: [cost_object_approver, employee_id, invoice_number, vendor_id,vendor_name, po_number, latest_submit_date, days_pending_approval, branch_name, expense_type_name,
      request_total, requested_total
    ]
  }

  }
