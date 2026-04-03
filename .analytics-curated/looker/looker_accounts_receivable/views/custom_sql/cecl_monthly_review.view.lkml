#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: cecl_monthly_review {
  derived_table: {
    sql: SELECT
          ARH.RECORDNO                                                                      AS HEADER_RECORDNO,
          ARH.CUSTOMERID                                                                    AS CUSTOMER_ID,
          CUST.NAME                                                                         AS CUSTOMER_NAME,
          COALESCE(ARH.WHENPOSTED, ARH.WHENPAID)                                            AS POST_DATE,
          CASE WHEN ARH.RECORDTYPE = 'aradvance' THEN ARH.DOCNUMBER ELSE ARH.RECORDID END   AS DOCUMENT,
          ARH.WHENDUE                                                                       AS DUE_DATE,
          CASE WHEN ARH.WHENDUE IS NULL THEN 0 ELSE TO_DATE({% date_end date_filter %}) - ARH.WHENDUE END AS AGE,
          ARH.RECORDID                                                                      AS RECORD_ID,
          ARH.DOCNUMBER                                                                     AS REF_NUMBER,
          ARH.PAYMENTMETHOD                                                                 AS PAY_METHOD,
          ARH.RECORDTYPE                                                                    AS RECORD_TYPE,
          ARD.RECORDNO                                                                      AS DETAIL_RECORDNO,
          ARD.LOCATIONID                                                                    AS ENTITY,
          ARD.ACCOUNTNO                                                                     AS ACCOUNT,
          GLA.TITLE                                                                         AS ACCOUNT_NAME,
          GLA.NORMALBALANCE                                                                 AS ACCOUNT_NB,
          GLA.ACCOUNTTYPE                                                                   AS ACCOUNT_TYPE,
          GLA.CLOSINGTYPE                                                                   AS ACCOUNT_CT,
          GLA.STATUS                                                                        AS ACCOUNT_STATUS,
          ARD.DEPARTMENTID                                                                  AS DEPT_ID,
          DEPT.TITLE                                                                        AS DEPT_NAME,
          COALESCE(ARD.AMOUNT, 0)                                                           AS ORIG_AMOUNT,
          COALESCE(ARP_INV.AMT * -1, 0)                                                     AS AMT_PAID,
          COALESCE(ARP_CM.AMT, 0)                                                           AS AMT_CM_APPLIED,
          COALESCE(ROUND(ARDET1.AMT, 2), 0) * -1                                            AS PAYMENT_APPLIED,
          ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED                         AS BALANCE,
          CASE WHEN AGE <= 0 THEN BALANCE ELSE 0 END                                        AS A_0_OR_LESS,
          CASE WHEN AGE BETWEEN 1 AND 30 THEN BALANCE ELSE 0 END                            AS A_1_TO_30,
          CASE WHEN AGE BETWEEN 31 AND 60 THEN BALANCE ELSE 0 END                           AS A_31_TO_60,
          CASE WHEN AGE BETWEEN 61 AND 90 THEN BALANCE ELSE 0 END                           AS A_61_TO_90,
          CASE WHEN AGE BETWEEN 91 AND 120 THEN BALANCE ELSE 0 END                          AS A_91_TO_120,
          CASE WHEN AGE BETWEEN 121 AND 180 THEN BALANCE ELSE 0 END                          AS A_121_TO_180,
          CASE WHEN AGE BETWEEN 181 AND 365 THEN BALANCE ELSE 0 END                          AS A_181_TO_365,
          CASE WHEN AGE BETWEEN 366 AND 548 THEN BALANCE ELSE 0 END                          AS A_366_TO_548,
          CASE WHEN AGE BETWEEN 549 AND 730 THEN BALANCE ELSE 0 END                          AS A_549_TO_730,
          CASE WHEN AGE BETWEEN 731 AND 1095 THEN BALANCE ELSE 0 END                         AS A_731_TO_1095,
          CASE WHEN AGE >= 1096 THEN BALANCE ELSE 0 END                                      AS A_1096_AND_UP,
          COALESCE(COLLECTOR.COLLECTOR, '(No Collector Assigned)')                          AS COLLECTOR,
          COALESCE(COLLECTOR.MARKET, '(No Market Specified)')                               AS MARKET,
          CASE
              WHEN COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') = 'COD' THEN 'Cash on Delivery'
              ELSE COALESCE(ADMIN_TERM.ADMIN_TERM, CUST.TERMNAME, '(N/A)') END              AS PAY_TERMS,
          CASE WHEN AGE > 0 THEN BALANCE ELSE 0 END                                         AS TOTAL_PAST_DUE,
          COALESCE(CASE
                       WHEN ARD.ACCOUNTNO = '2210' THEN (CASE
                                                             WHEN SALES_TAX.RECORDNO IS NULL THEN 'Sales Tax - Non Rental'
                                                             ELSE 'Sales Tax - Rental' END)
                       ELSE (FN_ACCT.FN_ALLOCATION) END, 'N/A')                             AS FN_ALLOC,
          COALESCE(CECL_GRP."GROUP", '-')                               AS COLLECT_GROUP,
          MKT_REG_COUNT.CUSTOMER_GEO_TYPE                               CUSTOMER_GEO_TYPE
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
                             ARP.PAYMENTDATE <= {% date_end date_filter %}
                         GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_INV
                        ON ARH.RECORDNO = ARP_INV.RECORDKEY AND ARD.RECORDNO = ARP_INV.PAIDITEMKEY
              LEFT JOIN (SELECT
                             ARP.PAYMENTKEY,
                             ARP.PAYITEMKEY,
                             SUM(ARP.TRX_AMOUNT) AS AMT
                         FROM
                             ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                         WHERE
                             ARP.PAYMENTDATE <= {% date_end date_filter %}
                         GROUP BY ARP.PAYMENTKEY, ARP.PAYITEMKEY) ARP_CM
                        ON ARH.RECORDNO = ARP_CM.PAYMENTKEY AND ARD.RECORDNO = ARP_CM.PAYITEMKEY
              LEFT JOIN
              (SELECT
                   ARD.RECORDKEY,
                   SUM(ARIP.AMOUNT) AS AMT
               FROM
                   ANALYTICS.INTACCT.ARDETAIL ARD
                       LEFT JOIN
                       ANALYTICS.INTACCT.ARDETAIL ARIP ON ARD.RECORDNO = ARIP.PARENTENTRY
               WHERE
                   ARIP.ENTRY_DATE <= {% date_end date_filter %}
               GROUP BY ARD.RECORDKEY) AS ARDET1 ON ARH.RECORDNO = ARDET1.RECORDKEY
              LEFT JOIN(SELECT DISTINCT
                            CCA.COMPANY_ID                                                                   AS CUSTOMER_ID,
                            CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME)                                    AS MARKET,
                            CCA.FINAL_COLLECTOR                                                              AS COLLECTOR
                        FROM
                            ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                                LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                          ON CCA.COMPANY_ID = COGL.CUSTOMER_ID) COLLECTOR
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
              LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.CECL_CUST_COLLECT_GRP CECL_GRP
                        ON ARH.CUSTOMERID = TO_CHAR(CECL_GRP.COMPANY_ID) AND CAST(CECL_GRP.AS_OF_DATE AS DATE) = {% date_end date_filter %}
              LEFT JOIN(SELECT
                            ACCT_CLASS.GL_ACCOUNT,
                            ACCT_CLASS.FN_ALLOCATION
                        FROM
                            ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS ACCT_CLASS
                        WHERE
                              --ACCT_CLASS.VERSION = '1'
                              {% condition version_filter %} ACCT_CLASS.VERSION {% endcondition %}
                          AND ACCT_CLASS.GL_ACCOUNT != '2210') FN_ACCT ON ARD.ACCOUNTNO = FN_ACCT.GL_ACCOUNT
              LEFT JOIN (SELECT DISTINCT
                             ARH2.RECORDNO
                         FROM
                             ANALYTICS.INTACCT.ARRECORD ARH2
                                 LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD2 ON ARH2.RECORDNO = ARD2.RECORDKEY
                                 JOIN (SELECT
                                           ACCT_CLASS.GL_ACCOUNT
                                       FROM
                                           ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS ACCT_CLASS
                                       WHERE
                                             --ACCT_CLASS.VERSION = '1'
                                            {% condition version_filter %} ACCT_CLASS.VERSION {% endcondition %}
                                         AND ACCT_CLASS.FN_ALLOCATION = 'Rental') ARD3 ON ARD2.ACCOUNTNO = ARD3.GL_ACCOUNT
                         WHERE
                             ARH2.RECORDTYPE IN ('arinvoice', 'aradvance', 'aradjustment')) SALES_TAX
                        ON ARH.RECORDNO = SALES_TAX.RECORDNO
              LEFT JOIN (SELECT DISTINCT
    ARH.CUSTOMERID,
    --COUNT(DISTINCT ARD.DEPARTMENTID)     AS MKT_COUNT,
    --COUNT(DISTINCT MKT_REG.REGION_ID)    AS REG_COUNT,
    CASE
        WHEN COUNT(DISTINCT ARD.DEPARTMENTID) = 1 THEN 'Local'
        ELSE CASE
                 WHEN COUNT(DISTINCT ARD.DEPARTMENTID) > 1 AND COUNT(DISTINCT MKT_REG.REGION_ID) = 1 THEN 'Regional'
                 ELSE 'National' END END AS CUSTOMER_GEO_TYPE
FROM
    ANALYTICS.INTACCT.ARRECORD ARH
        LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD
                  ON ARH.RECORDNO = ARD.RECORDKEY
        LEFT JOIN (SELECT
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
                       DIST_REG.REGION_ID) MKT_REG ON MKT_REG.BRANCH_ID = ARD.DEPARTMENTID
WHERE
    ARH.RECORDTYPE IN (
                       'arinvoice', 'aradjustment')
GROUP BY ALL) MKT_REG_COUNT ON ARH.CUSTOMERID = MKT_REG_COUNT.CUSTOMERID
      WHERE
            ((ARH.WHENPOSTED <= {% date_end date_filter %} AND ARH.RECORDTYPE != 'aradvance') OR
             (ARH.WHENPAID <= {% date_end date_filter %} AND ARH.RECORDTYPE = 'aradvance'))
        AND ARH.RECORDTYPE NOT IN ('arpayment', 'aroverpayment')
        AND ROUND(ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED, 2) != 0 ;;
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
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."POST_DATE" ;;
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

  dimension: orig_amount {
    type: number
    sql: ${TABLE}."ORIG_AMOUNT" ;;
  }

  dimension: amt_paid {
    type: number
    sql: ${TABLE}."AMT_PAID" ;;
  }

  dimension: amt_cm_applied {
    type: number
    sql: ${TABLE}."AMT_CM_APPLIED" ;;
  }

  dimension: payment_applied {
    type: number
    sql: ${TABLE}."PAYMENT_APPLIED" ;;
  }

  dimension: balance {
    type: number
    sql: ${TABLE}."BALANCE" ;;
  }

  dimension: a_0_or_less {
    type: number
    sql: ${TABLE}."A_0_OR_LESS" ;;
  }

  dimension: a_1_to_30 {
    type: number
    sql: ${TABLE}."A_1_TO_30" ;;
  }

  dimension: a_31_to_60 {
    type: number
    sql: ${TABLE}."A_31_TO_60" ;;
  }

  dimension: a_61_to_90 {
    type: number
    sql: ${TABLE}."A_61_TO_90" ;;
  }

  dimension: a_91_to_120 {
    type: number
    sql: ${TABLE}."A_91_TO_120" ;;
  }

  dimension: a_121_to_180 {
    type: number
    sql: ${TABLE}."A_121_TO_180" ;;
  }

  dimension: a_181_to_365 {
    type: number
    sql: ${TABLE}."A_181_TO_365" ;;
  }

  dimension: a_366_to_548 {
    type: number
    sql: ${TABLE}."A_366_TO_548" ;;
  }

  dimension: a_549_to_730 {
    type: number
    sql: ${TABLE}."A_549_TO_730" ;;
  }

  dimension: a_731_to_1095 {
    type: number
    sql: ${TABLE}."A_731_TO_1095" ;;
  }


  dimension: a_1096_and_up {
    type: number
    sql: ${TABLE}."A_1096_AND_UP" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: pay_terms {
    type: string
    sql: ${TABLE}."PAY_TERMS" ;;
  }

  dimension: total_past_due {
    type: number
    sql: ${TABLE}."TOTAL_PAST_DUE" ;;
  }

  dimension: fn_alloc {
    type: string
    sql: ${TABLE}."FN_ALLOC" ;;
  }

  dimension: collect_group {
    type: string
    sql: ${TABLE}."COLLECT_GROUP" ;;
  }

  dimension: customer_geo_type {
    type: string
    sql: ${TABLE}."CUSTOMER_GEO_TYPE" ;;
  }

  set: detail {
    fields: [
      header_recordno,
      customer_id,
      customer_name,
      post_date,
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
      amt_paid,
      amt_cm_applied,
      payment_applied,
      balance,
      a_0_or_less,
      a_1_to_30,
      a_31_to_60,
      a_61_to_90,
      a_91_to_120,
      a_121_to_180,
      a_181_to_365,
      a_366_to_548,
      a_549_to_730,
      a_731_to_1095,
      a_1096_and_up,
      collector,
      market,
      pay_terms,
      total_past_due,
      fn_alloc,
      collect_group,
      customer_geo_type
    ]
  }

  filter: date_filter {
    type: date
  }

  filter: version_filter {
    type: string
  }

}
