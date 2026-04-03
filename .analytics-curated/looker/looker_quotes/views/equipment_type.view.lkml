view: equipment_type {
  sql_table_name: "QUOTES"."EQUIPMENT_TYPE"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: _es_load_timestamp {
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
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: four_week_rate {
    type: number
    sql: ${TABLE}."FOUR_WEEK_RATE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: quote_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: selected_rate_type_id {
    type: string
    sql: ${TABLE}."SELECTED_RATE_TYPE_ID" ;;
  }

  dimension: shift_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."SHIFT_ID" ;;
  }

  dimension: suggested_bench_mark_daily_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_BENCH_MARK_DAILY_RATE" ;;
  }

  dimension: suggested_bench_mark_monthly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_BENCH_MARK_MONTHLY_RATE" ;;
  }

  dimension: suggested_bench_mark_weekly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_BENCH_MARK_WEEKLY_RATE" ;;
  }

  dimension: suggested_floor_daily_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_FLOOR_DAILY_RATE" ;;
  }

  dimension: suggested_floor_monthly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_FLOOR_MONTHLY_RATE" ;;
  }

  dimension: suggested_floor_weekly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_FLOOR_WEEKLY_RATE" ;;
  }

  dimension: suggested_online_daily_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_ONLINE_DAILY_RATE" ;;
  }

  dimension: suggested_online_monthly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_ONLINE_MONTHLY_RATE" ;;
  }

  dimension: suggested_online_weekly_rate {
    type: number
    sql: ${TABLE}."SUGGESTED_ONLINE_WEEKLY_RATE" ;;
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      equipment_class_name,
      quote.company_name,
      quote.new_company_name,
      quote.delivery_type_name,
      quote.po_name,
      quote.id,
      quote.rpp_name,
      quote.contact_name,
      shift.id,
      shift.name
    ]
  }
}
