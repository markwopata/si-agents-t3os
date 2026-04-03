view: branch_ranking_filter {
  derived_table: {
    sql:
      WITH combined_data AS (
        SELECT
          d.market_id,
      -- Calculating the total score
      COALESCE((
      AVG(LEAST(COALESCE(w.score,0),1)) +
      AVG(LEAST(COALESCE(t.score,0),.5)) +
      AVG(LEAST(COALESCE(l.score,0),1.5)) +
      AVG(LEAST(COALESCE(c.score,0),1)) +
      AVG(LEAST(COALESCE(a.score,0),1.5)) +
      AVG(LEAST(COALESCE(tr.score,0),.5)) +
      AVG(LEAST(COALESCE(o.score,0),1)) +
      AVG(LEAST(COALESCE(h.score,0),.5)) +
      AVG(LEAST(COALESCE(dsr.score,0),.5)) +
      AVG(LEAST(COALESCE(u.score,0),1.5)) +
      AVG(LEAST(COALESCE(wo.score,0),.5))
      ), 0) AS total_percent_to_goal_avg_last_3_months

      FROM ${market_region_xwalk_and_dates.SQL_TABLE_NAME} d

      -- LEFT JOIN each aggregate table based on market_id & month
      LEFT JOIN ${warranty_aggregate.SQL_TABLE_NAME} w
      ON d.market_id = w.branch_id AND d.month = w.month

      LEFT JOIN ${training_aggregate.SQL_TABLE_NAME} t
      ON d.market_id = t.branch_id AND d.month = t.month

      LEFT JOIN ${compliance_vendors_aggregate.SQL_TABLE_NAME} c
      ON d.market_id = c.branch_id AND d.month = c.month

      LEFT JOIN ${aging_work_orders_aggregate.SQL_TABLE_NAME} a
      ON d.market_id = a.branch_id AND d.month = a.month

      LEFT JOIN ${overdue_inspections_aggregate.SQL_TABLE_NAME} o
      ON d.market_id = o.branch_id AND d.month = o.month

      LEFT JOIN ${headcount_oec_aggregate.SQL_TABLE_NAME} h
      ON d.market_id = h.branch_id AND d.month = h.month

      LEFT JOIN ${deadstock_ratio_aggregate.SQL_TABLE_NAME} dsr
      ON d.market_id = dsr.branch_id AND d.month = dsr.month

      LEFT JOIN ${unavailable_oec_aggregate.SQL_TABLE_NAME} u
      ON d.market_id = u.branch_id AND d.month = u.month

      LEFT JOIN ${turnover_aggregate.SQL_TABLE_NAME} tr
      ON d.market_id = tr.branch_id AND d.month = tr.month

      LEFT JOIN ${lost_revenue_aggregate.SQL_TABLE_NAME} l
      on d.market_id = l.branch_id and d.month = l.month

      LEFT JOIN ${wos_within_7days_of_delivery_aggregate.SQL_TABLE_NAME} wo
      on d.market_id = wo.branch_id and d.month = wo.month

      WHERE d.month >= DATEADD('month', -3, DATE_TRUNC('month', CURRENT_DATE()))
          AND d.month < DATE_TRUNC('month', CURRENT_DATE())
          group by 1
      )

      SELECT
      market_id,
      total_percent_to_goal_avg_last_3_months,

      -- Ranking logic
      RANK() OVER (ORDER BY total_percent_to_goal_avg_last_3_months DESC) AS desc_rank,
      RANK() OVER (ORDER BY total_percent_to_goal_avg_last_3_months ASC) AS asc_rank

      FROM combined_data
      ;;
  }

  # Dimensions
  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: branch_ranking {
    type: string
    sql: CASE
           WHEN ${TABLE}.desc_rank <= 10 THEN 'Top 10'
           WHEN ${TABLE}.asc_rank <= 10 THEN 'Bottom 10'
           ELSE NULL
         END ;;
  }

  # measure: total_percent_to_goal_avg_last_3_months {
  #   type: number
  #   sql: ${TABLE}.total_percent_to_goal_avg_last_3_months ;;
  #   value_format: "0.0%"
  #   description: "Total Percent to Goal, averaged over the last 3 months"
  # }
}
