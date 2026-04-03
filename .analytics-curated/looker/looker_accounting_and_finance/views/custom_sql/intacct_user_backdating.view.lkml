view: intacct_user_backdating {
  # Dashboard-level date filter → pushed into p.AUWHENCREATED
  filter: created_date { type: date }

  derived_table: {
    sql:
      WITH sage_user_backdating AS (
        SELECT
          p.CREATEDBY AS user_id,
          COUNT(*) AS total_documents,
          SUM(CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
                   THEN 1 ELSE 0 END) AS backdated_documents,
          SUM(CASE WHEN DATE_TRUNC('month', p.WHENCREATED) <> DATE_TRUNC('month', p.AUWHENCREATED)
                   THEN 1 ELSE 0 END) AS cross_month_documents
        FROM analytics.intacct.PODOCUMENT p
        WHERE 1=1
          AND p.DOCPARID = 'Purchase Order'
          AND LEFT(p.DOCNO, 1) = 'E'
          {% if _filters['intacct_user_backdating.created_date'] %}
            AND {% condition created_date %} p.AUWHENCREATED {% endcondition %}
          {% endif %}
        GROUP BY 1
        HAVING SUM(CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
                        THEN 1 ELSE 0 END) > 0
      )
      SELECT
        sub.user_id,
        usr.DESCRIPTION AS user_name,
        COALESCE(cd.LOCATION, 'Unknown') AS branch_name,
        COALESCE(cd.DIRECT_MANAGER_NAME, 'Unknown') AS manager_name,
        sub.total_documents,
        sub.backdated_documents,
        sub.cross_month_documents
      FROM sage_user_backdating sub
      LEFT JOIN analytics.intacct.USERINFO usr
        ON sub.user_id = usr.RECORDNO
      LEFT JOIN analytics.intacct.CONTACT c
        ON usr.CONTACTKEY = c.RECORDNO
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
        ON LOWER(c.EMAIL1) = LOWER(cd.WORK_EMAIL)
       AND cd.rn = 1
      WHERE 1=1
        AND usr.STATUS = 'active'
        AND COALESCE(cd.EMPLOYEE_STATUS, 'Active') <> 'Terminated'
    ;;
  }

  # ===== Dimensions =====
  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}.user_name ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.branch_name ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.manager_name ;;
  }

  # ===== Measures =====
  measure: total_documents {
    type: sum
    sql: ${TABLE}.total_documents ;;
    drill_fields: [user_id, user_name, manager_name, branch_name]
  }

  measure: backdated_documents {
    type: sum
    sql: ${TABLE}.backdated_documents ;;
  }

  measure: cross_month_documents {
    type: sum
    sql: ${TABLE}.cross_month_documents ;;
  }

  # Ratios computed in Looker (good for rollups by manager/branch)
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
