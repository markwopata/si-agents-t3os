view: intacct_department_backdating {
  # Dashboard-level date filter → pushed into p.AUWHENCREATED
  filter: created_date { type: date }

  derived_table: {
    sql:
      WITH branch_backdating AS (
        SELECT
          COALESCE(cd.LOCATION, 'Unknown') AS department_name,  -- using LOCATION as "department"
          COUNT(*) AS total_documents,
          SUM(CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
                   THEN 1 ELSE 0 END) AS backdated_documents,
          SUM(CASE WHEN DATE_TRUNC('month', p.WHENCREATED) <> DATE_TRUNC('month', p.AUWHENCREATED)
                   THEN 1 ELSE 0 END) AS cross_month_documents
        FROM analytics.intacct.PODOCUMENT p
        JOIN analytics.intacct.USERINFO usr
          ON p.CREATEDBY = usr.RECORDNO
        JOIN analytics.intacct.CONTACT c
          ON usr.CONTACTKEY = c.RECORDNO
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
          ON LOWER(c.EMAIL1) = LOWER(cd.WORK_EMAIL)
         AND cd.rn = 1
        WHERE 1=1
          AND p.DOCPARID = 'Purchase Order'
          AND LEFT(p.DOCNO, 1) = 'E'
          {% if _filters['intacct_department_backdating.created_date'] %}
            AND {% condition created_date %} p.AUWHENCREATED {% endcondition %}
          {% endif %}
          AND usr.STATUS = 'active'
          AND COALESCE(cd.EMPLOYEE_STATUS, 'Active') <> 'Terminated'
        GROUP BY 1
      )
      SELECT
        department_name,
        total_documents,
        backdated_documents,
        cross_month_documents
      FROM branch_backdating
      ORDER BY backdated_documents DESC
    ;;
  }

  # ========= Dimensions =========
  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  # ========= Measures =========
  measure: total_documents {
    type: sum
    sql: ${TABLE}.total_documents ;;
  }

  measure: backdated_documents {
    type: sum
    sql: ${TABLE}.backdated_documents ;;
  }

  measure: cross_month_documents {
    type: sum
    sql: ${TABLE}.cross_month_documents ;;
  }

  measure: pct_backdated {
    type: number
    sql: CASE WHEN ${total_documents} = 0 THEN NULL
              ELSE ${backdated_documents} / NULLIF(${total_documents}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Backdated"
  }

  measure: pct_cross_month {
    type: number
    sql: CASE WHEN ${total_documents} = 0 THEN NULL
              ELSE ${cross_month_documents} / NULLIF(${total_documents}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Cross-Month"
  }
}
