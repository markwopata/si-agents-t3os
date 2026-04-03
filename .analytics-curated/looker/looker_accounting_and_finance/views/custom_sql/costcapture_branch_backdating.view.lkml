view: costcapture_branch_backdating {
  # Dashboard-level date filter (applies to r.DATE_CREATED)
  filter: created_date { type: date }

  derived_table: {
    sql:
      WITH branch_backdating AS (
        SELECT
          COALESCE(cd.LOCATION, 'Unknown') AS branch_name,
          COUNT(*) AS total_receipts,
          SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                   THEN 1 ELSE 0 END) AS backdated_receipts,
          SUM(CASE WHEN DATE_TRUNC('month', r.DATE_RECEIVED) <> DATE_TRUNC('month', r.DATE_CREATED)
                   THEN 1 ELSE 0 END) AS cross_month_receipts
        FROM procurement.public.purchase_order_receivers r
        JOIN es_warehouse.public.users u
          ON r.CREATED_BY_ID = u.USER_ID
        LEFT JOIN (
          SELECT
            WORK_EMAIL,
            LOCATION,
            EMPLOYEE_STATUS,
            ROW_NUMBER() OVER (
              PARTITION BY LOWER(WORK_EMAIL)
              ORDER BY POSITION_EFFECTIVE_DATE DESC NULLS LAST
            ) AS rn
          FROM analytics.payroll.company_directory
        ) cd
          ON LOWER(u.USERNAME) = LOWER(cd.WORK_EMAIL)
         AND cd.rn = 1
        WHERE 1=1
          {% if _filters['costcapture_branch_backdating.created_date'] %}
            AND {% condition created_date %} r.DATE_CREATED {% endcondition %}
          {% endif %}
          AND COALESCE(cd.EMPLOYEE_STATUS, 'Active') <> 'Terminated'
        GROUP BY 1
        HAVING SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                        THEN 1 ELSE 0 END) > 0
      )
      SELECT
        branch_name,
        total_receipts,
        backdated_receipts,
        cross_month_receipts
      FROM branch_backdating
    ;;
  }

  # ========== Dimensions ==========
  dimension: branch_name {
    type: string
    sql: ${TABLE}.branch_name ;;
  }

  # ========== Measures ==========
  measure: total_receipts {
    type: sum
    sql: ${TABLE}.total_receipts ;;
  }

  measure: backdated_receipts {
    type: sum
    sql: ${TABLE}.backdated_receipts ;;
  }

  measure: cross_month_receipts {
    type: sum
    sql: ${TABLE}.cross_month_receipts ;;
  }

  measure: pct_backdated {
    type: number
    sql: CASE WHEN ${total_receipts} = 0 THEN NULL
              ELSE ${backdated_receipts} / NULLIF(${total_receipts}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Backdated"
  }

  measure: pct_cross_month {
    type: number
    sql: CASE WHEN ${total_receipts} = 0 THEN NULL
              ELSE ${cross_month_receipts} / NULLIF(${total_receipts}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Cross-Month"
  }
}
