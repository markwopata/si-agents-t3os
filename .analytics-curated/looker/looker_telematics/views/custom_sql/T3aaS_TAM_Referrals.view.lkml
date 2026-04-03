view: T3aaS_TAM_Referrals{
  derived_table: {
    sql:
    WITH mid_market_deals AS (
    SELECT DISTINCT
        DEAL.deal_id AS DEAL_ID
    FROM ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL DEAL
    WHERE
        DEAL.deal_pipeline_id = '135406348'
        AND DEAL.PROPERTY_DIRECT_SALE_MORE_THAN_100_ASSETS = 'T3 TAM Referral'
),

post_sale_deals AS (
    SELECT DISTINCT
        DEAL.deal_id AS DEAL_ID,
        DEAL.property_es_admin_id AS ES_ADMIN_ID,
        DATE(DEAL.property_closedate) AS CLOSE_DATE,
        DEAL.property_tam_email_address AS TAM_EMAIL
    FROM ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.DEAL DEAL
    WHERE
        DEAL.deal_pipeline_id = 'b09afe71-b55e-4fca-9392-397cf0fbe287'
        AND DEAL.PROPERTY_DIRECT_SALE_MORE_THAN_100_ASSETS = 'T3 TAM Referral'
),

filtered_invoices AS (
    SELECT
        I.BILLING_APPROVED_DATE::DATE AS billing_date,
        I.PAID,
        U.COMPANY_ID,
        ROW_NUMBER() OVER (PARTITION BY U.COMPANY_ID ORDER BY I.BILLING_APPROVED_DATE) AS rn
    FROM ES_WAREHOUSE.PUBLIC.INVOICES AS I
    LEFT JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS AS PO
        ON I.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS AS LI
        ON I.INVOICE_ID = LI.INVOICE_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES AS LIT
        ON LI.LINE_ITEM_TYPE_ID = LIT.LINE_ITEM_TYPE_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS AS O
        ON I.ORDER_ID = O.ORDER_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
        ON O.USER_ID = U.USER_ID
    WHERE
        LI.LINE_ITEM_TYPE_ID = 33
        AND I.BILLING_APPROVED_DATE >= '2020-01-01'
        AND U.COMPANY_ID <> 1854
    GROUP BY
        I.BILLING_APPROVED_DATE, I.PAID, U.COMPANY_ID
),

ranked_invoices AS (
    SELECT
        COMPANY_ID,
        MAX(CASE WHEN rn = 1 THEN billing_date END) AS invoice_date_1,
        MAX(CASE WHEN rn = 2 THEN billing_date END) AS invoice_date_2,
        MAX(CASE WHEN rn = 3 THEN billing_date END) AS invoice_date_3,
        MAX(CASE WHEN rn = 1 THEN IFF(PAID, 1, 0) END) AS paid_1,
        MAX(CASE WHEN rn = 2 THEN IFF(PAID, 1, 0) END) AS paid_2,
        MAX(CASE WHEN rn = 3 THEN IFF(PAID, 1, 0) END) AS paid_3
    FROM filtered_invoices
    WHERE rn <= 3
    GROUP BY COMPANY_ID
),

admin_info_with_commission AS (
    SELECT
        COMPANY_ID,
        invoice_date_1,
        paid_1,
        invoice_date_2,
        paid_2,
        invoice_date_3,
        paid_3,
        CASE
            WHEN paid_1 = 1 AND paid_2 = 1 AND paid_3 = 1 THEN 'Yes'
            ELSE 'No'
        END AS commission_payout
    FROM ranked_invoices
)

SELECT
    psd.DEAL_ID,
    psd.ES_ADMIN_ID,
    psd.CLOSE_DATE,
    psd.TAM_EMAIL,
    a.INVOICE_DATE_1,
    a.PAID_1,
    a.INVOICE_DATE_2,
    a.PAID_2,
    a.INVOICE_DATE_3,
    a.PAID_3,
    a.COMMISSION_PAYOUT
FROM post_sale_deals psd
LEFT JOIN mid_market_deals mmd
    ON psd.DEAL_ID = mmd.DEAL_ID
LEFT JOIN admin_info_with_commission a
    ON a.COMPANY_ID = psd.ES_ADMIN_ID
    ;;}

  dimension: DEAL_ID {
    type: string
    sql: ${TABLE}.DEAL_ID ;;
  }

  dimension: ES_ADMIN_ID {
    type: string
    sql: ${TABLE}.ES_ADMIN_ID ;;
  }

  dimension: CLOSE_DATE {
    type: date
    sql: ${TABLE}.CLOSE_DATE ;;
  }

  dimension: TAM_EMAIL {
    type: string
    sql: ${TABLE}.TAM_EMAIL ;;
  }

  dimension: INVOICE_DATE_1 {
    type: date
    sql: ${TABLE}.INVOICE_DATE_1 ;;
  }

  dimension: PAID_1 {
    type: string
    sql: ${TABLE}.PAID_1 ;;
  }

  dimension: INVOICE_DATE_2 {
    type: date
    sql: ${TABLE}.INVOICE_DATE_2 ;;
  }

  dimension: PAID_2 {
    type: string
    sql: ${TABLE}.PAID_2 ;;
  }

  dimension: INVOICE_DATE_3 {
    type: date
    sql: ${TABLE}.INVOICE_DATE_3 ;;
  }

  dimension: PAID_3 {
    type: string
    sql: ${TABLE}.PAID_3 ;;
  }

  dimension: COMMISSION_PAYOUT {
    type: string
    sql: ${TABLE}.COMMISSION_PAYOUT ;;
  }


}
