view: period_list_for_abs_assets {
  derived_table: {
    sql:
      SELECT
        dd.dt_key,
        dd.dt_date                AS period_date,
        DATE_TRUNC('month', dd.dt_date)  AS period_start_date,
        dd.dt_period             AS period_name
      FROM platform.gold.dim_dates dd
      WHERE dd.dt_date >= '2021-01-01'
        AND dd.dt_date <= CURRENT_DATE
        AND (
          dd.dt_date = LAST_DAY(dd.dt_date)
          OR dd.dt_date = CURRENT_DATE
        )
      ORDER BY dd.dt_date DESC
    ;;
  }

  # Surrogate key
  dimension: dt_key {
    type: string
    primary_key: yes
    sql: ${TABLE}.dt_key ;;
  }

  # The actual date for the period
  dimension: period_date {
    type: date
    sql: ${TABLE}.period_date ;;
  }

  # First day of the month for that period
  dimension: period_start_date {
    type: date
    sql: ${TABLE}.period_start_date ;;
  }

  # Friendly name of the period, e.g. "January 2021"
  dimension: period_name {
    type: string
    sql: ${TABLE}.period_name ;;
  }

}
