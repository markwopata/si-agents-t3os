view: new_customers_rolling_90_days {
  sql_table_name: "PUBLIC"."NEW_CUSTOMERS_ROLLING_90_DAYS"
    ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: created_day {
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
    sql: ${TABLE}."CREATED_DAY" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: first_rental {
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
    sql: ${TABLE}."FIRST_RENTAL_START_DATE" ;;
  }
  dimension: rental_ind {
    type: number
    sql: ${TABLE}."RENTAL_IND" ;;
  }

  dimension: company_count {
    type: number
    sql: ${TABLE}."COMPANY_COUNT" ;;
  }

  measure: total_companies {
    type: sum
    sql: ${company_count} ;;
  }

  measure: total_rented_companies {
    type: sum
    sql: ${rental_ind} ;;
  }

  measure: rolling_90_day_ratio {
    type: number
    value_format_name: decimal_0
    drill_fields: [company_id, company_name, market_name,salesperson,date_created_date,first_rental_date]
    sql: (coalesce(${total_rented_companies},0)/(case when ${total_companies} = 0 then null else (coalesce(${total_companies},0)*1.0) end))*100 ;;
  }

}
