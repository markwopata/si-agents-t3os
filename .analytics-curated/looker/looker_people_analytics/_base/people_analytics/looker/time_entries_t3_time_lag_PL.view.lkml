view: time_entries_t3_time_lag_PL {
  derived_table: {
    sql:
      SELECT
        full_name,
        start_date,
        DATE_TRUNC('WEEK', start_date) AS week_start_date,
        DATE_TRUNC('MONTH', start_date) AS month_start_date,
        regular_hours + overtime_hours AS daily_total_hours,
        SUM(regular_hours + overtime_hours)
          OVER (PARTITION BY full_name, DATE_TRUNC('WEEK', start_date)) AS weekly_total_hours,
        SUM(regular_hours + overtime_hours)
          OVER (PARTITION BY full_name, DATE_TRUNC('MONTH', start_date)) AS monthly_total_hours
      FROM "LOOKER"."TIME_ENTRIES_T3"
    ;;
  }

  # Add primary key dimension
  dimension: id {
    primary_key: yes   # Mark this dimension as the primary key
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.full_name, '_', ${TABLE}.start_date) ;;
  }

  # Dimensions
  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension_group: start_date {
    type: time
    sql: ${TABLE}.start_date ;;
  }

  dimension_group: week_start_date {
    type: time
    sql: ${TABLE}.week_start_date ;;
  }

  dimension_group: month_start_date {
    type: time
    sql: ${TABLE}.month_start_date ;;
  }

  # Measures
  measure: daily_total_hours {
    type: sum
    sql: ${TABLE}.daily_total_hours ;;
  }

  measure: weekly_total_hours {
    type: sum
    sql: ${TABLE}.weekly_total_hours ;;
  }

  measure: monthly_total_hours {
    type: sum
    sql: ${TABLE}.monthly_total_hours ;;
  }
}
