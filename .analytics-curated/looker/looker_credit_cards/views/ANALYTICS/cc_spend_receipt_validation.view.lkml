view: cc_spend_receipt_validation {
  sql_table_name: "GS"."CC_SPEND_RECEIPT_VALIDATION"
    ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: action_code {
    type: string
    sql: ${TABLE}."ACTION_CODE" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: employee_email_address {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: reason_code {
    type: string
    sql: ${TABLE}."REASON_CODE" ;;
  }

  dimension: receipt_amount {
    type: number
    sql: ${TABLE}."RECEIPT_AMOUNT" ;;
  }

  dimension: receipt_amt {
    type: number
    sql: ${TABLE}."RECEIPT_AMT" ;;
  }

  dimension: receipt_image {
    type: string
    sql: ${TABLE}."RECEIPT_IMAGE" ;;
  }

  dimension: receipt_notes {
    type: string
    sql: ${TABLE}."RECEIPT_NOTES" ;;
  }

  dimension_group: receipt_upload {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RECEIPT_UPLOAD_DATE" ;;
  }

  dimension: transaction_amount {
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT" ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  dimension: tx_amt {
    type: number
    sql: ${TABLE}."TX_AMT" ;;
  }

  dimension_group: tx {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TX_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_name, name]
  }
}
