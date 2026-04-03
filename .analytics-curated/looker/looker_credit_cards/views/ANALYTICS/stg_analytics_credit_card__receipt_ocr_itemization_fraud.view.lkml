view: stg_analytics_credit_card__receipt_ocr_itemization_fraud {
  sql_table_name: "CREDIT_CARD"."STG_ANALYTICS_CREDIT_CARD__RECEIPT_OCR_ITEMIZATION_FRAUD" ;;

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: fraud_confidence {
    type: number
    sql: ${TABLE}."FRAUD_CONFIDENCE" ;;
  }
  dimension: fraud_flag {
    type: yesno
    sql: ${TABLE}."FRAUD_FLAG" ;;
  }
  dimension: fraud_reasoning {
    type: string
    sql: ${TABLE}."FRAUD_REASONING" ;;
  }
  dimension: image_url {
    type: string
    sql: ${TABLE}."IMAGE_URL" ;;
    html: {% assign clean = value | remove: '\"' | strip %} <a href='{{ clean }}' target='_blank'>{{ clean }}</a>;;
  }
  dimension: item_text {
    type: string
    sql: ${TABLE}."ITEM_TEXT" ;;
  }
  dimension: line_idx {
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_IDX" ;;
  }
  dimension: line_notes {
    type: string
    sql: ${TABLE}."LINE_NOTES" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: need_further_review {
    type: yesno
    sql: ${TABLE}."NEED_FURTHER_REVIEW" ;;
  }
  dimension: purchase_id {
    type: string
    sql: ${TABLE}."PURCHASE_ID" ;;
  }
  dimension_group: submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SUBMITTED_AT" ;;
  }
  dimension_group: upload {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPLOAD_DATE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: count {
    type: count
  }
}
