view: phoenix_id_types {
  sql_table_name: "DEBT"."PHOENIX_ID_TYPES"
    ;;

  dimension: financial_lender_id {
    type: number
    sql: ${TABLE}."FINANCIAL_LENDER_ID" ;;
  }

  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }

  dimension: funded {
    type: number
    sql: ${TABLE}."FUNDED" ;;
  }

  dimension: lender {
    type: string
    sql: ${TABLE}."LENDER" ;;
  }

  dimension: phoenix_id {
    type: number
    sql: ${TABLE}."PHOENIX_ID" ;;
  }

  dimension: sage_account_number {
    type: string
    sql: ${TABLE}."SAGE_ACCOUNT_NUMBER" ;;
  }

  dimension: sage_lender_id {
    type: string
    sql: ${TABLE}."SAGE_LENDER_ID" ;;
  }

  dimension: sage_loan_id {
    type: string
    sql: ${TABLE}."SAGE_LOAN_ID" ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
