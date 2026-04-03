view: payment_count {
  sql_table_name: "ANALYTICS"."TREASURY"."PAYMENT_COUNT" ;;

  ############# DIMENSIONS #############

  dimension: document_or_check_number {
    type: string
    sql: ${TABLE}."DOCUMENT_OR_CHECK_NUMBER" ;;
  }

  dimension_group: payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  ############# MEASURES #############

  measure: check_count {
    value_format_name: decimal_0
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."CHECK_COUNT" ;;
  }

  measure: payment_count {
    value_format_name:  decimal_0
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."PAYMENT_COUNT" ;;
  }

  measure: percent_check_count {
    value_format_name:  percent_2
    type: number
    drill_fields: [trx_details*]
    sql: IFF(${payment_count}=0,0,${check_count}/${payment_count}) ;;
  }

  measure: payment_amount {
    label: "Total Spend"
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

############# DRILL FIELDS #############

  set: trx_details {
    fields: [vendor_id,vendor_name,payment_date,payment_type,payment_status,document_or_check_number,payment_amount,check_count,payment_amount]
    }

}
