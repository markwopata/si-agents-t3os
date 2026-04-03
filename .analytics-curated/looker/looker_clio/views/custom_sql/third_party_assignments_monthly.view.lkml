view: third_party_assignments_monthly {
  derived_table: {
    sql:

      WITH snapshot_daily AS (
        SELECT
          company_id,
          snapshot_date::date AS snapshot_date,
          final_collector,
          CASE
            WHEN final_collector ILIKE '%DAL%' THEN 'DAL'
            WHEN final_collector ILIKE '%CCC%' THEN 'CCC'
            ELSE 'INTERNAL'
          END AS assignment_type
        FROM analytics.bi_ops.collector_customer_assignments_daily_snapshot
      ),


      assignments_monthly AS (
      SELECT
      DATE_TRUNC('month', snapshot_date)::date AS month_start_date,
      assignment_type                         AS third_party,
      COUNT(DISTINCT company_id)             AS accounts_assigned
      FROM snapshot_daily
      WHERE assignment_type IN ('CCC','DAL')
      GROUP BY 1,2
      ),


      snapshot_with_lag AS (
      SELECT
      company_id,
      snapshot_date,
      assignment_type,
      LAG(assignment_type) OVER (
      PARTITION BY company_id
      ORDER BY snapshot_date
      ) AS prev_assignment_type
      FROM snapshot_daily
      ),


      placement_starts AS (
      SELECT
      company_id,
      snapshot_date AS placement_start_date,
      assignment_type AS third_party_assigned
      FROM snapshot_with_lag
      WHERE assignment_type IN ('CCC','DAL')
      AND (prev_assignment_type IS NULL OR prev_assignment_type NOT IN ('CCC','DAL'))
      ),


      placement_ends AS (
      SELECT
      company_id,
      snapshot_date AS placement_end_date,
      prev_assignment_type AS third_party_assigned
      FROM snapshot_with_lag
      WHERE prev_assignment_type IN ('CCC','DAL')
      AND assignment_type NOT IN ('CCC','DAL')
      ),

      placement_windows AS (
      SELECT
      s.company_id,
      s.third_party_assigned,
      s.placement_start_date,
      MIN(e.placement_end_date) AS placement_end_date
      FROM placement_starts s
      LEFT JOIN placement_ends e
      ON  s.company_id = e.company_id
      AND s.third_party_assigned = e.third_party_assigned
      AND e.placement_end_date > s.placement_start_date
      GROUP BY
      s.company_id,
      s.third_party_assigned,
      s.placement_start_date
      ),


      payments_by_company AS (
      SELECT
      COALESCE(pa.date, p.payment_date)::date AS payment_date,
      p.company_id,
      SUM(
      CASE
      WHEN ba.intacct_undepfundsacct = '1205'
      THEN 0
      ELSE pa.amount
      END
      ) AS payment_amount
      FROM es_warehouse.public.payment_applications pa
      JOIN es_warehouse.public.payments p
      ON pa.payment_id = p.payment_id
      LEFT JOIN es_warehouse.public.bank_account_erp_refs ba
      ON p.bank_account_id = ba.bank_account_id
      WHERE pa.reversed_date IS NULL
      GROUP BY 1,2
      ),

      payments_while_agency AS (
      SELECT
      pb.payment_date,
      pw.third_party_assigned,
      pb.payment_amount
      FROM payments_by_company pb
      JOIN placement_windows pw
      ON pb.company_id = pw.company_id
      AND pb.payment_date >= pw.placement_start_date
      AND (
      pw.placement_end_date IS NULL
      OR pb.payment_date < pw.placement_end_date
      )
      ),

      payments_monthly AS (
      SELECT
      DATE_TRUNC('month', payment_date)::date AS month_start_date,
      third_party_assigned                   AS third_party,
      SUM(payment_amount)                    AS payments_total
      FROM payments_while_agency
      GROUP BY 1,2
      )


      SELECT
      COALESCE(a.month_start_date, pm.month_start_date) AS month_start_date,
      COALESCE(a.third_party, pm.third_party)           AS third_party,
      COALESCE(a.accounts_assigned, 0)                  AS accounts_assigned,
      COALESCE(pm.payments_total, 0)                    AS payments_total,
        (
    TO_CHAR(COALESCE(a.month_start_date, pm.month_start_date), 'YYYYMM') ||
    CASE
      WHEN COALESCE(a.third_party, pm.third_party) = 'CCC' THEN '01'
      WHEN COALESCE(a.third_party, pm.third_party) = 'DAL' THEN '02'
      ELSE '99'
    END
  ) AS sort_order
      FROM assignments_monthly a
      FULL OUTER JOIN payments_monthly pm
      ON pm.month_start_date = a.month_start_date
      AND pm.third_party      = a.third_party
      ;;
  }

  dimension_group: month {
    type: time
    timeframes: [date, month, year]
    sql: ${TABLE}.month_start_date ;;
  }

  dimension: third_party {
    sql: ${TABLE}.third_party ;;
  }

  measure: accounts_assigned {
    type: sum
    sql: ${TABLE}.accounts_assigned ;;
    value_format: "#,##0"
  }

  measure: payments_total {
    type: sum
    sql: ${TABLE}.payments_total ;;
    value_format_name: usd
  }

dimension: sort_order {
  sql: ${TABLE}.sort_order ;;
  view_label: "Technical Fields"
  group_label: "Technical"
}

}
