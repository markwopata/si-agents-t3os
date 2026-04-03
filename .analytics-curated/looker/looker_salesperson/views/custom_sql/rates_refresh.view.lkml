view: rates_refresh {
  derived_table: {
    sql: select MARKET_ID, DISTRICT, rf.EQUIPMENT_CLASS_ID, ec.NAME, c.NAME as CATEGORY,
       case when LAST_6_MONTHS_REVENUE is null then 0 else LAST_6_MONTHS_REVENUE end as LAST_6_MONTHS_REVENUE,
       CURRENT_FLOOR as MONTH_FLOOR,
       round(CURRENT_FLOOR*WEEK_SPLIT,0) as WEEK_FLOOR,
       round(CURRENT_FLOOR*DAY_SPLIT,0) as DAY_FLOOR,
       CURRENT_BENCHMARK as MONTH_BENCHMARK,
       round(CURRENT_BENCHMARK*WEEK_SPLIT,0) as WEEK_BENCHMARK,
       round(CURRENT_BENCHMARK*DAY_SPLIT,0) as DAY_BENCHMARK,
       CURRENT_ONLINE as MONTH_ONLINE,
       round(CURRENT_ONLINE*WEEK_SPLIT,0) as WEEK_ONLINE,
       round(CURRENT_ONLINE*DAY_SPLIT,0) as DAY_ONLINE,
       NEW_FLOOR as NEW_MONTH_FLOOR,
       round(NEW_FLOOR*WEEK_SPLIT,0) as NEW_WEEK_FLOOR,
       round(NEW_FLOOR*DAY_SPLIT,0) as NEW_DAY_FLOOR,
       NEW_BENCHMARK as NEW_MONTH_BENCHMARK,
       round(NEW_BENCHMARK*WEEK_SPLIT,0) as NEW_WEEK_BENCHMARK,
       round(NEW_BENCHMARK*DAY_SPLIT,0) as NEW_DAY_BENCHMARK,
       CURRENT_ONLINE as NEW_MONTH_ONLINE,
       round(CURRENT_ONLINE*WEEK_SPLIT,0) as NEW_WEEK_ONLINE,
       round(CURRENT_ONLINE*DAY_SPLIT,0) as NEW_DAY_ONLINE
    from ANALYTICS.RATE_ACHIEVEMENT.RATES_FINAL rf
left join ANALYTICS.RATE_ACHIEVEMENT.RATE_SPLITS rs on rs.EQUIPMENT_CLASS_ID = rf.EQUIPMENT_CLASS_ID
left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on ec.EQUIPMENT_CLASS_ID = rf.EQUIPMENT_CLASS_ID
left join ES_WAREHOUSE.PUBLIC.CATEGORIES c on ec.CATEGORY_ID = c.CATEGORY_ID
where DISTRICT not like '5-4';;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.EQUIPMENT_CLASS_ID;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.CATEGORY ;;
  }

  dimension: last_6_months_revenue {
    type: number
    sql: ${TABLE}.LAST_6_MONTHS_REVENUE ;;
  }

  dimension: month_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.MONTH_FLOOR ;;
  }

  dimension: week_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.WEEK_FLOOR ;;
  }

  dimension: day_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.DAY_FLOOR ;;
  }

  dimension: month_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.MONTH_BENCHMARK ;;
  }

  dimension: week_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.WEEK_BENCHMARK ;;
  }

  dimension: day_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.DAY_BENCHMARK ;;
  }

  dimension: month_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.MONTH_ONLINE ;;
  }

  dimension: week_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.WEEK_ONLINE ;;
  }

  dimension: day_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.DAY_ONLINE ;;
  }

  dimension: new_month_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_MONTH_FLOOR ;;
  }

  dimension: new_week_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_WEEK_FLOOR ;;
  }

  dimension: new_day_floor {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_DAY_FLOOR ;;
  }

  dimension: new_month_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_MONTH_BENCHMARK ;;
  }

  dimension: new_week_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_WEEK_BENCHMARK ;;
  }

  dimension: new_day_benchmark {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_DAY_BENCHMARK ;;
  }

  dimension: new_month_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_MONTH_ONLINE ;;
  }

  dimension: new_week_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_WEEK_ONLINE ;;
  }

  dimension: new_day_online {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.NEW_DAY_ONLINE ;;
  }

  dimension: current_floor {
    type: string
    sql:concat('$',${day_floor}, ' / $', ${week_floor}, ' / $', ${month_floor})  ;;
  }

  dimension: current_benchmark {
    type: string
    sql:concat('$',${day_benchmark}, ' / $', ${week_benchmark}, ' / $', ${month_benchmark})  ;;
  }

  dimension: current_online {
    type: string
    sql:concat('$',${day_online}, ' / $', ${week_online}, ' / $', ${month_online})  ;;
  }

  dimension: new_floor {
    type: string
    sql:concat('$',${new_day_floor}, ' / $', ${new_week_floor}, ' / $', ${new_month_floor})  ;;
  }

  dimension: new_benchmark {
    type: string
    sql:concat('$',${new_day_benchmark}, ' / $', ${new_week_benchmark}, ' / $', ${new_month_benchmark})  ;;
  }

  dimension: new_online {
    type: string
    sql:concat('$',${new_day_online}, ' / $', ${new_week_online}, ' / $', ${new_month_online})  ;;
  }
}
