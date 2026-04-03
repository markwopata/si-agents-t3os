view: epay_vendor_first_set {
  sql_table_name: "ANALYTICS"."PL_DBT"."GOLD_EPAY_VENDOR_FIRST_SET" ;;

  ########## DIMENSIONS ##########



  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}."ALT_PAY_METHOD" ;;
  }

  dimension: first_set_date {
    type: date
    sql: ${TABLE}."FIRST_SET_DATE" ;;
  }


  dimension: payment_date {
    type: date
    sql: ${first_set_date} ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension_group: month {
    type: time
    timeframes: [month]
    sql:  last_day(${first_set_date}::date) ;;
  }



########## MEASURES ##########

  measure: vendor_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [vendor_details*]
    sql: ${vendor_id} ;;
}

  ############## DRILL FIELDS ##############
  set: vendor_details {
    fields: [vendor_id,vendor_name,first_set_date]
  }

}
