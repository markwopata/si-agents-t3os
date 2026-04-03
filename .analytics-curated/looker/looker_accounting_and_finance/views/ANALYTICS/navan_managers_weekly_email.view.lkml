view: navan_managers_weekly_email {
  sql_table_name: "ANALYTICS"."TREASURY"."NAVAN_MANAGERS_WEEKLY_EMAIL" ;;

  ###### DIMENSIONS ######

  dimension_group: booking_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BOOKING_END_DATE" ;;
  }

  dimension_group: booking_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BOOKING_START_DATE" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PURCHASED" ;;
  }

  dimension: booking_status {
    type: string
    sql: ${TABLE}."BOOKING_STATUS" ;;
  }



  dimension: key {
    type: string
    sql: ${TABLE}."KEY" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}."MANAGER_NAME" ;;
  }

  dimension: out_of_policy_violation {
    type: string
    sql: ${TABLE}."OUT_OF_POLICY_VIOLATION" ;;
  }

  dimension: per_day_price {
    value_format_name: usd
    type: string
    sql: ${TABLE}."PER_DAY_PRICE" ;;
  }

  dimension: total_price {
    value_format_name: usd
    type: number
    sql: ${TABLE}."TOTAL_PRICE" ;;
  }

  dimension: traveled_cabin_class {
    type: string
    sql: ${TABLE}."TRAVELED_CABIN_CLASS" ;;
  }

  dimension: traveling_user_emails {
    type: string
    sql: ${TABLE}."TRAVELING_USER_EMAILS" ;;
  }

  dimension: traveling_users {
    type: string
    sql: ${TABLE}."TRAVELING_USERS" ;;
  }

  dimension: trip_name {
    type: string
    sql: ${TABLE}."TRIP_NAME" ;;
  }

  dimension: trip_purpose {
    type: string
    sql: ${TABLE}."TRIP_PURPOSE" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: is_manager  {
    type: yesno
    sql:  (${department} = 'National Tooling Solutions' AND '{{ _user_attributes['email'] }}' = 'brandon.wilson@equipmentshare.com') OR
          (${manager_email} = '{{ _user_attributes['email'] }}') OR
          ('{{ _user_attributes['email'] }}' in (
        'paul.logue@equipmentshare.com',
        'lisa.evans@equipmentshare.com',
        'sam.giroux@equipmentshare.com',
        'joanna.kollmeyer@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'sonya.collier@equipmentshare.com',
        'sarah.cooley@equipmentshare.com',
        'katie.cunningham@equipmentshare.com',
        'jabbok@equipmentshare.com'
        )) ;;
  }


  ###### MEASURES ######

}
