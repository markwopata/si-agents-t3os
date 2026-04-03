view: receipt_backdating_cc {
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
      cc_detail AS (
        SELECT
          /* identifiers */
          CAST(r.PURCHASE_ORDER_RECEIVER_ID   AS VARCHAR)  AS receiver_id,
          CAST(r.PURCHASE_ORDER_ID            AS VARCHAR)  AS purchase_order_id,
          CAST(li.PURCHASE_ORDER_LINE_ITEM_ID AS VARCHAR)  AS line_item_id,

      /* dates & derived */
      r.DATE_CREATED                                    AS created_at,
      r.DATE_RECEIVED                                   AS received_at,
      DATEDIFF('day', r.DATE_CREATED, r.DATE_RECEIVED)  AS days_backdated,
      CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED) THEN 1 ELSE 0 END AS is_backdated,
      CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
      AND DATE_TRUNC('month', r.DATE_RECEIVED) <> DATE_TRUNC('month', r.DATE_CREATED) THEN 1 ELSE 0 END AS is_cross_month,

      /* user/org */
      CAST(u.USER_ID AS VARCHAR)                        AS user_id,
      (u.FIRST_NAME || ' ' || u.LAST_NAME)              AS user_name,
      COALESCE(cd.LOCATION, 'Unknown')                  AS branch_name,
      COALESCE(TO_VARCHAR(cd.MARKET_ID), 'Unknown')     AS branch_id,
      COALESCE(cd.DIRECT_MANAGER_NAME, 'Unknown')       AS manager_name,
      COALESCE(cd.EMPLOYEE_STATUS, 'Active')            AS employee_status,

      /* items + line values */
      CAST(i.ITEM_ID AS VARCHAR)                        AS item_id,
      i.ITEM_TYPE                                       AS item_type,
      li.QUANTITY                                       AS total_quantity,            -- kept for reference; not exposed as a metric
      li.TOTAL_ACCEPTED                                 AS total_accepted_quantity,
      li.PRICE_PER_UNIT                                 AS unit_price,
      (li.TOTAL_ACCEPTED * li.PRICE_PER_UNIT)           AS total_accepted_value

      FROM procurement.public.purchase_order_receivers r
      LEFT JOIN procurement.public.purchase_order_line_items li
      ON li.PURCHASE_ORDER_ID = r.PURCHASE_ORDER_ID
      LEFT JOIN procurement.public.items i
      ON i.ITEM_ID = li.ITEM_ID
      LEFT JOIN es_warehouse.public.users u
      ON r.CREATED_BY_ID = u.USER_ID
      LEFT JOIN cd_latest cd
      ON LOWER(u.USERNAME) = cd.email_lc AND cd.rn = 1
      WHERE 1=1
      )
      SELECT * FROM cc_detail
      ;;
  }

  # -----------------------
  # Dimensions
  # -----------------------

  # IDs
  dimension: receiver_id       { type: string sql: ${TABLE}.receiver_id ;; }
  dimension: purchase_order_id { type: string sql: ${TABLE}.purchase_order_id ;; }
  dimension: line_item_id      { type: string sql: ${TABLE}.line_item_id ;; }

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
  dimension: branch_name     { type: string sql: ${TABLE}.branch_name ;; }
  dimension: branch_id     { type: string sql: ${TABLE}.branch_id ;; }
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

  # Days backdated rollups (useful aggregates; safe at scale)
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

  # Backdated receipts (count of distinct receiver_ids where is_backdated = Yes)
  measure: backdated_receipts {
    label: "Backdated Receipts"
    type: count_distinct
    sql: ${receiver_id} ;;
    filters: [is_backdated: "yes"]         # keeps the drill scoped to backdated
    value_format_name: decimal_0

    drill_fields: [
      receiver_id,                         # one row per receipt
      user_name,
      branch_name,
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
