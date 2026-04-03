view: company_rental_rates {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_RENTAL_RATES" ;;
  drill_fields: [company_rental_rate_id]

  dimension: company_rental_rate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_RENTAL_RATE_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_voided {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_VOIDED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: rate_end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    # sql:CAST(IFF(${TABLE}."DATE_CREATED"<${TABLE}."END_DATE" AND ${TABLE}."DATE_VOIDED">${TABLE}."END_DATE", ${TABLE}."END_DATE", IFF(${TABLE}."DATE_CREATED">${TABLE}."END_DATE",IFNULL(${TABLE}."DATE_VOIDED",'9999-12-31'),IFNULL(${TABLE}."DATE_VOIDED",IFNULL(${TABLE}."END_DATE",'9999-12-31')))) AS TIMESTAMP_NTZ);;
    sql:CAST(IFF(CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ)<CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) AND CAST(${TABLE}."DATE_VOIDED" AS TIMESTAMP_NTZ)>CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ), CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ), IFF(CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ)>CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ),IFNULL(CAST(${TABLE}."DATE_VOIDED" AS TIMESTAMP_NTZ),'9999-12-31'),IFNULL(CAST(${TABLE}."DATE_VOIDED" AS TIMESTAMP_NTZ),IFNULL(CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ),'9999-12-31')))) AS TIMESTAMP_NTZ);;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }
  dimension: price_per_day {
    type: number
    sql: coalesce(${TABLE}."PRICE_PER_DAY",null) ;;
  }
  dimension: price_per_hour {
    type: number
    sql: coalesce(${TABLE}."PRICE_PER_HOUR",null) ;;
  }
  dimension: price_per_month {
    type: number
    sql: coalesce(${TABLE}."PRICE_PER_MONTH",null) ;;
  }
  dimension: price_per_week {
    type: number
    sql: coalesce(${TABLE}."PRICE_PER_WEEK",null) ;;
  }
  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }
  dimension: rental_rate_type_id {
    type: number
    sql: ${TABLE}."RENTAL_RATE_TYPE_ID" ;;
  }
  dimension: rsp_company_id {
    type: number
    sql: ${TABLE}."RSP_COMPANY_ID" ;;
  }
  dimension: voided {
    type: yesno
    sql: ${TABLE}."VOIDED" ;;
  }
  dimension: voided_by_user_id {
    type: number
    sql: ${TABLE}."VOIDED_BY_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_rental_rate_id]
  }
}
