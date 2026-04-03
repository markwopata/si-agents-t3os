view: intacct_monthly_backdating {
  derived_table: {
    sql:
      WITH base AS (
        SELECT
          DATE_TRUNC('month', p.AUWHENCREATED) AS month,
          DATEDIFF('day', p.AUWHENCREATED, p.WHENCREATED) AS days_backdated,
          CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
               THEN 1 ELSE 0 END AS is_backdated,
          CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
               AND DATE_TRUNC('month', p.WHENCREATED) <> DATE_TRUNC('month', p.AUWHENCREATED)
               THEN 1 ELSE 0 END AS is_cross_month
        FROM analytics.intacct.PODOCUMENT p
        WHERE p.DOCPARID = 'Purchase Order'
          AND LEFT(p.DOCNO, 1) = 'E'
      ),

      -- exact monthly counts/sums (matches your original query’s grain)
      agg_base AS (
      SELECT
      month,
      COUNT(*)                           AS total_documents,
      SUM(is_backdated)                  AS backdated_documents,
      SUM(is_cross_month)                AS cross_month_documents
      FROM base
      GROUP BY month
      ),

      -- ONE row per month: signed value with the largest absolute offset
      max_signed AS (
      SELECT month, days_backdated
      FROM (
      SELECT
      month,
      days_backdated,
      ROW_NUMBER() OVER (
      PARTITION BY month
      ORDER BY ABS(days_backdated) DESC
      ) AS rn
      FROM base
      WHERE is_backdated = 1
      )
      WHERE rn = 1
      ),

      -- ONE row per month: mode (most frequent signed offset)
      mode_signed AS (
      SELECT month, days_backdated
      FROM (
      SELECT
      month,
      days_backdated,
      COUNT(*) AS cnt,
      ROW_NUMBER() OVER (
      PARTITION BY month
      ORDER BY cnt DESC, days_backdated ASC
      ) AS rn
      FROM base
      WHERE is_backdated = 1
      GROUP BY month, days_backdated
      )
      WHERE rn = 1
      )

      SELECT
      a.month,
      a.total_documents,
      a.backdated_documents,
      ms.days_backdated AS max_days_backdated,   -- signed, chosen by max ABS
      mo.days_backdated AS mode_days_backdated,  -- most common signed value
      a.cross_month_documents
      FROM agg_base a
      LEFT JOIN max_signed  ms ON a.month = ms.month
      LEFT JOIN mode_signed mo ON a.month = mo.month
      ORDER BY a.month
      ;;
  }

  dimension_group: month {
    type: time
    timeframes: [month, month_name, quarter, year]
    datatype: date
    sql: ${TABLE}.month ;;
  }

  measure: total_documents        { type: sum  sql: ${TABLE}.total_documents ;; }
  measure: backdated_documents    { type: sum  sql: ${TABLE}.backdated_documents ;; }
  measure: cross_month_documents  { type: sum  sql: ${TABLE}.cross_month_documents ;; }

  # Compute % as a ratio of sums (no precomputed percent in SQL)
  measure: pct_backdated {
    type: number
    sql: CASE WHEN ${total_documents} = 0 THEN NULL
              ELSE ${backdated_documents} / NULLIF(${total_documents}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Backdated"
  }

  measure: max_days_backdated  { type: max  sql: ${TABLE}.max_days_backdated  ;; }
  measure: mode_days_backdated { type: max  sql: ${TABLE}.mode_days_backdated ;; }
}
