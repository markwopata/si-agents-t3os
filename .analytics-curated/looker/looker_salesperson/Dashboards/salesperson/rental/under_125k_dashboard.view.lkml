view: under_125k_dashboard {
  derived_table: {
    sql:
      SELECT
        salesperson_user_id,
        MAX(date) AS date,

      SUM(
      CASE
      WHEN TRY_TO_DATE(date) >= TRY_TO_DATE(first_date_as_tam)
      AND TRY_TO_DATE(date) <= DATEADD(day, 30, TRY_TO_DATE(first_date_as_tam))
      THEN total_rev
      ELSE NULL
      END
      ) AS revenue_30_days,

      SUM(
      CASE
      WHEN TRY_TO_DATE(date) >= TRY_TO_DATE(first_date_as_tam)
      AND TRY_TO_DATE(date) <= DATEADD(day, 60, TRY_TO_DATE(first_date_as_tam))
      THEN total_rev
      ELSE NULL
      END
      ) AS revenue_60_days,

      SUM(
      CASE
      WHEN TRY_TO_DATE(date) >= TRY_TO_DATE(first_date_as_tam)
      AND TRY_TO_DATE(date) <= DATEADD(day, 90, TRY_TO_DATE(first_date_as_tam))
      THEN total_rev
      ELSE NULL
      END
      ) AS revenue_90_days

      FROM analytics.bi_ops.daily_sp_market_rollup
      WHERE TRY_TO_DATE(first_date_as_tam) IS NOT NULL
      GROUP BY 1
      ;;
  }

  dimension: salesperson_user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.salesperson_user_id ;;
  }

  dimension_group: date_month {
    type: time
    timeframes: [raw, date, month, quarter, year]
    sql: ${TABLE}.date ;;
  }

  dimension: revenue_30_days {
    type: number
    sql: ${TABLE}.revenue_30_days ;;
    value_format_name: usd
  }

  dimension: revenue_60_days {
    type: number
    sql: ${TABLE}.revenue_60_days ;;
    value_format_name: usd
  }

  dimension: revenue_90_days {
    type: number
    sql: ${TABLE}.revenue_90_days ;;
    value_format_name: usd
  }

  measure: count {
    type: count
  }

  measure: total_revenue_30_days {
    type: sum
    sql: ${revenue_30_days} ;;
    value_format_name: usd
  }

  measure: total_revenue_60_days {
    type: sum
    sql: ${revenue_60_days} ;;
    value_format_name: usd
  }

  measure: total_revenue_90_days {
    type: sum
    sql: ${revenue_90_days} ;;
    value_format_name: usd
  }
}
