view: commission_clawback_history {
  sql_table_name: "COMMISSION_CLAWBACKS"."COMMISSION_CLAWBACK_HISTORY"
    ;;


  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  measure: clawback_amount {
    type: sum
    value_format_name: usd
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

  measure: commission_paid {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."COMMISSION_PAID" ;;
  }

  dimension: date_created {
    type: string
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: exception {
    type: yesno
    sql: ${TABLE}."EXCEPTION" ;;
  }

  dimension: invoice_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: paid_date {
    type: string
    sql: ${TABLE}."PAID_DATE" ;;
  }

  measure: reimbursement_amount {
    type: sum
    value_format_name: usd
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

  dimension: salesperson_type_id {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  measure: revenue_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE_AMOUNT" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
