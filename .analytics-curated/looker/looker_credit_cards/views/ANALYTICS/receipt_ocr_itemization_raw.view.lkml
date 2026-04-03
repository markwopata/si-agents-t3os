view: receipt_ocr_itemization_raw {
  sql_table_name: "CREDIT_CARD"."RECEIPT_OCR_ITEMIZATION_RAW" ;;

  dimension: gas_pump_flag {
    type: yesno
    sql: ${TABLE}."GAS_PUMP_FLAG" ;;
  }
  dimension: handwritten_confidence {
    type: number
    sql: ${TABLE}."HANDWRITTEN_CONFIDENCE" ;;
  }
  dimension: handwritten_flag {
    type: yesno
    sql: ${TABLE}."HANDWRITTEN_FLAG" ;;
  }
  dimension: image_evaluation {
    type: string
    sql: ${TABLE}."IMAGE_EVALUATION" ;;
  }
  dimension: image_quality {
    type: number
    sql: ${TABLE}."IMAGE_QUALITY" ;;
  }
  dimension: image_url {
    type: string
    sql: ${TABLE}."IMAGE_URL" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: ocr_data_raw {
    type: string
    sql: ${TABLE}."OCR_DATA_RAW" ;;
  }
  dimension: purchase_id {
    type: number
    sql: ${TABLE}."PURCHASE_ID" ;;
  }
  dimension_group: submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SUBMITTED_AT" ;;
  }
  dimension: transaction_merchant_name {
    type: string
    sql: ${TABLE}."TRANSACTION_MERCHANT_NAME" ;;
  }
  dimension_group: upload {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPLOAD_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [transaction_merchant_name]
  }
}
