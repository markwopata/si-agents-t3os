view: retail_salesperson_invoice_detail {
  derived_table: {
    sql:
      WITH month_sales AS (
        SELECT
          I.SALESPERSON_USER_ID || '-' || YEAR(LI.GL_BILLING_APPROVED_DATE) || '-' || MONTH(LI.GL_BILLING_APPROVED_DATE) AS PK,
          I.SALESPERSON_USER_ID AS USER_ID,
          SI.NAME AS REP_NAME,
          A.MAKE,
          A.MODEL,
          A.YEAR,
          A.ASSET_CLASS,
          XWALK.MARKET_NAME AS LINE_ITEM_MARKET,
          SI.HOME_MARKET_DATED AS REP_MARKET,
          SI.DISTRICT_DATED AS REP_DISTRICT,
          SI.REGION_NAME_DATED AS REP_REGION,
          SI.DIRECT_MANAGER_NAME_PRESENT AS MANAGER_NAME,
          DATE_TRUNC('MONTH', COALESCE(LI.GL_BILLING_APPROVED_DATE, I.BILLING_APPROVED_DATE))::DATE AS BILLING_APPROVED_DATE,
          SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (110, 80, 24) THEN LI.AMOUNT ELSE 0 END) AS NEW_AMOUNT,
          SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (127, 123, 111, 141, 81) THEN LI.AMOUNT ELSE 0 END) AS USED_AMOUNT,
          SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID = 50 THEN LI.AMOUNT ELSE 0 END) AS RPO_AMOUNT,
          SUM(LI.AMOUNT) AS AMOUNT
        FROM ES_WAREHOUSE.PUBLIC.INVOICES I
        JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS LI ON I.INVOICE_ID = LI.INVOICE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A ON LI.ASSET_ID = A.ASSET_ID
        LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK ON LI.BRANCH_ID = XWALK.MARKET_ID
        JOIN ANALYTICS.BI_OPS.SALESPERSON_INFO SI ON I.SALESPERSON_USER_ID = SI.USER_ID
          AND SI.RECORD_INEFFECTIVE_DATE IS NULL
        WHERE I.BILLING_APPROVED = TRUE
          AND LI.LINE_ITEM_TYPE_ID IN (24, 50, 80, 81, 110, 111, 123, 141)
          AND LI.GL_BILLING_APPROVED_DATE >= DATEADD(MONTH, -12, CURRENT_DATE)
        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
      ),

      quarter_sales AS (
      SELECT
      I.SALESPERSON_USER_ID || '-' || YEAR(LI.GL_BILLING_APPROVED_DATE) || '-' || QUARTER(LI.GL_BILLING_APPROVED_DATE) AS PK,
      I.SALESPERSON_USER_ID AS USER_ID,
      SI.NAME AS REP_NAME,
      A.MAKE,
      A.MODEL,
      A.YEAR,
      A.ASSET_CLASS,
      XWALK.MARKET_NAME AS LINE_ITEM_MARKET,
      SI.HOME_MARKET_DATED AS REP_MARKET,
      SI.DISTRICT_DATED AS REP_DISTRICT,
      SI.REGION_NAME_DATED AS REP_REGION,
      SI.DIRECT_MANAGER_NAME_PRESENT AS MANAGER_NAME,
      DATE_TRUNC('QUARTER', COALESCE(LI.GL_BILLING_APPROVED_DATE, I.BILLING_APPROVED_DATE))::DATE AS BILLING_APPROVED_DATE,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (110, 80, 24) THEN LI.AMOUNT ELSE 0 END) AS NEW_AMOUNT,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (127, 123, 111, 141, 81) THEN LI.AMOUNT ELSE 0 END) AS USED_AMOUNT,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID = 50 THEN LI.AMOUNT ELSE 0 END) AS RPO_AMOUNT,
      SUM(LI.AMOUNT) AS AMOUNT
      FROM ES_WAREHOUSE.PUBLIC.INVOICES I
      JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS LI ON I.INVOICE_ID = LI.INVOICE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A ON LI.ASSET_ID = A.ASSET_ID
      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK ON LI.BRANCH_ID = XWALK.MARKET_ID
      JOIN ANALYTICS.BI_OPS.SALESPERSON_INFO SI ON I.SALESPERSON_USER_ID = SI.USER_ID
      AND SI.RECORD_INEFFECTIVE_DATE IS NULL
      WHERE I.BILLING_APPROVED = TRUE
      AND LI.LINE_ITEM_TYPE_ID IN (24, 50, 80, 81, 110, 111, 123, 141)
      AND LI.GL_BILLING_APPROVED_DATE >= DATEADD(MONTH, -12, CURRENT_DATE)
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
      ),

      year_sales AS (
      SELECT
      I.SALESPERSON_USER_ID || '-' || YEAR(LI.GL_BILLING_APPROVED_DATE) AS PK,
      I.SALESPERSON_USER_ID AS USER_ID,
      SI.NAME AS REP_NAME,
      A.MAKE,
      A.MODEL,
      A.YEAR,
      A.ASSET_CLASS,
      XWALK.MARKET_NAME AS LINE_ITEM_MARKET,
      SI.HOME_MARKET_DATED AS REP_MARKET,
      SI.DISTRICT_DATED AS REP_DISTRICT,
      SI.REGION_NAME_DATED AS REP_REGION,
      SI.DIRECT_MANAGER_NAME_PRESENT AS MANAGER_NAME,
      DATE_TRUNC('YEAR', COALESCE(LI.GL_BILLING_APPROVED_DATE, I.BILLING_APPROVED_DATE))::DATE AS BILLING_APPROVED_DATE,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (110, 80, 24) THEN LI.AMOUNT ELSE 0 END) AS NEW_AMOUNT,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID IN (127, 123, 111, 141, 81) THEN LI.AMOUNT ELSE 0 END) AS USED_AMOUNT,
      SUM(CASE WHEN LI.LINE_ITEM_TYPE_ID = 50 THEN LI.AMOUNT ELSE 0 END) AS RPO_AMOUNT,
      SUM(LI.AMOUNT) AS AMOUNT
      FROM ES_WAREHOUSE.PUBLIC.INVOICES I
      JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS LI ON I.INVOICE_ID = LI.INVOICE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A ON LI.ASSET_ID = A.ASSET_ID
      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK ON LI.BRANCH_ID = XWALK.MARKET_ID
      JOIN ANALYTICS.BI_OPS.SALESPERSON_INFO SI ON I.SALESPERSON_USER_ID = SI.USER_ID
      AND SI.RECORD_INEFFECTIVE_DATE IS NULL
      WHERE I.BILLING_APPROVED = TRUE
      AND LI.LINE_ITEM_TYPE_ID IN (24, 50, 80, 81, 110, 111, 123, 141)
      AND LI.GL_BILLING_APPROVED_DATE >= DATEADD(MONTH, -12, CURRENT_DATE)
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
      )

      SELECT * FROM month_sales WHERE {% parameter date_grain %} = 'month'
      UNION ALL
      SELECT * FROM quarter_sales WHERE {% parameter date_grain %} = 'quarter'
      UNION ALL
      SELECT * FROM year_sales WHERE {% parameter date_grain %} = 'year'
      ;;
  }

  # PARAMETERS
  parameter: sales_category {
    type: string
    allowed_value: { label: "New" value: "new" }
    allowed_value: { label: "Used" value: "used" }
    allowed_value: { label: "RPO" value: "rpo" }
    allowed_value: { label: "Total" value: "total" }
  }

  parameter: date_grain {
    type: string
    default_value: "month"
    allowed_value: { label: "Month" value: "month" }
    allowed_value: { label: "Quarter" value: "quarter" }
    allowed_value: { label: "Year" value: "year" }
  }
  # DIMENSIONS
  dimension: pk {
    type: string
    primary_key: yes
    sql: ${TABLE}.PK ;;
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_DATE ;;
  }

  dimension: rep_name {
    type: string
    sql: ${TABLE}.REP_NAME ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.YEAR ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.ASSET_CLASS ;;
  }

  dimension: line_item_market {
    type: string
    sql: ${TABLE}.LINE_ITEM_MARKET ;;
  }

  dimension: rep_market {
    type: string
    sql: ${TABLE}.REP_MARKET ;;
  }

  dimension: rep_district {
    type: string
    sql: ${TABLE}.REP_DISTRICT ;;
  }

  dimension: rep_region {
    type: string
    sql: ${TABLE}.REP_REGION ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.MANAGER_NAME ;;
  }

  dimension: dynamic_date {
    type: date
    sql:
      CASE
        WHEN {% parameter date_grain %} = 'month'   THEN DATE_TRUNC('MONTH', retail_salesperson_invoice_detail."BILLING_APPROVED_DATE")::DATE
        WHEN {% parameter date_grain %} = 'quarter' THEN DATE_TRUNC('QUARTER', retail_salesperson_invoice_detail."BILLING_APPROVED_DATE")::DATE
        WHEN {% parameter date_grain %} = 'year'    THEN DATE_TRUNC('YEAR', retail_salesperson_invoice_detail."BILLING_APPROVED_DATE")::DATE
      END
      ;;
  }

  #MEASURES
  measure: amount {
    type: sum
    sql: ${TABLE}.AMOUNT ;;
    value_format_name: usd_0
  }

  measure: new_amount {
    type: sum
    sql: ${TABLE}.NEW_AMOUNT ;;
    value_format_name: usd_0
  }

  measure: used_amount {
    type: sum
    sql: ${TABLE}.USED_AMOUNT ;;
    value_format_name: usd_0
  }

  measure: rpo_amount {
    type: sum
    sql: ${TABLE}.RPO_AMOUNT ;;
    value_format_name: usd_0
  }

  measure: dynamic_amount {
    type: number
    value_format_name: usd_0
    sql:
    CASE
      WHEN {% parameter sales_category %} = 'new' THEN ${new_amount}
      WHEN {% parameter sales_category %} = 'used' THEN ${used_amount}
      WHEN {% parameter sales_category %} = 'rpo' THEN ${rpo_amount}
      ELSE ${amount}
    END ;;
  }

  measure: percent_to_goal {
    type: number
    value_format_name: percent_1
    sql:
    CASE
      WHEN ${retail_sales_goals.dynamic_goal} > 0 THEN ${dynamic_amount} / ${retail_sales_goals.dynamic_goal}
      ELSE NULL
    END
  ;;
  }

}
