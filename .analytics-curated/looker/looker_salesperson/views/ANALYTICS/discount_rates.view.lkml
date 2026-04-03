view: discount_rates {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."DISCOUNT_RATES" ;;
  drill_fields: [discount_rate_id]

  dimension: discount_rate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DISCOUNT_RATE_ID" ;;
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_voided {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_VOIDED" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: voided_by {
    type: string
    sql: ${TABLE}."VOIDED_BY" ;;
  }
  dimension: duration {
    type: number
    value_format: "#,##0"
    sql: datediff(days,${TABLE}."DATE_CREATED",${TABLE}."DATE_VOIDED")  ;;
  }
  measure: count {
    type: count
    drill_fields: [district]
  }
}
