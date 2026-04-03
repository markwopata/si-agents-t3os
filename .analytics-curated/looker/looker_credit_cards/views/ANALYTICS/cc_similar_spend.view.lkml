view: cc_similar_spend {
  sql_table_name: "PUBLIC"."CC_SIMILAR_SPEND"
    ;;

  dimension: cardholder_name {
    type: string
    sql: ${TABLE}."CARDHOLDER_NAME" ;;
  }

  dimension: employee_number_one {
    type: string
    sql: ${TABLE}."EMPLOYEE_NUMBER_ONE" ;;
  }

  dimension: employee_number_two {
    type: string
    sql: ${TABLE}."EMPLOYEE_NUMBER_TWO" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: full_name_one {
    type: string
    sql: ${TABLE}."FULL_NAME_ONE" ;;
  }

  dimension: full_name_two {
    type: string
    sql: ${TABLE}."FULL_NAME_TWO" ;;
  }

  dimension: merchant_name_one {
    type: string
    sql: ${TABLE}."MERCHANT_NAME_ONE" ;;
  }

  dimension: merchant_name_two {
    type: string
    sql: ${TABLE}."MERCHANT_NAME_TWO" ;;
  }

  dimension: transaction_amount_one {
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT_ONE" ;;
  }

  dimension: transaction_amount_two {
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT_TWO" ;;
  }

  dimension_group: transaction_date_one {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TRANSACTION_DATE_ONE" ;;
  }

  dimension_group: transaction_date_two {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TRANSACTION_DATE_TWO" ;;
  }

  measure: count {
    type: count
    drill_fields: [cardholder_name]
  }
}
