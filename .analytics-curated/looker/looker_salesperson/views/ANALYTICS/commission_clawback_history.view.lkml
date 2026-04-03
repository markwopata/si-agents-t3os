view: commission_clawback_history {
  sql_table_name: "COMMISSION_CLAWBACKS"."COMMISSION_CLAWBACK_HISTORY"
    ;;

  dimension: billing_approved_date {
    type: string
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: clawback_amount {
    type: number
    sql: ${TABLE}."CLAWBACK_AMOUNT" ;;
  }

  dimension: clawback_date {
    type: string
    sql: ${TABLE}."CLAWBACK_DATE" ;;
  }

  dimension: clawback_eligible {
    type: yesno
    sql: ${TABLE}."CLAWBACK_ELIGIBLE" ;;
  }

  dimension: clawback_month {
    type: string
    sql: ${TABLE}."CLAWBACK_MONTH" ;;
  }

  dimension: commission_eligible {
    type: yesno
    sql: ${TABLE}."COMMISSION_ELIGIBLE" ;;
  }

  dimension: commission_month {
    type: string
    sql: ${TABLE}."COMMISSION_MONTH" ;;
  }

  dimension: commission_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMMISSION_PAID" ;;
  }

  dimension: exception {
    type: yesno
    sql: ${TABLE}."EXCEPTION" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: paid_date {
    type: string
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: reimbursement_amount {
    type: number
    sql: ${TABLE}."REIMBURSEMENT_AMOUNT" ;;
  }

  dimension: reimbursement_eligible {
    type: yesno
    sql: ${TABLE}."REIMBURSEMENT_ELIGIBLE" ;;
  }

  dimension: reimbursement_month {
    type: string
    sql: ${TABLE}."REIMBURSEMENT_MONTH" ;;
  }

  dimension: revenue_amount {
    type: number
    sql: ${TABLE}."REVENUE_AMOUNT" ;;
  }

  dimension: salesperson_type_id {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [salesperson_user_id]
  }

  measure: clawback_total {
    type: sum
    sql: ${clawback_amount};;
    #filters: [clawback_eligible: "Yes"]
    value_format_name: usd
    drill_fields: [branch_id,salesperson_user_id,clawback_month]
  }

  measure: reimbursement_total {
    type: sum
    sql: ${reimbursement_amount};;
    #filters: [reimbursement_eligible: "Yes"]
    value_format_name: usd
    drill_fields: [branch_id,salesperson_user_id,reimbursement_month]
  }

}
