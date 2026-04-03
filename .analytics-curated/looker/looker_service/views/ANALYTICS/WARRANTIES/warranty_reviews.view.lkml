view: warranty_reviews {
  sql_table_name: "ANALYTICS"."WARRANTIES"."WARRANTY_REVIEWS" ;;

  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }
  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension: created_by_email {
    type: string
    sql: ${TABLE}."CREATED_BY_EMAIL" ;;
  }
  dimension: engine_tag {
    type: string
    sql: ${TABLE}."ENGINE_TAG" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${TABLE}."IS_CURRENT" ;;
  }
  dimension: note_added {
    type: string
    sql: ${TABLE}."NOTE_ADDED" ;;
  }
  dimension: pre_file_denial_code {
    type: string
    sql: ${TABLE}."PRE_FILE_DENIAL_CODE" ;;
  }
  dimension_group: review {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."REVIEW_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: review_id {
    type: number
    sql: ${TABLE}."REVIEW_ID" ;;
  }
  dimension: t3_updated_correct {
    type: yesno
    sql: ${TABLE}."T3_UPDATED_CORRECT" ;;
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
