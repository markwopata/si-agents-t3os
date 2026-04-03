view: costcapture_user_backdating {
  # Dashboard-level date filter that pushes into r.DATE_CREATED
  filter: created_date { type: date }

  derived_table: {
    sql:
      WITH user_backdating AS (
        SELECT
          r.CREATED_BY_ID AS user_id,
          COUNT(*) AS total_receipts,
          SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                   THEN 1 ELSE 0 END) AS backdated_receipts,
          SUM(CASE WHEN DATE_TRUNC('month', r.DATE_RECEIVED) <> DATE_TRUNC('month', r.DATE_CREATED)
                   THEN 1 ELSE 0 END) AS cross_month_receipts
        FROM procurement.public.purchase_order_receivers r
        WHERE 1=1
          {% if _filters['costcapture_user_backdating.created_date'] %}
            AND {% condition created_date %} r.DATE_CREATED {% endcondition %}
          {% endif %}
        GROUP BY 1
        HAVING SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                        THEN 1 ELSE 0 END) > 0
      )
      SELECT
        u.USER_ID AS user_id,
        (u.FIRST_NAME || ' ' || u.LAST_NAME) AS user_name,
        COALESCE(cd.LOCATION, 'Unknown') AS branch_name,
        COALESCE(cd.DIRECT_MANAGER_NAME, 'Unknown') AS manager_name,
        ub.total_receipts,
        ub.backdated_receipts,
        ub.cross_month_receipts
      FROM user_backdating ub
      LEFT JOIN es_warehouse.public.users u
        ON ub.user_id = u.USER_ID
      LEFT JOIN (
        SELECT
          WORK_EMAIL,
          DIRECT_MANAGER_NAME,
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
      WHERE COALESCE(cd.EMPLOYEE_STATUS, 'Active') <> 'Terminated'
    ;;
  }

  # Dimensions
  dimension: user_id      { primary_key: yes type: string sql: ${TABLE}.user_id ;; }
  dimension: user_name    { type: string sql: ${TABLE}.user_name ;; }
  dimension: branch_name  { type: string sql: ${TABLE}.branch_name ;; }
  dimension: manager_name { type: string sql: ${TABLE}.manager_name ;; }

  # Measures
  measure: total_receipts       { type: sum sql: ${TABLE}.total_receipts ;; }
  measure: backdated_receipts   { type: sum sql: ${TABLE}.backdated_receipts ;; }
  measure: cross_month_receipts { type: sum sql: ${TABLE}.cross_month_receipts ;; }

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
