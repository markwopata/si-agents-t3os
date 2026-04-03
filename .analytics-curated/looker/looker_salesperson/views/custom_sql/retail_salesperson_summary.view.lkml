view: retail_salesperson_summary {
  derived_table: {
    sql:
        WITH monthly_goals AS (
          SELECT
            USER_ID,
            DATE_FROM_PARTS(YEAR, MONTH, 1) AS BILLING_APPROVED_MONTH,
            MAX(NEW_REV_GOAL) AS NEW_REV_GOAL,
            MAX(USED_REV_GOAL) AS USED_REV_GOAL,
            MAX(RPO_REV_GOAL) AS RPO_REV_GOAL,
            MAX(NEW_REV_GOAL + USED_REV_GOAL + RPO_REV_GOAL) AS TOTAL_REV_GOAL
          FROM ANALYTICS.BI_OPS.RAM_GOALS
          GROUP BY USER_ID, YEAR, MONTH
        ),
        invoice_lines AS (
          SELECT
            I.SALESPERSON_USER_ID AS USER_ID,
            SI.NAME AS NAME,
            A.MAKE AS MAKE,
            A.MODEL AS MODEL,
            A.YEAR AS YEAR,
            A.ASSET_CLASS AS ASSET_CLASS,
            SI.HOME_MARKET_DATED AS REP_MARKET,
            SI.DISTRICT_DATED AS DISTRICT,
            SI.REGION_NAME_DATED AS REGION,
            SI.DIRECT_MANAGER_NAME_PRESENT AS MANAGER_NAME,
            DATE_TRUNC('MONTH', LI.GL_BILLING_APPROVED_DATE)::DATE AS BILLING_APPROVED_MONTH,
            DATE_TRUNC('QUARTER', LI.GL_BILLING_APPROVED_DATE)::DATE AS BILLING_APPROVED_QUARTER,
            DATE_TRUNC('YEAR', LI.GL_BILLING_APPROVED_DATE)::DATE AS BILLING_APPROVED_YEAR,
            SUM(LI.AMOUNT) AS AMOUNT
          FROM ES_WAREHOUSE.PUBLIC.INVOICES I
          JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS LI ON I.INVOICE_ID = LI.INVOICE_ID
          LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES C ON I.COMPANY_ID = C.COMPANY_ID
          LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A ON LI.ASSET_ID = A.ASSET_ID
          JOIN ANALYTICS.BI_OPS.SALESPERSON_INFO SI ON I.SALESPERSON_USER_ID = SI.USER_ID
            AND SI.RECORD_INEFFECTIVE_DATE IS NULL
          WHERE I.BILLING_APPROVED = TRUE
            AND LI.LINE_ITEM_TYPE_ID IN (24, 50, 80, 81, 110, 111, 123, 141)
            AND LI.GL_BILLING_APPROVED_DATE >= DATEADD(MONTH, -12, CURRENT_DATE)
          GROUP BY
            I.SALESPERSON_USER_ID,
            SI.NAME,
            SI.HOME_MARKET_DATED,
            SI.DISTRICT_DATED,
            SI.REGION_NAME_DATED,
            SI.DIRECT_MANAGER_NAME_PRESENT,
            DATE_TRUNC('MONTH', LI.GL_BILLING_APPROVED_DATE)::DATE,
            DATE_TRUNC('QUARTER', LI.GL_BILLING_APPROVED_DATE)::DATE,
            DATE_TRUNC('YEAR', LI.GL_BILLING_APPROVED_DATE)::DATE,
            A.MAKE,
            A.MODEL,
            A.YEAR,
            A.ASSET_CLASS
        )
        SELECT
          G.USER_ID,
          IL.REP_MARKET AS SALESPERSON_MARKET,
          IL.DISTRICT,
          IL.REGION,
          IL.MANAGER_NAME,
          IL.NAME AS SALESPERSON_NAME,
          G.BILLING_APPROVED_MONTH AS BILLING_APPROVED_DATE,
          G.BILLING_APPROVED_MONTH,
          COALESCE(IL.BILLING_APPROVED_QUARTER, DATE_TRUNC('QUARTER', G.BILLING_APPROVED_MONTH)) AS BILLING_APPROVED_QUARTER,
          COALESCE(IL.BILLING_APPROVED_YEAR, DATE_TRUNC('YEAR', G.BILLING_APPROVED_MONTH)) AS BILLING_APPROVED_YEAR,
          COALESCE(IL.NAME, '') AS NAME,
          COALESCE(IL.AMOUNT, 0) AS AMOUNT,
          G.NEW_REV_GOAL,
          G.USED_REV_GOAL,
          G.RPO_REV_GOAL,
          G.TOTAL_REV_GOAL
        FROM monthly_goals G
        LEFT JOIN invoice_lines IL
          ON G.USER_ID = IL.USER_ID
          AND G.BILLING_APPROVED_MONTH = IL.BILLING_APPROVED_MONTH
      ;;
  }

  dimension: rep_home_market {
    label: "Rep - Home Market"
    type: string
    sql: concat(${salesperson_name}, ' - ',${salesperson_market}) ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: salesperson_market {
    type: string
    sql: ${TABLE}.SALESPERSON_MARKET ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.REGION ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.MANAGER_NAME ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}.SALESPERSON_NAME ;;
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_DATE ;;
  }

  dimension_group: billing_approved_month {
    type: time
    sql: ${TABLE}.BILLING_APPROVED_MONTH ;;
    timeframes: [time, date, week, month, quarter, year]
  }

  dimension: billing_approved_quarter {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_QUARTER ;;
  }

  dimension: billing_approved_year {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_YEAR ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}.AMOUNT ;;
    value_format_name: usd
  }

  measure: new_rev_goal {
    type: max
    sql: ${TABLE}.NEW_REV_GOAL ;;
    value_format_name: usd
  }

  measure: used_rev_goal {
    type: max
    sql: ${TABLE}.USED_REV_GOAL ;;
    value_format_name: usd
  }

  measure: rpo_rev_goal {
    type: max
    sql: ${TABLE}.RPO_REV_GOAL ;;
    value_format_name: usd
  }

  measure: total_rev_goal {
    type: max
    sql: ${TABLE}.TOTAL_REV_GOAL ;;
    value_format_name: usd
  }
}
