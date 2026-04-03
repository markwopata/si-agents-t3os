view: retail_salesperson_simple {
  derived_table: {
    sql:
        SELECT DISTINCT I.INVOICE_ID,
                    LI.BRANCH_ID                                           AS INVOICE_MARKET_ID,
                    MRX.MARKET_NAME                                        AS INVOICE_MARKET,
                    MRX.DISTRICT                                           AS INVOICE_DISTRICT,
                    MRX.REGION_NAME                                        AS INVOICE_REGION,
                    I.BILLING_APPROVED_DATE,
                    LI.GL_BILLING_APPROVED_DATE,
                    DATE_TRUNC('MONTH', LI.GL_BILLING_APPROVED_DATE)::DATE AS MONTH,
                    I.ORDER_ID,
                    I.COMPANY_ID,
                    C.NAME                                                 AS COMPANY_NAME,
                    I.SALESPERSON_USER_ID                                  AS USER_ID,
                    SI.NAME                                                AS SALESPERSON_NAME,
                    SI.HOME_MARKET_DATED                                   AS SALESPERSON_MARKET,
                    SI.DISTRICT_DATED                                      AS SALESPERSON_DISTRICT,
                    SI.REGION_DATED                                        AS SALESPERSON_REGION,
                    SI.EMAIL_ADDRESS                                       AS SALESPERSON_EMAIL,
                    SI.EMPLOYEE_TITLE_DATED                                AS SALESPERSON_TITLE,
                    LI.LINE_ITEM_TYPE_ID,
                    LIT.NAME                                               AS LINE_ITEM_TYPE,
                    CASE
                        WHEN LI.LINE_ITEM_TYPE_ID IN (110, 80, 24) THEN 'New'
                        WHEN LI.LINE_ITEM_TYPE_ID IN (127, 123, 111, 141, 81) THEN 'Used'
                        WHEN LI.LINE_ITEM_TYPE_ID = 50 THEN 'RPO'
                        ELSE 'other'
                        END                                                AS LINE_ITEM_CATEGORY,
                    LI.ASSET_ID,
                    A.MAKE,
                    A.MODEL,
                    A.YEAR,
                    A.ASSET_CLASS,
                    LI.AMOUNT
    FROM ES_WAREHOUSE.PUBLIC.INVOICES I
             JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS LI
                  ON I.INVOICE_ID = LI.INVOICE_ID
             JOIN ANALYTICS.BI_OPS.SALESPERSON_INFO SI
                  ON I.SALESPERSON_USER_ID = SI.USER_ID
                      AND RECORD_INEFFECTIVE_DATE IS NULL
             LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK MRX
                       ON LI.BRANCH_ID = MRX.MARKET_ID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES C
                       ON I.COMPANY_ID = C.COMPANY_ID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS A
                       ON LI.ASSET_ID = A.ASSET_ID
             LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES LIT
                       ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
    WHERE I.BILLING_APPROVED = TRUE
      AND LI.LINE_ITEM_TYPE_ID IN (24, 50, 80, 81, 110, 111, 123, 141)
      AND LI.GL_BILLING_APPROVED_DATE >= DATEADD(MONTH, -12, CURRENT_DATE)
    ORDER BY I.INVOICE_ID
    ;;
  }

  dimension: rep_home_market {
    label: "Rep - Home Market"
    type: string
    sql: concat(${salesperson_name}, ' - ',${salesperson_market}) ;;
  }

  dimension: salesperson_market {
    type: string
    sql:  ${TABLE}.SALESPERSON_MARKET ;;
  }

  dimension: salesperson_district {
    type: string
    sql:  ${TABLE}.SALESPERSON_DISTRICT ;;
  }

  dimension: salesperson_region {
    type: string
    sql:  ${TABLE}.SALESPERSON_REGION ;;
  }

  dimension: salesperson_email {
    type: string
    sql:  ${TABLE}.SALESPERSON_EMAIL ;;
  }

  dimension: salesperson_title {
    type: string
    sql:  ${TABLE}.SALESPERSON_TITLE ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.INVOICE_ID ;;
  }

  dimension: invoice_admin_link {
    type: string
    sql: ${TABLE}.INVOICE_ID ;;
    link: {
      label: "Admin Link"
      url: "https://admin.equipmentshare.com/#/home/transactions/invoices/{{ value | url_encode }}"
    }
    description: "This links to the invoice on Admin"
  }

  dimension: invoice_market_id {
    type: string
    sql: ${TABLE}.INVOICE_MARKET_ID ;;
  }

  dimension: invoice_market_name {
    type: string
    sql: ${TABLE}.INVOICE_MARKET ;;
  }

  dimension: invoice_district_name {
    type: string
    sql: ${TABLE}.INVOICE_DISTRICT ;;
  }

  dimension: invoice_region_name {
    type: string
    sql: ${TABLE}.INVOICE_REGION ;;
  }

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_DATE ;;
  }

  dimension_group: billing_month {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: DATE_TRUNC('MONTH', ${TABLE}.GL_BILLING_APPROVED_DATE) ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}.GL_BILLING_APPROVED_DATE ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.ORDER_ID ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}.SALESPERSON_NAME ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.LINE_ITEM_TYPE_ID ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}.LINE_ITEM_TYPE ;;
  }

  dimension: line_item_category {
    type: string
    sql: ${TABLE}.LINE_ITEM_CATEGORY ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.ASSET_ID ;;
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
    value_format_name: id
    sql: ${TABLE}.YEAR ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.ASSET_CLASS ;;
  }

  measure: amount {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.AMOUNT ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      invoice_admin_link,
      asset_id,
      make,
      model,
      rep_home_market,
      company_name,
      amount
    ]
  }
}
