view: new_dealership_sales {
  derived_table: {
    sql: WITH
      plexi_periods AS (
        SELECT
          _ROW       AS _ROW,
          TRUNC      AS period_month,
          DISPLAY    AS display_month,
          PERIOD_PUBLISHED
        FROM ANALYTICS.GS.PLEXI_PERIODS
      ),

      snap AS (
      SELECT
      MKT_ID::NUMBER        AS market_id,
      MKT_NAME              AS market_name,
      ACCTNO                AS account_number,
      GL_ACCT               AS account_name,
      GL_DATE               AS gl_date,
      DESCR                 AS description,
      URL_ADMIN             AS url_admin,
      AMT                   AS amount,
      DATE_TRUNC('month', GL_DATE) AS period_month
      FROM BRANCH_EARNINGS_DDS_SNAP
      WHERE ACCTNO in ('FBAA','FBBA') -- New and Used Dealership sales
      ),

      live AS (
      SELECT
      MARKET_ID::NUMBER     AS market_id,
      MARKET_NAME           AS market_name,
      ACCOUNT_NUMBER        AS account_number,
      ACCOUNT_NAME          AS account_name,
      GL_DATE               AS gl_date,
      DESCRIPTION           AS description,
      URL_ADMIN             AS url_admin,
      AMOUNT                AS amount,
      DATE_TRUNC('month', GL_DATE) AS period_month
      FROM ANALYTICS.BRANCH_EARNINGS.INT_LIVE_BRANCH_EARNINGS_LOOKER
      WHERE ACCOUNT_NUMBER in ('FBAA','FBBA') -- New and Used Dealership sales
      )

      SELECT
      l.market_id,
      l.market_name,
      l.account_number,
      l.account_name,
      l.gl_date,
      l.description,
      l.url_admin,
      l.amount,
      p.display_month,
      p._row,
      'Live Data' AS data_source
      FROM live l
      JOIN plexi_periods p
      ON l.period_month = p.period_month
      WHERE p.PERIOD_PUBLISHED is null

      UNION ALL

      SELECT
      s.market_id,
      s.market_name,
      s.account_number,
      s.account_name,
      s.gl_date,
      s.description,
      s.url_admin,
      s.amount,
      p.display_month,
      p._row,
      'Snapshot Data' AS data_source
      FROM snap s
      JOIN plexi_periods p
      ON s.period_month = p.period_month
      WHERE p.PERIOD_PUBLISHED = 'published'
      ;;
  }

  # Dimensions
  dimension: _row {
    type: number
    sql: 150-${TABLE}."_ROW" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name;;
  }

  dimension: gl_date {
    type: date
    sql: ${TABLE}.gl_date;;
  }

  dimension: period_month {
    type: date
    sql: DATE_TRUNC('month', ${TABLE}.gl_date);;
    order_by_field: _row
  }

  dimension_group: period_month_date {
    type: time
    timeframes: [raw,month]          # only need month bucket
    convert_tz: no
    datatype: date
    sql: DATE_TRUNC('month', ${TABLE}.gl_date) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description;;
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}.url_admin;;
  }

  dimension: display_month {
    type: string
    sql: ${TABLE}.display_month;;
    order_by_field: _row
  }

  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source;;
  }

  # Measures
  measure: total_amount {
    type: sum
    sql: ${TABLE}.amount;;
    value_format_name: "usd"
  }
}
