view: apbillpayment {
  sql_table_name: "INTACCT"."APBILLPAYMENT" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: invbaseamt {
    type: number
    sql: ${TABLE}."INVBASEAMT" ;;
  }
  dimension: invtrxamt {
    type: number
    sql: ${TABLE}."INVTRXAMT" ;;
  }
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: paiditemkey {
    type: number
    sql: ${TABLE}."PAIDITEMKEY" ;;
  }
  dimension: parentpymt {
    type: number
    sql: ${TABLE}."PARENTPYMT" ;;
  }
  dimension: payitemkey {
    type: number
    sql: ${TABLE}."PAYITEMKEY" ;;
  }
  dimension_group: paymentdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENTDATE" ;;
  }
  dimension: paymentkey {
    type: number
    sql: ${TABLE}."PAYMENTKEY" ;;
  }
  dimension: recordkey {
    type: number
    sql: ${TABLE}."RECORDKEY" ;;
  }
  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: trx_amount {
    type: number
    sql: ${TABLE}."TRX_AMOUNT" ;;
  }
  dimension_group: whencreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENCREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: whenmodified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
