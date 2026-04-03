view: concur_invoice_audit_trail_approval_workflow {
  sql_table_name: "CONCUR_GOLD"."CONCUR_INVOICE_AUDIT_TRAIL_APPROVAL_WORKFLOW" ;;

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
  }
  dimension: delegate_name {
    type: string
    sql: ${TABLE}."DELEGATE_NAME" ;;
  }
  dimension: fk_request_key {
    type: number
    sql: ${TABLE}."FK_REQUEST_KEY" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: name_employee_assigned_to_step {
    type: string
    sql: ${TABLE}."NAME_EMPLOYEE_ASSIGNED_TO_STEP" ;;
  }
  dimension: next_step {
    type: string
    sql: ${TABLE}."NEXT_STEP" ;;
  }
  dimension: pk_workflow_instance_key {
    type: number
    sql: ${TABLE}."PK_WORKFLOW_INSTANCE_KEY" ;;
  }
  dimension: status_upon_step_completion {
    type: string
    sql: ${TABLE}."STATUS_UPON_STEP_COMPLETION" ;;
  }
  dimension: step_name {
    type: string
    sql: ${TABLE}."STEP_NAME" ;;
  }
  dimension: step_role {
    type: string
    sql: ${TABLE}."STEP_ROLE" ;;
  }
  dimension: step_sequence {
    type: number
    sql: ${TABLE}."STEP_SEQUENCE" ;;
  }
  dimension_group: timestamp_step_action {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_STEP_ACTION") ;;
  }
  measure: count {
    type: count
    drill_fields: [step_name, delegate_name]
  }
}
