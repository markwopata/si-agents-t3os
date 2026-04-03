view: ar_aging_with_class {
  derived_table: {
    sql: WITH cust_geo_type AS (SELECT DISTINCT ARH.CUSTOMERID,
--COUNT(DISTINCT ARD.DEPARTMENTID)     AS MKT_COUNT,
--COUNT(DISTINCT MKT_REG.REGION_ID)    AS REG_COUNT,
                                       CASE
                                           WHEN COUNT(DISTINCT ARD.DEPARTMENTID) = 1 THEN 'Local'
                                           ELSE CASE
                                                    WHEN COUNT(DISTINCT ARD.DEPARTMENTID)
                                                             > 1
                                                        AND COUNT(DISTINCT MKT_REG.REGION_ID) = 1 THEN 'Regional'
                                                    ELSE 'National' END END AS CUSTOMER_GEO_TYPE
                       FROM ANALYTICS.INTACCT.ARRECORD ARH
                                LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD
                                          ON ARH.RECORDNO = ARD.RECORDKEY
                                LEFT JOIN (SELECT DIST_REG.MARKET_ID   AS BRANCH_ID
                                                , DIST_REG.DISTRICT_ID AS DISTRICT_ID
                                                , MIN(DIST.NAME)       AS DISTRICT_NAME
                                                , DIST_REG.REGION_ID   AS REGION_ID
                                                , MIN(REG.NAME)        AS REGION_NAME
                                           FROM (SELECT TO_CHAR(MKT.MARKET_ID) AS MARKET_ID
                                                      , MIN(MKT.DISTRICT_ID)   AS DISTRICT_ID
                                                      , MIN(XWALK.REGION)      AS REGION_ID
                                                 FROM ES_WAREHOUSE.PUBLIC.MARKETS MKT
                                                          LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK
                                                                    ON MKT.MARKET_ID = XWALK.MARKET_ID
                                                 WHERE MKT.COMPANY_ID = '1854'
                                                   AND MKT.ACTIVE = TRUE
                                                 GROUP BY TO_CHAR(MKT.MARKET_ID)) DIST_REG
                                                    LEFT JOIN ES_WAREHOUSE.PUBLIC.REGIONS REG ON DIST_REG.REGION_ID = REG.REGION_ID
                                                    LEFT JOIN ES_WAREHOUSE.PUBLIC.DISTRICTS DIST
                                                              ON DIST_REG.DISTRICT_ID = DIST.DISTRICT_ID
                                           GROUP BY DIST_REG.MARKET_ID
                                                  , DIST_REG.DISTRICT_ID
                                                  , DIST_REG.REGION_ID) MKT_REG ON MKT_REG.BRANCH_ID = ARD.DEPARTMENTID
                       WHERE ARH.RECORDTYPE IN (
                                                'arinvoice', 'aradjustment')
                       GROUP BY ALL),
    disputes_flag AS (
        SELECT DISTINCT
            inv.INVOICE_NO,
            'Yes' AS Disputed
        FROM ES_WAREHOUSE.PUBLIC.INVOICES inv
        INNER JOIN ES_WAREHOUSE.PUBLIC.DISPUTES d
            ON inv.INVOICE_ID = d.INVOICE_ID
            )
     ,data AS (SELECT ARH.CUSTOMERID                                                                                                    AS CUSTOMER_ID,
                     CUST.NAME                                                                                                         AS CUSTOMER_NAME,
                     CASE WHEN Cust.termname ilike '%CASH ON%' THEN 'Yes' ElSE 'No' END                                                     AS COD,
                     COALESCE(ARH.WHENPOSTED, ARH.WHENPAID)                                                                            AS POST_DATE,
                     CASE
                         WHEN ARH.RECORDTYPE = 'aradvance' THEN ARH.DOCNUMBER
                         ELSE ARH.RECORDID END                                                                                         AS DOCUMENT,
                         COALESCE(disputes.Disputed, 'No') AS Disputed,
                     ARH.WHENDUE                                                                                                       AS DUE_DATE,
                     CASE
                         WHEN ARH.WHENDUE IS NULL THEN 0
                         ELSE TO_DATE({% date_end date_filter %}) - ARH.WHENDUE END                                                                           AS AGE,
                     ARH.RECORDTYPE                                                                                                    AS RECORD_TYPE,
                     ARD.ACCOUNTNO                                                                                                     AS ACCOUNT,
                     GLA.TITLE                                                                                                         AS ACCOUNT_NAME,
                     COALESCE(ARD.AMOUNT, 0)                                                                                           AS ORIG_AMOUNT,
                     COALESCE(ARP_INV.AMT * -1, 0)                                                                                     AS AMT_PAID,
                     COALESCE(ARP_CM.AMT, 0)                                                                                           AS AMT_CM_APPLIED,
                     COALESCE(ROUND(ARDET1.AMT, 2), 0) * -1                                                                            AS PAYMENT_APPLIED,
                     ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED                                                         AS BALANCE,
                     CASE WHEN AGE <= 0 THEN BALANCE ELSE 0 END                                                                        AS A_0_OR_LESS,
                     CASE WHEN AGE BETWEEN 1 AND 30 THEN BALANCE ELSE 0 END                                                            AS A_1_TO_30,
                     CASE WHEN AGE BETWEEN 31 AND 60 THEN BALANCE ELSE 0 END                                                           AS A_31_TO_60,
                     CASE WHEN AGE BETWEEN 61 AND 90 THEN BALANCE ELSE 0 END                                                           AS A_61_TO_90,
                     CASE WHEN AGE BETWEEN 91 AND 120 THEN BALANCE ELSE 0 END                                                          AS A_91_TO_120,
                     CASE WHEN AGE >= 121 THEN BALANCE ELSE 0 END                                                                      AS A_121_AND_UP,
                     COALESCE(COLLECTOR.COLLECTOR, '(No Collector Assigned)')                                                          AS COLLECTOR,
                     CASE
                         WHEN COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') = 'COD' THEN 'Cash on Delivery'
                         ELSE COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') END                                              AS PAY_TERMS,
                     COALESCE(CASE
                                  WHEN ARD.ACCOUNTNO = '2210' THEN (CASE
                                                                        WHEN SALES_TAX.RECORDNO IS NULL
                                                                            THEN 'Sales Tax - Non Rental'
                                                                        ELSE 'Sales Tax - Rental' END)
                                  ELSE (FN_ACCT.FN_ALLOCATION) END,
                              'N/A')                                                                                                   AS FN_ALLOC,
                     CECL_GRP."GROUP"                                                                                                  AS COLLECT_GROUP,
                     SUM(COALESCE(ARD.AMOUNT, 0))
                         OVER (PARTITION BY ARH.CUSTOMERID, CUST.NAME, ARH.DOCNUMBER, ARD.LOCATIONID, ARD.ACCOUNTNO, ARD.DEPARTMENTID) AS REVERSED,
                     g.CUSTOMER_GEO_TYPE
              FROM ANALYTICS.INTACCT.ARRECORD ARH
                       LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH.CUSTOMERID = CUST.CUSTOMERID
                       LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
                       LEFT JOIN (SELECT ARP.RECORDKEY,
                                         ARP.PAIDITEMKEY,
                                         SUM(ARP.TRX_AMOUNT) AS AMT
                                  FROM ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                                  WHERE ARP.PAYMENTDATE <= {% date_end date_filter %}
                                  GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_INV
                                 ON ARH.RECORDNO = ARP_INV.RECORDKEY AND ARD.RECORDNO = ARP_INV.PAIDITEMKEY
                       LEFT JOIN (SELECT ARP.PAYMENTKEY,
                                         ARP.PAYITEMKEY,
                                         SUM(ARP.TRX_AMOUNT) AS AMT
                                  FROM ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                                  WHERE ARP.PAYMENTDATE <= {% date_end date_filter %}
                                  GROUP BY ARP.PAYMENTKEY, ARP.PAYITEMKEY) ARP_CM
                                 ON ARH.RECORDNO = ARP_CM.PAYMENTKEY AND ARD.RECORDNO = ARP_CM.PAYITEMKEY
                       LEFT JOIN
                   (SELECT ARD.RECORDKEY,
                           SUM(ARIP.AMOUNT) AS AMT
                    FROM ANALYTICS.INTACCT.ARDETAIL ARD
                             LEFT JOIN
                         ANALYTICS.INTACCT.ARDETAIL ARIP ON ARD.RECORDNO = ARIP.PARENTENTRY
                    WHERE ARIP.ENTRY_DATE <= {% date_end date_filter %}
                    GROUP BY ARD.RECORDKEY) AS ARDET1 ON ARH.RECORDNO = ARDET1.RECORDKEY
                       LEFT JOIN(SELECT DISTINCT CCA.COMPANY_ID                                AS CUSTOMER_ID,
                                                 CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS MARKET,
                                                 CASE
                                                     WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL'
                                                     ELSE CCA.FINAL_COLLECTOR END              AS COLLECTOR
                                 FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                                          LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                                    ON CCA.COMPANY_ID = COGL.CUSTOMER_ID) COLLECTOR
                                ON TRY_TO_NUMBER(ARH.CUSTOMERID) = COLLECTOR.CUSTOMER_ID
                       LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
                       LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD.DEPARTMENTID = DEPT.DEPARTMENTID
                       LEFT JOIN(SELECT CUST.COMPANY_ID AS CUSTOMER_ID,
                                        TERMS.NAME      AS ADMIN_TERM
                                 FROM ES_WAREHOUSE.PUBLIC.COMPANIES CUST
                                          LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS TERMS
                                                    ON CUST.NET_TERMS_ID = TERMS.NET_TERMS_ID) ADMIN_TERM
                                ON CUST.CUSTOMERID = TO_CHAR(ADMIN_TERM.CUSTOMER_ID)
                       LEFT JOIN (SELECT COMPANY_ID, "GROUP", AS_OF_DATE
                                  FROM ANALYTICS.FINANCIAL_SYSTEMS.CECL_CUST_COLLECT_GRP
                                  QUALIFY ROW_NUMBER() OVER (PARTITION BY COMPANY_ID ORDER BY AS_OF_DATE DESC) = 1) CECL_GRP
                                 ON ARH.CUSTOMERID = TO_CHAR(CECL_GRP.COMPANY_ID)
                       LEFT JOIN(SELECT ACCT_CLASS.GL_ACCOUNT,
                                        ACCT_CLASS.FN_ALLOCATION
                                 FROM ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS ACCT_CLASS
                                 WHERE ACCT_CLASS.VERSION = '4'
--                               {% condition version_filter %} ACCT_CLASS.VERSION {% endcondition %}
                                   AND ACCT_CLASS.GL_ACCOUNT != '2210') FN_ACCT ON ARD.ACCOUNTNO = FN_ACCT.GL_ACCOUNT
                       LEFT JOIN (SELECT DISTINCT ARH2.RECORDNO
                                  FROM ANALYTICS.INTACCT.ARRECORD ARH2
                                           LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD2 ON ARH2.RECORDNO = ARD2.RECORDKEY
                                           JOIN (SELECT ACCT_CLASS.GL_ACCOUNT
                                                 FROM ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS ACCT_CLASS
                                                 WHERE ACCT_CLASS.VERSION = '4'
--                                             {% condition version_filter %} ACCT_CLASS.VERSION {% endcondition %}
                                                   AND ACCT_CLASS.FN_ALLOCATION = 'Rental') ARD3
                                                ON ARD2.ACCOUNTNO = ARD3.GL_ACCOUNT
                                  WHERE ARH2.RECORDTYPE IN ('arinvoice', 'aradvance', 'aradjustment')) SALES_TAX
                                 ON ARH.RECORDNO = SALES_TAX.RECORDNO
                       LEFT JOIN cust_geo_type g ON ARH.CUSTOMERID = g.CUSTOMERID
                       LEFT JOIN disputes_flag disputes
                                ON ARH.DOCNUMBER = disputes.INVOICE_NO
              WHERE ((ARH.WHENPOSTED <= {% date_end date_filter %} AND ARH.RECORDTYPE != 'aradvance')
      OR  (ARH.WHENPAID  <= {% date_end date_filter %} AND ARH.RECORDTYPE = 'aradvance'))
    AND ARH.RECORDTYPE NOT IN ('arpayment', 'aroverpayment')
    AND ROUND(ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED, 2) != 0
      AND COALESCE(
        CASE
          WHEN ARD.ACCOUNTNO = '2210' THEN
            CASE WHEN SALES_TAX.RECORDNO IS NULL THEN 'Sales Tax - Non Rental'
                 ELSE 'Sales Tax - Rental' END
          ELSE FN_ACCT.FN_ALLOCATION
        END
      , 'N/A'
      ) <> 'OEM Receivable'
    QUALIFY REVERSED <> 0
  ORDER BY DOCNUMBER)

SELECT *
FROM data

    ;;
  }

  filter: date_filter {
    type: date
  }

  filter: version_filter {
    type: string
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: cod {
    type: string
    sql: ${TABLE}.COD ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}.POST_DATE ;;
  }

  dimension: document {
    type: string
    sql: ${TABLE}.DOCUMENT ;;
  }

  dimension: disputed {
    type: string
    sql: ${TABLE}.DISPUTED ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.AGE ;;
  }

  dimension: balance {
    type: number
    sql: ${TABLE}.BALANCE ;;
  }

  dimension: fn_alloc {
    type: string
    sql: ${TABLE}.FN_ALLOC ;;
    label: "FN Allocation"
  }

  dimension: customer_geo_type {
    type: string
    sql: ${TABLE}.CUSTOMER_GEO_TYPE ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.ACCOUNT ;;
    label: "Account"
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.ACCOUNT_NAME ;;
    label: "Account Name"
  }

  measure: ag_0_or_less {
    label: "Age 0 or Less"
    type: sum
    sql: CASE WHEN ${age} <= 0 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: ag_1_to_30 {
    label: "Age 1 to 30"
    type: sum
    sql: CASE WHEN ${age} BETWEEN 1 AND 30 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: ag_31_to_60 {
    label: "Age 31 to 60"
    type: sum
    sql: CASE WHEN ${age} BETWEEN 31 AND 60 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: ag_61_to_90 {
    label: "Age 61 to 90"
    type: sum
    sql: CASE WHEN ${age} BETWEEN 61 AND 90 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: ag_91_to_120 {
    label: "Age 91 to 120"
    type: sum
    sql: CASE WHEN ${age} BETWEEN 91 AND 120 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: ag_121_and_up {
    label: "Age 121 and Up"
    type: sum
    sql: CASE WHEN ${age} >= 121 THEN ${balance} ELSE 0 END ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: total_balance {
    type: sum
    sql: ${balance} ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  measure: class_balance {
    type: sum
    sql: ${balance} ;;
    value_format_name: "usd"
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      customer_id,
      customer_name,
      cod,
      post_date,
      document,
      disputed,
      due_date,
      age,
      balance,
      fn_alloc,
      customer_geo_type,
      account,
      account_name
    ]
  }
}
