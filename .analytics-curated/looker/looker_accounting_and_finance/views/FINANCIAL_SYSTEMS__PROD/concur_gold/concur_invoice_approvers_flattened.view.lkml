view: concur_invoice_approvers_flattened {
  sql_table_name: "CONCUR_GOLD"."CONCUR_INVOICE_APPROVERS_FLATTENED" ;;

  dimension: approval_level {
    type: string
    sql: ${TABLE}."APPROVAL_LEVEL" ;;
  }
  dimension: approver {
    type: string
    sql: ${TABLE}."APPROVER" ;;
  }
  dimension: delegate_approver {
    type: string
    sql: ${TABLE}."DELEGATE_APPROVER" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: name_request {
    type: string
    sql: ${TABLE}."NAME_REQUEST" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: pk_request_key {
    type: number
    sql: ${TABLE}."PK_REQUEST_KEY" ;;
  }
  dimension_group: timestamp_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_APPROVED" ;;
  }
  measure: count {
    type: count
  }
  dimension: approval_rank {
    type: number
    sql:
    CASE
      WHEN ${TABLE}.approval_level = 'GL Approval >=5K' THEN 1
      WHEN ${TABLE}.approval_level = 'GL Approval >=10K' THEN 2
      WHEN ${TABLE}.approval_level = 'GL Approval >=25K' THEN 3
    END ;;
  }
}
