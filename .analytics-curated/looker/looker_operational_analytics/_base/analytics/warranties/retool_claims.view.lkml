view: retool_claims {
  sql_table_name: "ANALYTICS"."WARRANTIES"."RETOOL_CLAIMS" ;;

  dimension: child_invoice_no {
    type: string
    sql: ${TABLE}."CHILD_INVOICE_NO" ;;
  }
  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }
  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension: credited {
    type: yesno
    sql: ${TABLE}."CREDITED" ;;
  }
  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }
  dimension: dispute_id {
    type: number
    sql: ${TABLE}."DISPUTE_ID" ;;
  }
  dimension: disputed {
    type: yesno
    sql: ${TABLE}."DISPUTED" ;;
  }
  dimension: fully_denied {
    type: yesno
    sql: ${TABLE}."FULLY_DENIED" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: modification_note {
    type: string
    sql: ${TABLE}."MODIFICATION_NOTE" ;;
  }
  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }
  dimension_group: modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."MODIFIED_DATE" ;;
  }
  dimension_group: review {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."REVIEW_DATE" ;;
  }
  dimension: review_id {
    type: number
    sql: ${TABLE}."REVIEW_ID" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
  }
}
