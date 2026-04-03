view: retool_warranty {
  sql_table_name: "ANALYTICS"."WARRANTIES"."RETOOL_WARRANTY" ;;

  dimension: child_invoice_no {
    type: string
    sql: ${TABLE}."CHILD_INVOICE_NO" ;;
  }
  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }
  dimension: credited {
    type: yesno
    sql: ${TABLE}."CREDITED" ;;
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
  dimension_group: last_review {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_REVIEW_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: last_review_email {
    type: string
    sql: ${TABLE}."LAST_REVIEW_EMAIL" ;;
  }
  dimension: last_review_user_id {
    type: number
    sql: ${TABLE}."LAST_REVIEW_USER_ID" ;;
  }
  dimension: review_id {
    type: number
    sql: ${TABLE}."REVIEW_ID" ;;
  }
  dimension: warranty_state {
    type: string
    sql: ${TABLE}."WARRANTY_STATE" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
  }
}
