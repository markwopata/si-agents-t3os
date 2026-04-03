view: costcapture_monthly_backdating {
  derived_table: {
    sql:
      WITH base AS (
        SELECT
          DATE_TRUNC('month', r.DATE_CREATED) AS month,
          DATEDIFF('day', r.DATE_CREATED, r.DATE_RECEIVED) AS days_backdated,
          CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
               THEN 1 ELSE 0 END AS is_backdated,
          CASE WHEN DATE_TRUNC('month', r.DATE_RECEIVED) <> DATE_TRUNC('month', r.DATE_CREATED)
               AND DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
               THEN 1 ELSE 0 END AS is_cross_month
        FROM procurement.public.purchase_order_receivers r
      ),

      -- Exact monthly counts/sums to match your original query
      agg_base AS (
      SELECT
      month,
      COUNT(*) AS total_receipts,
      SUM(is_backdated) AS backdated_receipts,
      SUM(is_cross_month) AS cross_month_receipts
      FROM base
      GROUP BY month
      ),

      -- One row per month: the signed value whose absolute value is largest
      max_signed AS (
      SELECT month, days_backdated
      FROM (
      SELECT
      month,
      days_backdated,
      ROW_NUMBER() OVER (PARTITION BY month ORDER BY ABS(days_backdated) DESC) AS rn
      FROM base
      WHERE is_backdated = 1
      )
      WHERE rn = 1
      ),

      -- One row per month: the most frequent signed days_backdated (mode)
      mode_signed AS (
      SELECT month, days_backdated
      FROM (
      SELECT
      month,
      days_backdated,
      COUNT(*) AS cnt,
      ROW_NUMBER() OVER (PARTITION BY month ORDER BY COUNT(*) DESC, days_backdated ASC) AS rn
      FROM base
      WHERE is_backdated = 1
      GROUP BY month, days_backdated
      )
      WHERE rn = 1
      )

      SELECT
      a.month,
      a.total_receipts,
      a.backdated_receipts,
      ms.days_backdated   AS max_days_backdated,   -- signed value of the largest absolute offset
      mo.days_backdated   AS mode_days_backdated,  -- most common signed offset
      a.cross_month_receipts
      FROM agg_base a
      LEFT JOIN max_signed ms ON a.month = ms.month
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

  measure: total_receipts {
    type: sum
    sql: ${TABLE}.total_receipts ;;
  }

  measure: backdated_receipts {
    type: sum
    sql: ${TABLE}.backdated_receipts ;;
  }

  # Compute % in Looker so it rolls up correctly
  measure: pct_backdated {
    type: number
    sql: CASE WHEN ${total_receipts} = 0 THEN NULL
              ELSE ${backdated_receipts} / NULLIF(${total_receipts}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Backdated"
  }

  measure: max_days_backdated {
    type: max
    sql: ${TABLE}.max_days_backdated ;;
  }

  measure: mode_days_backdated {
    type: max
    sql: ${TABLE}.mode_days_backdated ;;
  }

  measure: cross_month_receipts {
    type: sum
    sql: ${TABLE}.cross_month_receipts ;;
  }
}
