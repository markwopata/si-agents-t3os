view: market_goals {
  sql_table_name: "PUBLIC"."MARKET_GOALS"
    ;;

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_level {
    type: string
    sql: ${TABLE}."MARKET_LEVEL" ;;
  }

  dimension_group: months {
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
    sql: ${TABLE}."MONTHS" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: revenue_goals {
    type: string
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: market_start {
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
    sql: ${TABLE}."MARKET_START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [name]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${market_id},${months_month},${start_date}) ;;
  }

  measure: goal_for_current_month_created_date {
    type: sum
    sql: ${revenue_goals} ;;
    filters: [line_items.line_item_type_id: "6,8,108,109"]
    value_format_name: usd_0
  }

  measure: goal_for_current_month_billing_approved {
    type: sum
    sql: ${revenue_goals} ;;
    filters: [line_items.line_item_type_id: "6,8,108,109"]
    value_format_name: usd_0
  }

  measure: number_of_days_into_month {
    type: number
    sql: DATE_PART('days', current_timestamp()) ;;
  }

  measure: number_of_days_in_current_month {
    type: number
    sql: date_part(days,last_day(current_timestamp)) ;;
  }

  measure: per_day_revenue_goal {
    type: number
    sql: ((case when ${goal_for_current_month_billing_approved} = 0 then null else ${goal_for_current_month_billing_approved} end)/${number_of_days_in_current_month})*${number_of_days_into_month} ;;
  }

  measure: goal_revenue_per_day {
    type: number
    sql: ${goal_for_current_month_billing_approved}/${per_day_revenue_goal} ;;
  }

  measure: rental_revenue_vs_goal {
    type: number
    sql: ${line_items.total_rental_revenue}/${per_day_revenue_goal} ;;
  }
}
