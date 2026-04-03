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
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: deleted {
    type: yesno
    sql: ${TABLE}.deleted ;;
  }
  measure: count {
    type: count
  }
}
