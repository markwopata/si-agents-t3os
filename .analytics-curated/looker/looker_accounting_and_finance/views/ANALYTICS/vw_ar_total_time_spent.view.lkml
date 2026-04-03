view: vw_ar_total_time_spent {
  sql_table_name: "ANALYTICS"."TREASURY"."VW_AR_TOTAL_TIME_SPENT" ;;

##### DIMENSIONS #####

  dimension: key {
    type: string
    sql: ${posted_user_id} || '-' ||  ${entered_date}::date ;;
  }

  dimension: ach_count {
    type: number
    sql: ${TABLE}."ACH_COUNT" ;;
  }

  dimension: ach_time_per_payment {
    type: number
    sql: ${TABLE}."ACH_TIME_PER_PAYMENT" ;;
  }

  dimension: checks_count {
    type: number
    sql: ${TABLE}."CHECKS_COUNT" ;;
  }

  dimension: checks_time_per_payment {
    type: number
    sql: ${TABLE}."CHECKS_TIME_PER_PAYMENT" ;;
  }

  dimension: combined_hours {
    type: number
    sql: ${TABLE}."COMBINED_HOURS" ;;
  }

  dimension: credit_cash_count {
    type: number
    sql: ${TABLE}."CREDIT_CASH_COUNT" ;;
  }

  dimension: credit_cash_time_per_payment {
    type: number
    sql: ${TABLE}."CREDIT_CASH_TIME_PER_PAYMENT" ;;
  }

  dimension_group: entered {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ENTERED" ;;
  }

  dimension: hours_evaluation {
    type: string
    sql: ${TABLE}."HOURS_EVALUATION" ;;
  }

  dimension: manual_hours {
    type: number
    sql: ${TABLE}."MANUAL_HOURS" ;;
  }

  dimension: posted_name {
    type: string
    sql: ${TABLE}."POSTED_NAME" ;;
  }

  dimension: posted_user_id {
    type: number
    sql: ${TABLE}."POSTED_USER_ID" ;;
  }

  dimension: total_time_spent {
    type: number
    sql: ${TABLE}."TOTAL_TIME_SPENT" ;;
  }

  dimension: user_email_address {
    type: string
    sql: ${TABLE}."USER_EMAIL_ADDRESS" ;;
  }

  dimension: is_user  {
    type: yesno
    sql: ${user_email_address} = '{{ _user_attributes['email'] }}' OR
         ('{{ _user_attributes['email'] }}' in (
        'ryan.stevens@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'lisa.evans@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'jabbok@equipmentshare.com',
        'angie.wallace@equipmentshare.com',
        'jenny.sperry@equipmentshare.com',
        'kris@equipmentshare.com'
       )) ;;
  }

  ##### MEASURES #####

  measure:  hours_evaluation_count {
    value_format_name: decimal_0
    type: count
  }

}
