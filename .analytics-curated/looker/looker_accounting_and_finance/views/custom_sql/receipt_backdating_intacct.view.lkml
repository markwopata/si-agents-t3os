view: receipt_backdating_intacct {
  derived_table: {
    sql:
      WITH cd_latest AS (
        SELECT
          LOWER(WORK_EMAIL) AS email_lc,
          DIRECT_MANAGER_NAME,
          LOCATION,
          MARKET_ID,
          EMPLOYEE_STATUS,
          ROW_NUMBER() OVER (
            PARTITION BY LOWER(WORK_EMAIL)
            ORDER BY POSITION_EFFECTIVE_DATE DESC NULLS LAST
          ) AS rn
        FROM analytics.payroll.company_directory
      ),
      si_detail AS (
        SELECT
          /* identifiers */
          CAST(p.DOCNO      AS VARCHAR)                   AS purchase_order_id,
          CAST(pe.RECORDNO  AS VARCHAR)                   AS line_item_id,
          CAST(p.DOCNO      AS VARCHAR)                   AS docno,
          CAST(p.DOCID      AS VARCHAR)                   AS docid,
          CAST(p.PONUMBER   AS VARCHAR)                   AS ponumber,

      /* dates & derived */
      p.AUWHENCREATED                                  AS created_at,
      p.WHENCREATED                                    AS received_at,
      DATEDIFF('day', p.AUWHENCREATED, p.WHENCREATED)  AS days_backdated,
      CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED) THEN 1 ELSE 0 END AS is_backdated,
      CASE WHEN DATE_TRUNC('day', p.WHENCREATED) <> DATE_TRUNC('day', p.AUWHENCREATED)
      AND DATE_TRUNC('month', p.WHENCREATED) <> DATE_TRUNC('month', p.AUWHENCREATED) THEN 1 ELSE 0 END AS is_cross_month,

      /* user/org */
      CAST(usr.RECORDNO AS VARCHAR)                    AS user_id,
      usr.DESCRIPTION                                  AS user_name,
      COALESCE(cd.LOCATION, 'Unknown')                 AS department_name,
      COALESCE(TO_VARCHAR(cd.MARKET_ID), 'Unknown')    AS department_id,
      COALESCE(cd.DIRECT_MANAGER_NAME, 'Unknown')      AS manager_name,
      COALESCE(cd.EMPLOYEE_STATUS, 'Active')           AS employee_status,

      /* items + line values */
      CAST(pe.ITEMID AS VARCHAR)                       AS item_id,
      pe.ITEM_ITEMTYPE                                 AS item_type,
      pe.QUANTITY                                      AS total_quantity,            -- kept for reference; not exposed as a metric
      pe.QUANTITY                                      AS total_accepted_quantity,
      pe.PRICE                                         AS unit_price,
      pe.TOTAL                                         AS total_accepted_value

      FROM analytics.intacct.PODOCUMENTENTRY pe
      LEFT JOIN analytics.intacct.PODOCUMENT p
      ON pe.DOCHDRID = p.DOCID
      LEFT JOIN analytics.intacct.USERINFO usr
      ON p.CREATEDBY = usr.RECORDNO
      LEFT JOIN analytics.intacct.CONTACT c
      ON usr.CONTACTKEY = c.RECORDNO
      LEFT JOIN cd_latest cd
      ON LOWER(c.EMAIL1) = cd.email_lc AND cd.rn = 1
      WHERE 1=1
      AND p.DOCPARID = 'Purchase Order'
      AND LEFT(p.DOCNO, 1) = 'E'
      )
      SELECT * FROM si_detail
      ;;
  }

  # -----------------------
  # Dimensions
  # -----------------------

  # IDs
  dimension: purchase_order_id { type: string sql: ${TABLE}.purchase_order_id ;; }
  dimension: line_item_id      { type: string sql: ${TABLE}.line_item_id ;; }
  dimension: docno             { type: string sql: ${TABLE}.docno ;; }
  dimension: docid             { type: string sql: ${TABLE}.docid ;; }
  dimension: ponumber          { type: string sql: ${TABLE}.ponumber ;; }
  # (no receiver_id in Intacct)

  # Dates (for grouping/visuals)
  dimension_group: created_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension_group: received_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.received_at ;;
  }

  # User / Org
  dimension: user_id         { type: string sql: ${TABLE}.user_id ;; }
  dimension: user_name       { type: string sql: ${TABLE}.user_name ;; }
  dimension: department_name     { type: string sql: ${TABLE}.department_name ;; }
  dimension: department_id     { type: string sql: ${TABLE}.department_id ;; }
  dimension: manager_name    { type: string sql: ${TABLE}.manager_name ;; }
  dimension: employee_status { type: string sql: ${TABLE}.employee_status ;; }

  # Item / Line
  dimension: item_id   { type: string sql: ${TABLE}.item_id ;; }
  dimension: item_type { type: string sql: ${TABLE}.item_type ;; }

  # Flags
  dimension: is_backdated   { type: yesno sql: ${TABLE}.is_backdated = 1 ;; }
  dimension: is_cross_month { type: yesno sql: ${TABLE}.is_cross_month = 1 ;; }
  dimension: days_backdated { type: number sql: ${TABLE}.days_backdated ;; }

  # -----------------------
  # Measures (Accepted-focused)
  # -----------------------

  # Core accepted totals
  measure: total_accepted_quantity { type: sum sql: ${TABLE}.total_accepted_quantity ;; }
  measure: total_accepted_value    { type: sum sql: ${TABLE}.total_accepted_value ;; value_format_name: decimal_2 }

  # Backdated accepted totals
  measure: backdated_accepted_quantity {
    type: sum
    sql: CASE WHEN ${is_backdated} THEN ${TABLE}.total_accepted_quantity ELSE 0 END ;;
  }
  measure: backdated_accepted_value {
    type: sum
    sql: CASE WHEN ${is_backdated} THEN ${TABLE}.total_accepted_value ELSE 0 END ;;
    value_format_name: decimal_2
  }

  # % Backdated by accepted quantity/value
  measure: pct_backdated_quantity {
    type: number
    sql: NULLIF(${backdated_accepted_quantity},0) / NULLIF(${total_accepted_quantity},0) ;;
    value_format_name: percent_2
    label: "% Backdated (Qty)"
  }
  measure: pct_backdated_value {
    type: number
    sql: NULLIF(${backdated_accepted_value},0) / NULLIF(${total_accepted_value},0) ;;
    value_format_name: percent_2
    label: "% Backdated (Value)"
  }

  # Cross-month accepted totals and %
  measure: cross_month_accepted_quantity {
    type: sum
    sql: CASE WHEN ${is_cross_month} THEN ${TABLE}.total_accepted_quantity ELSE 0 END ;;
  }
  measure: cross_month_accepted_value {
    type: sum
    sql: CASE WHEN ${is_cross_month} THEN ${TABLE}.total_accepted_value ELSE 0 END ;;
    value_format_name: decimal_2
  }
  measure: pct_cross_month_quantity {
    type: number
    sql: NULLIF(${cross_month_accepted_quantity},0) / NULLIF(${total_accepted_quantity},0) ;;
    value_format_name: percent_2
    label: "% Cross-Month (Qty)"
  }
  measure: pct_cross_month_value {
    type: number
    sql: NULLIF(${cross_month_accepted_value},0) / NULLIF(${total_accepted_value},0) ;;
    value_format_name: percent_2
    label: "% Cross-Month (Value)"
  }

  # Days backdated rollups
  measure: avg_abs_days_backdated {
    type: average
    sql: CASE WHEN ${is_backdated} THEN ABS(${TABLE}.days_backdated) END ;;
    value_format_name: decimal_1
    label: "Avg Abs Days Backdated (Backdated Only)"
  }
  measure: max_abs_days_backdated {
    type: max
    sql: CASE WHEN ${is_backdated} THEN ABS(${TABLE}.days_backdated) END ;;
    value_format_name: decimal_0
    label: "Max Abs Days Backdated (Backdated Only)"
  }

  measure: backdated_receipts {
    label: "Backdated Receipts"
    type: count_distinct
    sql: ${docid} ;;
    # Use a measure-level filter so the drill stays scoped to backdated only
    filters: [is_backdated: "yes"]
    value_format_name: decimal_0

    drill_fields: [
      docid,                           # one row per receipt (groups the drill)
      user_name,
      department_name,
      manager_name,
      total_accepted_quantity,
      total_accepted_value,
      backdated_accepted_quantity,
      backdated_accepted_value,
      pct_backdated_quantity,
      pct_backdated_value,
      cross_month_accepted_quantity,
      cross_month_accepted_value,
      pct_cross_month_quantity,
      pct_cross_month_value
    ]
  }

}
