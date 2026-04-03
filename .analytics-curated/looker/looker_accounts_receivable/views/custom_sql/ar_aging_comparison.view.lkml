view: ar_aging_comparison {
  derived_table: {
    sql:
SELECT
    HEADER_RECORDNO,
    CUSTOMER_ID,
    CUSTOMER_NAME,
    ADDRESS_LINE_1,
    ADDRESS_LINE_2,
    CITY,
    STATE,
    ZIP,
    DO_NOT_RENT,
    POST_DATE,
    DOCUMENT,
    DUE_DATE,
    AGE,
    RECORD_ID,
    REF_NUMBER,
    PAY_METHOD,
    RECORD_TYPE,
    DETAIL_RECORDNO,
    ENTITY,
    ACCOUNT,
    ACCOUNT_NAME,
    ACCOUNT_NB,
    ACCOUNT_TYPE,
    ACCOUNT_CT,
    ACCOUNT_STATUS,
    DEPT_ID,
    DEPT_NAME,
    ORIG_AMOUNT,
    AMT_INVOICE,
    AMT_ADVANCE,
    AMT_OVERPAYMENT,
    AMT_ARPAYMENT,
    AMT_ARADJUSTMENT,
    AMT_PAID,
    AMT_CM_APPLIED,
    PAYMENT_APPLIED,
    PAYMENT_PAY_APPLIED,
    PAYMENT_WRITE_OFF_APPLIED,
    NET_PAYMENT,
    BALANCE,
    A_0_OR_LESS,
    A_1_TO_30,
    A_31_TO_60,
    A_61_TO_90,
    A_91_TO_120,
    A_121_AND_UP,
    COLLECTOR,
    MARKET,
    DISTRICT_ID,
    DISTRICT_NAME,
    REGION_ID,
    REGION_NAME,
    PAY_TERMS,
    TOTAL_PAST_DUE,
    ESCHEATMENT,
    AS_OF_DATE,
    SUM(
        CASE
            WHEN RECORD_TYPE IN ('arinvoice', 'aradjustment')
                AND POST_DATE >= {% date_end date_filter_earliest %}
                AND POST_DATE <= {% date_end date_filter_latest %}
            THEN ORIG_AMOUNT
            ELSE 0
        END
    ) AS NET_REV
    FROM
       (SELECT
    ARH.RECORDNO                                                          AS HEADER_RECORDNO,
    ARH.CUSTOMERID                                                        AS CUSTOMER_ID,
    CUST.NAME                                                             AS CUSTOMER_NAME,
    CUST_ADDRESS.ADDRESS_LINE_1                                           AS ADDRESS_LINE_1,
    CUST_ADDRESS.ADDRESS_LINE_2                                           AS ADDRESS_LINE_2,
    CUST_ADDRESS.CITY                                                     AS CITY,
    CUST_ADDRESS.STATE                                                    AS STATE,
    CUST_ADDRESS.ZIP                                                      AS ZIP,
    CASE WHEN CUST_ADDRESS.DO_NOT_RENT THEN 'DNR' ELSE NULL END           AS DO_NOT_RENT,
    COALESCE(ARH.WHENPOSTED, ARH.WHENPAID)                                AS POST_DATE,
    CASE
        WHEN ARH.RECORDTYPE = 'aradvance' THEN ARH.DOCNUMBER
        ELSE ARH.RECORDID END                                             AS DOCUMENT,
    ARH.WHENDUE                                                           AS DUE_DATE,
    CASE
        WHEN ARH.WHENDUE IS NULL THEN 0
        ELSE TO_DATE({% date_end date_filter_latest %} ) - ARH.WHENDUE END                      AS AGE,
    ARH.RECORDID                                                          AS RECORD_ID,
    ARH.DOCNUMBER                                                         AS REF_NUMBER,
    ARH.PAYMENTMETHOD                                                     AS PAY_METHOD,
    ARH.RECORDTYPE                                                        AS RECORD_TYPE,
    ARD.RECORDNO                                                          AS DETAIL_RECORDNO,
    ARD.LOCATIONID                                                        AS ENTITY,
    ARD.ACCOUNTNO                                                         AS ACCOUNT,
    GLA.TITLE                                                             AS ACCOUNT_NAME,
    GLA.NORMALBALANCE                                                     AS ACCOUNT_NB,
    GLA.ACCOUNTTYPE                                                       AS ACCOUNT_TYPE,
    GLA.CLOSINGTYPE                                                       AS ACCOUNT_CT,
    GLA.STATUS                                                            AS ACCOUNT_STATUS,
    ARD.DEPARTMENTID                                                      AS DEPT_ID,
    DEPT.TITLE                                                            AS DEPT_NAME,
    COALESCE(ARD.AMOUNT, 0)                                               AS ORIG_AMOUNT,
    CASE WHEN ARH.RECORDTYPE = 'arinvoice' THEN ARD.AMOUNT ELSE 0 END     AS AMT_INVOICE,
    CASE WHEN ARH.RECORDTYPE = 'aradvance' THEN ARD.AMOUNT ELSE 0 END     AS AMT_ADVANCE,
    CASE WHEN ARH.RECORDTYPE = 'aroverpayment' THEN ARD.AMOUNT ELSE 0 END AS AMT_OVERPAYMENT,
    CASE WHEN ARH.RECORDTYPE = 'arpayment' THEN ARD.AMOUNT ELSE 0 END     AS AMT_ARPAYMENT,
    CASE WHEN ARH.RECORDTYPE = 'aradjustment' THEN ARD.AMOUNT ELSE 0 END  AS AMT_ARADJUSTMENT,
    COALESCE(ARP_INV.AMT * -1, 0)                                         AS AMT_PAID,
    COALESCE(ARP_CM.AMT, 0)                                               AS AMT_CM_APPLIED,
    COALESCE(ROUND(ARDET1.AMT, 2), 0) * -1                                AS PAYMENT_APPLIED,
    COALESCE(ROUND(ARDET1.AMT_PAY_APPLIED_PMT, 2), 0) * -1                AS PAYMENT_PAY_APPLIED,
    COALESCE(ROUND(ARDET1.AMT_PAY_APPLIED_WO, 2), 0) * -1                 AS PAYMENT_WRITE_OFF_APPLIED,
    COALESCE(ARP_INV.AMT * -1, 0) + CASE
                                        WHEN ARH.RECORDTYPE = 'aradvance' THEN ARD.AMOUNT
                                        ELSE 0 END                        AS NET_PAYMENT,
    ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED             AS BALANCE,
    CASE WHEN AGE <= 0 THEN BALANCE ELSE 0 END                            AS A_0_OR_LESS,
    CASE WHEN AGE BETWEEN 1 AND 30 THEN BALANCE ELSE 0 END                AS A_1_TO_30,
    CASE WHEN AGE BETWEEN 31 AND 60 THEN BALANCE ELSE 0 END               AS A_31_TO_60,
    CASE WHEN AGE BETWEEN 61 AND 90 THEN BALANCE ELSE 0 END               AS A_61_TO_90,
    CASE WHEN AGE BETWEEN 91 AND 120 THEN BALANCE ELSE 0 END              AS A_91_TO_120,
    CASE WHEN AGE >= 121 THEN BALANCE ELSE 0 END                          AS A_121_AND_UP,
    COALESCE(COLLECTOR.COLLECTOR, '(No Collector Assigned)')              AS COLLECTOR,
    COALESCE(COLLECTOR.MARKET, '(No Market Specified)')                   AS MARKET,
    DIST_REG_INFO.DISTRICT_ID                                             AS DISTRICT_ID,
    DIST_REG_INFO.DISTRICT_NAME                                           AS DISTRICT_NAME,
    DIST_REG_INFO.REGION_ID                                               AS REGION_ID,
    DIST_REG_INFO.REGION_NAME                                             AS REGION_NAME,
    CASE
        WHEN COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') = 'COD' THEN 'Cash on Delivery'
        ELSE COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') END  AS PAY_TERMS,
    CASE WHEN AGE > 0 THEN BALANCE ELSE 0 END                             AS TOTAL_PAST_DUE,
    CASE
        WHEN COUNT(CASE WHEN (ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED) > 0 THEN 1 ELSE NULL END)
                   OVER (PARTITION BY ARH.CUSTOMERID) >= 1 THEN '-'
        ELSE 'Yes' END                                                    AS ESCHEATMENT,
    CAST({% date_end date_filter_latest %}  AS DATE)                                            AS AS_OF_DATE
FROM
    ANALYTICS.INTACCT.ARRECORD ARH
        LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH.CUSTOMERID = CUST.CUSTOMERID
        LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
        LEFT JOIN (SELECT
                       ARP.RECORDKEY,
                       ARP.PAIDITEMKEY,
                       SUM(ARP.TRX_AMOUNT) AS AMT
                   FROM
                       ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter_latest %}
                   GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_INV
                  ON ARH.RECORDNO = ARP_INV.RECORDKEY AND ARD.RECORDNO = ARP_INV.PAIDITEMKEY
        LEFT JOIN (SELECT
                       ARP.PAYMENTKEY,
                       ARP.PAYITEMKEY,
                       SUM(ARP.TRX_AMOUNT) AS AMT
                   FROM
                       ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter_latest %}
                   GROUP BY ARP.PAYMENTKEY, ARP.PAYITEMKEY) ARP_CM
                  ON ARH.RECORDNO = ARP_CM.PAYMENTKEY AND ARD.RECORDNO = ARP_CM.PAYITEMKEY
        LEFT JOIN (SELECT
                       ARD.RECORDNO,
                       ARD.RECORDKEY,
                       SUM(ARIP.AMOUNT)         AS AMT,
                       SUM(CASE
                               WHEN ARR.UNDEPOSITEDACCOUNTNO IN ('5316', '1205') THEN ARIP.AMOUNT
                               ELSE 0 END)      AS AMT_PAY_APPLIED_WO,
                       AMT - AMT_PAY_APPLIED_WO AS AMT_PAY_APPLIED_PMT
                   FROM
                       ANALYTICS.INTACCT.ARDETAIL ARD
                           LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARIP ON ARD.RECORDNO = ARIP.PARENTENTRY
                           LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARR ON ARD.RECORDKEY = ARR.RECORDNO
                   WHERE
                       ARIP.ENTRY_DATE <= {% date_end date_filter_latest %}
                   GROUP BY ALL) AS ARDET1 ON ARH.RECORDNO = ARDET1.RECORDKEY AND ARD.RECORDNO = ARDET1.RECORDNO
        LEFT JOIN(SELECT DISTINCT
                      CCA.COMPANY_ID                                                                   AS CUSTOMER_ID,
                      CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME)                                    AS MARKET,
                      CASE WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL' ELSE CCA.FINAL_COLLECTOR END AS COLLECTOR
                  FROM
                      ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                          LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                    ON CCA.COMPANY_ID = COGL.CUSTOMER_ID AND
                                       COGL.MONTH_RETURNED_FROM_LEGAL IS NULL) COLLECTOR
                 ON TRY_TO_NUMBER(ARH.CUSTOMERID) = COLLECTOR.CUSTOMER_ID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD.DEPARTMENTID = DEPT.DEPARTMENTID
        LEFT JOIN(SELECT
                      CUST.COMPANY_ID AS CUSTOMER_ID,
                      TERMS.NAME      AS ADMIN_TERM
                  FROM
                      ES_WAREHOUSE.PUBLIC.COMPANIES CUST
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS TERMS
                                    ON CUST.NET_TERMS_ID = TERMS.NET_TERMS_ID) ADMIN_TERM
                 ON CUST.CUSTOMERID = TO_CHAR(ADMIN_TERM.CUSTOMER_ID)
        LEFT JOIN(SELECT
                      DIST_REG.MARKET_ID   AS BRANCH_ID,
                      DIST_REG.DISTRICT_ID AS DISTRICT_ID,
                      MIN(DIST.NAME)       AS DISTRICT_NAME,
                      DIST_REG.REGION_ID   AS REGION_ID,
                      MIN(REG.NAME)        AS REGION_NAME
                  FROM
                      (SELECT
                           TO_CHAR(MKT.MARKET_ID) AS MARKET_ID,
                           MIN(MKT.DISTRICT_ID)   AS DISTRICT_ID,
                           MIN(XWALK.REGION)      AS REGION_ID
                       FROM
                           ES_WAREHOUSE.PUBLIC.MARKETS MKT
                               LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK ON MKT.MARKET_ID = XWALK.MARKET_ID
                       WHERE
                             MKT.COMPANY_ID = '1854'
                         AND MKT.ACTIVE = TRUE
                       GROUP BY
                           TO_CHAR(MKT.MARKET_ID)) DIST_REG
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.REGIONS REG ON DIST_REG.REGION_ID = REG.REGION_ID
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.DISTRICTS DIST ON DIST_REG.DISTRICT_ID = DIST.DISTRICT_ID
                  GROUP BY
                      DIST_REG.MARKET_ID,
                      DIST_REG.DISTRICT_ID,
                      DIST_REG.REGION_ID) DIST_REG_INFO ON ARD.DEPARTMENTID = DIST_REG_INFO.BRANCH_ID
        LEFT JOIN(SELECT DISTINCT
                      ADM_CUST.COMPANY_ID  AS CUSTOMER_ID,
                      LOC.STREET_1         AS ADDRESS_LINE_1,
                      LOC.STREET_2         AS ADDRESS_LINE_2,
                      LOC.CITY             AS CITY,
                      ST.ABBREVIATION      AS STATE,
                      LOC.ZIP_CODE         AS ZIP,
                      ADM_CUST.DO_NOT_RENT AS DO_NOT_RENT
                  FROM
                      ES_WAREHOUSE.PUBLIC.COMPANIES ADM_CUST
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS LOC ON ADM_CUST.BILLING_LOCATION_ID = LOC.LOCATION_ID
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES ST ON LOC.STATE_ID = ST.STATE_ID) CUST_ADDRESS
                 ON ARH.CUSTOMERID = TO_CHAR(CUST_ADDRESS.CUSTOMER_ID)
WHERE
      ((ARH.WHENPOSTED <= {% date_end date_filter_latest %}  AND ARH.RECORDTYPE != 'aradvance') OR
       (ARH.WHENPAID <= {% date_end date_filter_latest %}  AND ARH.RECORDTYPE = 'aradvance'))
  AND (ARH.RECORDTYPE NOT IN ('arpayment', 'aroverpayment') OR
       (ARH.RECORDTYPE = 'arpayment' AND ARH.CLRDATE IS NOT NULL AND ARD.LINEITEM = 'T'))
  AND BALANCE != 0

        UNION

        SELECT
    ARH.RECORDNO                                                          AS HEADER_RECORDNO,
    ARH.CUSTOMERID                                                        AS CUSTOMER_ID,
    CUST.NAME                                                             AS CUSTOMER_NAME,
    CUST_ADDRESS.ADDRESS_LINE_1                                           AS ADDRESS_LINE_1,
    CUST_ADDRESS.ADDRESS_LINE_2                                           AS ADDRESS_LINE_2,
    CUST_ADDRESS.CITY                                                     AS CITY,
    CUST_ADDRESS.STATE                                                    AS STATE,
    CUST_ADDRESS.ZIP                                                      AS ZIP,
    CASE WHEN CUST_ADDRESS.DO_NOT_RENT THEN 'DNR' ELSE NULL END           AS DO_NOT_RENT,
    COALESCE(ARH.WHENPOSTED, ARH.WHENPAID)                                AS POST_DATE,
    CASE
        WHEN ARH.RECORDTYPE = 'aradvance' THEN ARH.DOCNUMBER
        ELSE ARH.RECORDID END                                             AS DOCUMENT,
    ARH.WHENDUE                                                           AS DUE_DATE,
    CASE
        WHEN ARH.WHENDUE IS NULL THEN 0
        ELSE TO_DATE({% date_end date_filter_earliest %}) - ARH.WHENDUE END                      AS AGE,
    ARH.RECORDID                                                          AS RECORD_ID,
    ARH.DOCNUMBER                                                         AS REF_NUMBER,
    ARH.PAYMENTMETHOD                                                     AS PAY_METHOD,
    ARH.RECORDTYPE                                                        AS RECORD_TYPE,
    ARD.RECORDNO                                                          AS DETAIL_RECORDNO,
    ARD.LOCATIONID                                                        AS ENTITY,
    ARD.ACCOUNTNO                                                         AS ACCOUNT,
    GLA.TITLE                                                             AS ACCOUNT_NAME,
    GLA.NORMALBALANCE                                                     AS ACCOUNT_NB,
    GLA.ACCOUNTTYPE                                                       AS ACCOUNT_TYPE,
    GLA.CLOSINGTYPE                                                       AS ACCOUNT_CT,
    GLA.STATUS                                                            AS ACCOUNT_STATUS,
    ARD.DEPARTMENTID                                                      AS DEPT_ID,
    DEPT.TITLE                                                            AS DEPT_NAME,
    COALESCE(ARD.AMOUNT, 0)                                               AS ORIG_AMOUNT,
    CASE WHEN ARH.RECORDTYPE = 'arinvoice' THEN ARD.AMOUNT ELSE 0 END     AS AMT_INVOICE,
    CASE WHEN ARH.RECORDTYPE = 'aradvance' THEN ARD.AMOUNT ELSE 0 END     AS AMT_ADVANCE,
    CASE WHEN ARH.RECORDTYPE = 'aroverpayment' THEN ARD.AMOUNT ELSE 0 END AS AMT_OVERPAYMENT,
    CASE WHEN ARH.RECORDTYPE = 'arpayment' THEN ARD.AMOUNT ELSE 0 END     AS AMT_ARPAYMENT,
    CASE WHEN ARH.RECORDTYPE = 'aradjustment' THEN ARD.AMOUNT ELSE 0 END  AS AMT_ARADJUSTMENT,
    COALESCE(ARP_INV.AMT * -1, 0)                                         AS AMT_PAID,
    COALESCE(ARP_CM.AMT, 0)                                               AS AMT_CM_APPLIED,
    COALESCE(ROUND(ARDET1.AMT, 2), 0) * -1                                AS PAYMENT_APPLIED,
    COALESCE(ROUND(ARDET1.AMT_PAY_APPLIED_PMT, 2), 0) * -1                AS PAYMENT_PAY_APPLIED,
    COALESCE(ROUND(ARDET1.AMT_PAY_APPLIED_WO, 2), 0) * -1                 AS PAYMENT_WRITE_OFF_APPLIED,
    COALESCE(ARP_INV.AMT * -1, 0) + CASE
                                        WHEN ARH.RECORDTYPE = 'aradvance' THEN ARD.AMOUNT
                                        ELSE 0 END                        AS NET_PAYMENT,
    ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED             AS BALANCE,
    CASE WHEN AGE <= 0 THEN BALANCE ELSE 0 END                            AS A_0_OR_LESS,
    CASE WHEN AGE BETWEEN 1 AND 30 THEN BALANCE ELSE 0 END                AS A_1_TO_30,
    CASE WHEN AGE BETWEEN 31 AND 60 THEN BALANCE ELSE 0 END               AS A_31_TO_60,
    CASE WHEN AGE BETWEEN 61 AND 90 THEN BALANCE ELSE 0 END               AS A_61_TO_90,
    CASE WHEN AGE BETWEEN 91 AND 120 THEN BALANCE ELSE 0 END              AS A_91_TO_120,
    CASE WHEN AGE >= 121 THEN BALANCE ELSE 0 END                          AS A_121_AND_UP,
    COALESCE(COLLECTOR.COLLECTOR, '(No Collector Assigned)')              AS COLLECTOR,
    COALESCE(COLLECTOR.MARKET, '(No Market Specified)')                   AS MARKET,
    DIST_REG_INFO.DISTRICT_ID                                             AS DISTRICT_ID,
    DIST_REG_INFO.DISTRICT_NAME                                           AS DISTRICT_NAME,
    DIST_REG_INFO.REGION_ID                                               AS REGION_ID,
    DIST_REG_INFO.REGION_NAME                                             AS REGION_NAME,
    CASE
        WHEN COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') = 'COD' THEN 'Cash on Delivery'
        ELSE COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') END  AS PAY_TERMS,
    CASE WHEN AGE > 0 THEN BALANCE ELSE 0 END                             AS TOTAL_PAST_DUE,
    CASE
        WHEN COUNT(CASE WHEN (ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED) > 0 THEN 1 ELSE NULL END)
                   OVER (PARTITION BY ARH.CUSTOMERID) >= 1 THEN '-'
        ELSE 'Yes' END                                                    AS ESCHEATMENT,
    CAST({% date_end date_filter_earliest %} AS DATE)                                            AS AS_OF_DATE
FROM
    ANALYTICS.INTACCT.ARRECORD ARH
        LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH.CUSTOMERID = CUST.CUSTOMERID
        LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
        LEFT JOIN (SELECT
                       ARP.RECORDKEY,
                       ARP.PAIDITEMKEY,
                       SUM(ARP.TRX_AMOUNT) AS AMT
                   FROM
                       ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter_earliest %}
                   GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_INV
                  ON ARH.RECORDNO = ARP_INV.RECORDKEY AND ARD.RECORDNO = ARP_INV.PAIDITEMKEY
        LEFT JOIN (SELECT
                       ARP.PAYMENTKEY,
                       ARP.PAYITEMKEY,
                       SUM(ARP.TRX_AMOUNT) AS AMT
                   FROM
                       ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter_earliest %}
                   GROUP BY ARP.PAYMENTKEY, ARP.PAYITEMKEY) ARP_CM
                  ON ARH.RECORDNO = ARP_CM.PAYMENTKEY AND ARD.RECORDNO = ARP_CM.PAYITEMKEY
        LEFT JOIN (SELECT
                       ARD.RECORDNO,
                       ARD.RECORDKEY,
                       SUM(ARIP.AMOUNT)         AS AMT,
                       SUM(CASE
                               WHEN ARR.UNDEPOSITEDACCOUNTNO IN ('5316', '1205') THEN ARIP.AMOUNT
                               ELSE 0 END)      AS AMT_PAY_APPLIED_WO,
                       AMT - AMT_PAY_APPLIED_WO AS AMT_PAY_APPLIED_PMT
                   FROM
                       ANALYTICS.INTACCT.ARDETAIL ARD
                           LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARIP ON ARD.RECORDNO = ARIP.PARENTENTRY
                           LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARR ON ARD.RECORDKEY = ARR.RECORDNO
                   WHERE
                       ARIP.ENTRY_DATE <= {% date_end date_filter_earliest %}
                   GROUP BY ALL) AS ARDET1 ON ARH.RECORDNO = ARDET1.RECORDKEY AND ARD.RECORDNO = ARDET1.RECORDNO
        LEFT JOIN(SELECT DISTINCT
                      CCA.COMPANY_ID                                                                   AS CUSTOMER_ID,
                      CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME)                                    AS MARKET,
                      CASE WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL' ELSE CCA.FINAL_COLLECTOR END AS COLLECTOR
                  FROM
                      ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                          LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                    ON CCA.COMPANY_ID = COGL.CUSTOMER_ID AND
                                       COGL.MONTH_RETURNED_FROM_LEGAL IS NULL) COLLECTOR
                 ON TRY_TO_NUMBER(ARH.CUSTOMERID) = COLLECTOR.CUSTOMER_ID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD.DEPARTMENTID = DEPT.DEPARTMENTID
        LEFT JOIN(SELECT
                      CUST.COMPANY_ID AS CUSTOMER_ID,
                      TERMS.NAME      AS ADMIN_TERM
                  FROM
                      ES_WAREHOUSE.PUBLIC.COMPANIES CUST
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.NET_TERMS TERMS
                                    ON CUST.NET_TERMS_ID = TERMS.NET_TERMS_ID) ADMIN_TERM
                 ON CUST.CUSTOMERID = TO_CHAR(ADMIN_TERM.CUSTOMER_ID)
        LEFT JOIN(SELECT
                      DIST_REG.MARKET_ID   AS BRANCH_ID,
                      DIST_REG.DISTRICT_ID AS DISTRICT_ID,
                      MIN(DIST.NAME)       AS DISTRICT_NAME,
                      DIST_REG.REGION_ID   AS REGION_ID,
                      MIN(REG.NAME)        AS REGION_NAME
                  FROM
                      (SELECT
                           TO_CHAR(MKT.MARKET_ID) AS MARKET_ID,
                           MIN(MKT.DISTRICT_ID)   AS DISTRICT_ID,
                           MIN(XWALK.REGION)      AS REGION_ID
                       FROM
                           ES_WAREHOUSE.PUBLIC.MARKETS MKT
                               LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XWALK ON MKT.MARKET_ID = XWALK.MARKET_ID
                       WHERE
                             MKT.COMPANY_ID = '1854'
                         AND MKT.ACTIVE = TRUE
                       GROUP BY
                           TO_CHAR(MKT.MARKET_ID)) DIST_REG
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.REGIONS REG ON DIST_REG.REGION_ID = REG.REGION_ID
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.DISTRICTS DIST ON DIST_REG.DISTRICT_ID = DIST.DISTRICT_ID
                  GROUP BY
                      DIST_REG.MARKET_ID,
                      DIST_REG.DISTRICT_ID,
                      DIST_REG.REGION_ID) DIST_REG_INFO ON ARD.DEPARTMENTID = DIST_REG_INFO.BRANCH_ID
        LEFT JOIN(SELECT DISTINCT
                      ADM_CUST.COMPANY_ID  AS CUSTOMER_ID,
                      LOC.STREET_1         AS ADDRESS_LINE_1,
                      LOC.STREET_2         AS ADDRESS_LINE_2,
                      LOC.CITY             AS CITY,
                      ST.ABBREVIATION      AS STATE,
                      LOC.ZIP_CODE         AS ZIP,
                      ADM_CUST.DO_NOT_RENT AS DO_NOT_RENT
                  FROM
                      ES_WAREHOUSE.PUBLIC.COMPANIES ADM_CUST
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS LOC ON ADM_CUST.BILLING_LOCATION_ID = LOC.LOCATION_ID
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES ST ON LOC.STATE_ID = ST.STATE_ID) CUST_ADDRESS
                 ON ARH.CUSTOMERID = TO_CHAR(CUST_ADDRESS.CUSTOMER_ID)
