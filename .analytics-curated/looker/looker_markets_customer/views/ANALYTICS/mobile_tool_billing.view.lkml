view: mobile_tool_billing {
  sql_table_name: "MOBILE_TOOLS"."MOBILE_TOOL_BILLING"
    ;;

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}."CLASS_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: month {
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
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_string {
    label: "Month"
    type: string
    sql: TO_CHAR(${TABLE}."MONTH", 'YYYY-MM') ;;
  }

  dimension: price_per_day {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_month {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: price_per_week {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: rental_charge {
    type: number
    value_format_name: usd
    sql: ${TABLE}."RENTAL_CHARGE" ;;
  }

  dimension: discount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."DISCOUNT" ;;
  }

  dimension: run_number {
    type: number
    sql: ${TABLE}."RUN_NUMBER" ;;
  }

  dimension_group: start_date {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      date
    ]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
}
