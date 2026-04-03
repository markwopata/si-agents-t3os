view: date_scaffold {
  derived_table: {
    sql:
      SELECT DATE('2023-12-01') as active_month_first_day, LAST_DAY(DATE('2023-12-01')) as active_month_last_day UNION ALL
      SELECT DATE('2024-01-01'), LAST_DAY(DATE('2024-01-01')) UNION ALL
      SELECT DATE('2024-02-01'), LAST_DAY(DATE('2024-02-01')) UNION ALL
      SELECT DATE('2024-03-01'), LAST_DAY(DATE('2024-03-01')) UNION ALL
      SELECT DATE('2024-04-01'), LAST_DAY(DATE('2024-04-01')) UNION ALL
      SELECT DATE('2024-05-01'), LAST_DAY(DATE('2024-05-01')) UNION ALL
      SELECT DATE('2024-06-01'), LAST_DAY(DATE('2024-06-01')) UNION ALL
      SELECT DATE('2024-07-01'), LAST_DAY(DATE('2024-07-01')) UNION ALL
      SELECT DATE('2024-08-01'), LAST_DAY(DATE('2024-08-01')) UNION ALL
      SELECT DATE('2024-09-01'), LAST_DAY(DATE('2024-09-01')) UNION ALL
      SELECT DATE('2024-10-01'), LAST_DAY(DATE('2024-10-01')) UNION ALL
      SELECT DATE('2024-11-01'), LAST_DAY(DATE('2024-11-01')) UNION ALL
      SELECT DATE('2024-12-01'), LAST_DAY(DATE('2024-12-01')) UNION ALL
      SELECT DATE('2025-01-01'), LAST_DAY(DATE('2025-01-01')) UNION ALL
      SELECT DATE('2025-02-01'), LAST_DAY(DATE('2025-02-01'))
    ;;
  }

  dimension_group: active_month_first_day {
    type: time
    timeframes: [raw, month, year]
    sql: DATE_TRUNC('month', ${TABLE}.active_month_first_day) ;;
  }

  dimension_group: active_month_last_day {
    type: time
    sql: ${TABLE}.active_month_last_day ;;
  }
}
