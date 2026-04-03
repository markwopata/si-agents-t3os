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
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."END_DATE" ;;
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
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }
  dimension: negotiated_rates {
    type: string
    sql: concat('$', round(${price_per_hour}), ' / $', round(${price_per_day}), ' / $',
        round(${price_per_week}), ' / $', round(${price_per_month})) ;;
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