WHERE
      ((ARH.WHENPOSTED <= {% date_end date_filter_earliest %} AND ARH.RECORDTYPE != 'aradvance') OR
       (ARH.WHENPAID <= {% date_end date_filter_earliest %} AND ARH.RECORDTYPE = 'aradvance'))
  AND (ARH.RECORDTYPE NOT IN ('arpayment', 'aroverpayment') OR
       (ARH.RECORDTYPE = 'arpayment' AND ARH.CLRDATE IS NOT NULL AND ARD.LINEITEM = 'T'))
  AND BALANCE != 0 ) AR_AGING
GROUP BY
    HEADER_RECORDNO,
    CUSTOMER_ID,
    CUSTOMER_NAME,
    ADDRESS_LINE_1,
    ADDRESS_LINE_2,
    CITY,
    STATE,
    ZIP,
    DO_NOT_RENT,
    POST_DATE,
    DOCUMENT,
    DUE_DATE,
    AGE,
    RECORD_ID,
    REF_NUMBER,
    PAY_METHOD,
    RECORD_TYPE,
    DETAIL_RECORDNO,
    ENTITY,
    ACCOUNT,
    ACCOUNT_NAME,
    ACCOUNT_NB,
    ACCOUNT_TYPE,
    ACCOUNT_CT,
    ACCOUNT_STATUS,
    DEPT_ID,
    DEPT_NAME,
    ORIG_AMOUNT,
    AMT_INVOICE,
    AMT_ADVANCE,
    AMT_OVERPAYMENT,
    AMT_ARPAYMENT,
    AMT_ARADJUSTMENT,
    AMT_PAID,
    AMT_CM_APPLIED,
    PAYMENT_APPLIED,
    PAYMENT_PAY_APPLIED,
    PAYMENT_WRITE_OFF_APPLIED,
    NET_PAYMENT,
    BALANCE,
    A_0_OR_LESS,
    A_1_TO_30,
    A_31_TO_60,
    A_61_TO_90,
    A_91_TO_120,
    A_121_AND_UP,
    COLLECTOR,
    MARKET,
    DISTRICT_ID,
    DISTRICT_NAME,
    REGION_ID,
    REGION_NAME,
    PAY_TERMS,
    TOTAL_PAST_DUE,
    ESCHEATMENT,
    AS_OF_DATE;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: header_recordno {
    type: number
    sql: ${TABLE}."HEADER_RECORDNO" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
    bypass_suggest_restrictions: yes
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: do_not_rent {
    type: string
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension_group: period {
    type: time
    view_label: "Period"
    timeframes: [
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.POST_DATE ;;
    convert_tz: no
  }

  dimension: document {
    type: string
    sql: ${TABLE}."DOCUMENT" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: record_id {
    type: string
    sql: ${TABLE}."RECORD_ID" ;;
  }

  dimension: ref_number {
    type: string
    sql: ${TABLE}."REF_NUMBER" ;;
  }

  dimension: pay_method {
    type: string
    sql: ${TABLE}."PAY_METHOD" ;;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}."RECORD_TYPE" ;;
  }

  dimension: detail_recordno {
    type: number
    sql: ${TABLE}."DETAIL_RECORDNO" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_nb {
    type: string
    sql: ${TABLE}."ACCOUNT_NB" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: account_ct {
    type: string
    sql: ${TABLE}."ACCOUNT_CT" ;;
  }

  dimension: account_status {
    type: string
    sql: ${TABLE}."ACCOUNT_STATUS" ;;
  }

  dimension: dept_id {
    type: string
    sql: ${TABLE}."DEPT_ID" ;;
  }

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  measure: orig_amount {
    type: sum
    sql: ${TABLE}."ORIG_AMOUNT" ;;
  }

  measure: amt_invoice {
    type: sum
    sql: ${TABLE}."AMT_INVOICE" ;;
  }

  measure: amt_advance {
    type: sum
    sql: ${TABLE}."AMT_ADVANCE" ;;
  }

  measure: amt_overpayment {
    type: sum
    sql: ${TABLE}."AMT_OVERPAYMENT" ;;
  }

  measure: amt_arpayment {
    type: sum
    sql: ${TABLE}."AMT_ARPAYMENT" ;;
  }

  measure: amt_aradjustment {
    type: sum
    sql: ${TABLE}."AMT_ARADJUSTMENT" ;;
  }

  measure: amt_paid {
    type: sum
    sql: ${TABLE}."AMT_PAID" ;;
  }

  measure: amt_cm_applied {
    type: sum
    sql: ${TABLE}."AMT_CM_APPLIED" ;;
  }

  measure: payment_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_APPLIED" ;;
  }

  measure: payment_pay_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_PAY_APPLIED" ;;
  }

  measure: payment_write_off_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_WRITE_OFF_APPLIED" ;;
  }

  measure: net_payment {
    type: sum
    sql: ${TABLE}."NET_PAYMENT" ;;
  }

  measure: balance {
    type: sum
    sql: ${TABLE}."BALANCE" ;;
  }

  measure: a_0_or_less {
    type: sum
    sql: ${TABLE}."A_0_OR_LESS" ;;
  }

  measure: a_1_to_30 {
    type: sum
    sql: ${TABLE}."A_1_TO_30" ;;
  }

  measure: a_31_to_60 {
    type: sum
    sql: ${TABLE}."A_31_TO_60" ;;
  }

  measure: a_61_to_90 {
    type: sum
    sql: ${TABLE}."A_61_TO_90" ;;
  }

  measure: a_91_to_120 {
    type: sum
    sql: ${TABLE}."A_91_TO_120" ;;
  }

  measure: a_121_and_up {
    type: sum
    sql: ${TABLE}."A_121_AND_UP" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
    bypass_suggest_restrictions: yes
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: district_id {
    type: string
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: pay_terms {
    type: string
    sql: ${TABLE}."PAY_TERMS" ;;
  }

  measure: total_past_due {
    type: sum
    sql: ${TABLE}."TOTAL_PAST_DUE" ;;
  }

  dimension: escheatment {
    type: string
    sql: ${TABLE}."ESCHEATMENT" ;;
  }

  dimension: as_of_date {
    type: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }

  measure: net_rev {
    type: sum
    sql: ${TABLE}."NET_REV" ;;
  }


  set: detail {
    fields: [
      header_recordno,
      customer_id,
      customer_name,
      address_line_1,
      address_line_2,
      city,
      state,
      zip,
      do_not_rent,
      post_date,
      period_month,
      period_year,
      period_quarter,
      document,
      due_date,
      age,
      record_id,
      ref_number,
      pay_method,
      record_type,
      detail_recordno,
      entity,
      account,
      account_name,
      account_nb,
      account_type,
      account_ct,
      account_status,
      dept_id,
      dept_name,
      orig_amount,
      amt_invoice,
      amt_advance,
      amt_overpayment,
      amt_arpayment,
      amt_aradjustment,
      amt_paid,
      amt_cm_applied,
      payment_applied,
      payment_pay_applied,
      payment_write_off_applied,
      net_payment,
      balance,
      a_0_or_less,
      a_1_to_30,
      a_31_to_60,
      a_61_to_90,
      a_91_to_120,
      a_121_and_up,
      collector,
      market,
      district_id,
      district_name,
      region_id,
      region_name,
      pay_terms,
      total_past_due,
      escheatment,
      as_of_date,
      net_rev
    ]
  }

  filter: date_filter_earliest {
    type: date
  }

  filter: date_filter_latest {
    type: date
  }

  filter: collector_filter {
    type: string
  }
}
