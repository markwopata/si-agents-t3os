view: historical_cecl_review{
  derived_table: {
    sql: SELECT
    INVOICE.CUSTOMER_ID                                                 AS CUSTOMER_ID,
    INVOICE.CUSTOMER_NAME                                               AS CUSTOMER_NAME,
    INVOICE.DOCUMENT                                                    AS INVOICE_NUMBER,
    INVOICE.DOC_DATE                                                    AS INVOICE_DATE,
    INVOICE.DUE_DATE                                                    AS DUE_DATE,
    INVOICE.AGE                                                         AS AGE,
    ROUND(INVOICE.AMOUNT, 2)                                            AS INVOICE_AMT,
    INVOICE.GL_ACCOUNT                                                  AS GL,
    INVOICE.WHEN_PAID                                                   AS DATE_PAID,
--     INVOICE.RECORD_TYPE AS TYPE,
    WO.WRITE_OFF_DATE                                                   AS DATE_WRITTEN_OFF,
    COALESCE(ROUND(WO.WO_AMOUNT, 2), 0)                                 AS WO_AMT,
    COALESCE(ROUND(END.AMOUNT, 2), 0)                                   AS OPEN_AMOUNT,
    COALESCE(ROUND(INVOICE_AMT - WO_AMT - OPEN_AMOUNT, 2), INVOICE_AMT)         AS AMOUNT_PAID,
    CASE WHEN INVOICE.AGE <= 0 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END                  AS A_0_OR_LESS,
    CASE WHEN INVOICE.AGE BETWEEN 1 AND 30 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END      AS A_1_TO_30,
    CASE WHEN INVOICE.AGE BETWEEN 31 AND 60 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END     AS A_31_TO_60,
    CASE WHEN INVOICE.AGE BETWEEN 61 AND 90 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END     AS A_61_TO_90,
    CASE WHEN INVOICE.AGE BETWEEN 91 AND 120 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END    AS A_91_TO_120,
    CASE WHEN INVOICE.AGE >= 121 THEN ROUND(AMOUNT_PAID, 2) ELSE 0 END                AS A_121_AND_UP,
    COALESCE(CASE
                 WHEN INVOICE.GL_ACCOUNT = '2210' THEN (CASE
                                                            WHEN RENTAL_INVS.RECORDID IS NOT NULL
                                                                THEN 'Sales Tax - Rental'
                                                            ELSE 'Sales Tax - Non Rental' END)
                 ELSE FN_ALLOC.FN_ALLOCATION END, 'N/A')                AS FN_ALLOCATION,
    CASE WHEN IS_LEGAL_CUSTOMER.CUST_ID IS NULL THEN '-' ELSE 'Yes' END AS IN_LEGAL
FROM
    (SELECT
         ARH.CUSTOMERID                            AS CUSTOMER_ID,
         CUST.NAME                                 AS CUSTOMER_NAME,
         ARH.RECORDID                              AS DOCUMENT,
         ARH.WHENCREATED                           AS DOC_DATE,
         ARH.WHENDUE                               AS DUE_DATE,
         CASE
             WHEN ARH.WHENPAID IS NULL THEN (CAST({% date_end as_of_date %} AS DATE) - ARH.WHENDUE)
             ELSE (ARH.WHENPAID - ARH.WHENDUE) END AS AGE,
--          cast({% date_end as_of_date %} as date) - ARH.WHENDUE AS AGE,
         ARH.RECORDTYPE                            AS RECORD_TYPE,
         ARH.WHENPAID                              AS WHEN_PAID,
         ARD.ACCOUNTNO                             AS GL_ACCOUNT,
         SUM(ARD.AMOUNT)                           AS AMOUNT
     FROM
         ANALYTICS.INTACCT.ARRECORD ARH
             LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
             LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH.CUSTOMERID = CUST.CUSTOMERID
     WHERE
           --CAST(ARH.WHENCREATED AS DATE) >= '2021-01-01'
       --AND CAST(ARH.WHENCREATED AS DATE) <= '2021-12-31'
         ARH.RECORDTYPE IN ('arinvoice')
     GROUP BY
         ARH.CUSTOMERID,
         CUST.NAME,
         ARH.RECORDID,
         ARH.WHENCREATED,
         ARH.WHENDUE,
         CASE
             WHEN ARH.WHENPAID IS NULL THEN (CAST({% date_end as_of_date %} AS DATE) - ARH.WHENDUE)
             ELSE (ARH.WHENPAID - ARH.WHENDUE) END,
         ARH.RECORDTYPE,
         ARH.WHENPAID,
         ARD.ACCOUNTNO) INVOICE
        LEFT JOIN(SELECT
                      BD.CUSTOMER_ID,
                      BD.INV_NUMBER,
                      BD.INV_GL_ACCOUNT,
                      MAX(BD.WRITE_OFF_DATE) AS WRITE_OFF_DATE,
                      SUM(BD.WO_AMOUNT)      AS WO_AMOUNT
                  FROM
                      (SELECT
                           ARH.WHENPOSTED                AS WHEN_POSTED,
                           ARIP.PAYMENTDATE              AS PMT_DATE,
                           ARD_ADPY.AMOUNT               AS FULL_WO_AMT,
                           ARH_ADPY.UNDEPOSITEDACCOUNTNO AS UNDEP_FUNDS_ACCT,
                           ARIP.PAYMENTDATE              AS WRITE_OFF_DATE,
                           ARH_INV.CUSTOMERID            AS CUSTOMER_ID,
                           CUST.NAME                     AS CUSTOMER_NAME,
                           ARH_INV.RECORDID              AS INV_NUMBER,
                           ARH_INV.WHENPOSTED            AS INV_POSTED,
                           ARD_INV.ACCOUNTNO             AS INV_GL_ACCOUNT,
                           GLA.TITLE                     AS ACCOUNT_NAME,
                           ARD_INV.DEPARTMENTID          AS INV_DEPT_ID,
                           DEPT.TITLE                    AS INV_DEPT_NAME,
                           ARD_INV.AMOUNT                AS INV_LINE_AMT,
                           ARIP.AMOUNT                   AS WO_AMOUNT
                       FROM
                           ANALYTICS.INTACCT.ARRECORD ARH
                               LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
                               LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_ADPY ON ARD.PARENTENTRY = ARD_ADPY.RECORDNO
                               LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_ADPY
                                         ON ARD_ADPY.RECORDKEY = ARH_ADPY.RECORDNO
                               LEFT JOIN ANALYTICS.INTACCT.ARINVOICEPAYMENT ARIP
                                         ON ARH.RECORDNO = ARIP.PAYMENTKEY AND ARD.RECORDNO = ARIP.PAYITEMKEY
                               LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_INV
                                         ON ARIP.RECORDKEY = ARH_INV.RECORDNO
                               LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_INV
                                         ON ARH_INV.RECORDNO = ARD_INV.RECORDKEY AND ARIP.PAIDITEMKEY = ARD_INV.RECORDNO
                               LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH_INV.CUSTOMERID = CUST.CUSTOMERID
                               LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD_INV.DEPARTMENTID = DEPT.DEPARTMENTID
                               LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD_INV.ACCOUNTNO = GLA.ACCOUNTNO
                       WHERE
                             ARD.LINEITEM = 'T'
                         AND ARH_ADPY.UNDEPOSITEDACCOUNTNO = '1205'
                         AND CAST(ARIP.PAYMENTDATE AS DATE) >= '2021-01-09'
                         AND CAST(ARIP.PAYMENTDATE AS DATE) <= {% date_end as_of_date %}) BD
                  GROUP BY
                      BD.CUSTOMER_ID,
                      BD.INV_NUMBER,
                      BD.INV_GL_ACCOUNT) WO
                 ON INVOICE.CUSTOMER_ID = WO.CUSTOMER_ID AND INVOICE.DOCUMENT = WO.INV_NUMBER AND
                    INVOICE.GL_ACCOUNT = WO.INV_GL_ACCOUNT
        LEFT JOIN(SELECT
                      AR_AGING.CUSTOMER_ID  AS CUSTOMER_ID,
                      AR_AGING.RECORD_ID    AS INV_NUMBER,
                      AR_AGING.ACCOUNT      AS INV_GL_ACCOUNT,
                      SUM(AR_AGING.BALANCE) AS AMOUNT
                  FROM
                      (SELECT
                           ARH.RECORDNO                                              AS HEADER_RECORDNO,
                           ARH.CUSTOMERID                                            AS CUSTOMER_ID,
                           CUST.NAME                                                 AS CUSTOMER_NAME,
                           COALESCE(ARH.WHENPOSTED, ARH.WHENPAID)                    AS POST_DATE,
                           CASE
                               WHEN ARH.RECORDTYPE = 'aradvance' THEN ARH.DOCNUMBER
                               ELSE ARH.RECORDID END                                 AS DOCUMENT,
                           ARH.WHENDUE                                               AS DUE_DATE,
                           CASE
                               WHEN ARH.WHENDUE IS NULL THEN 0
                               ELSE TO_DATE({% date_end as_of_date %}) - ARH.WHENDUE END          AS AGE,
                           ARH.RECORDID                                              AS RECORD_ID,
                           ARH.DOCNUMBER                                             AS REF_NUMBER,
                           ARH.PAYMENTMETHOD                                         AS PAY_METHOD,
                           ARH.RECORDTYPE                                            AS RECORD_TYPE,
                           ARD.RECORDNO                                              AS DETAIL_RECORDNO,
                           ARD.LOCATIONID                                            AS ENTITY,
                           ARD.ACCOUNTNO                                             AS ACCOUNT,
                           CASE
                               WHEN ARD.OFFSETGLACCOUNTNO IS NULL THEN ARD.ACCOUNTNO
                               ELSE ARD.OFFSETGLACCOUNTNO END                        AS OFFSET_ACCOUNT,
                           GLA.TITLE                                                 AS ACCOUNT_NAME,
                           GLA.NORMALBALANCE                                         AS ACCOUNT_NB,
                           GLA.ACCOUNTTYPE                                           AS ACCOUNT_TYPE,
                           GLA.CLOSINGTYPE                                           AS ACCOUNT_CT,
                           GLA.STATUS                                                AS ACCOUNT_STATUS,
                           ARD.DEPARTMENTID                                          AS DEPT_ID,
                           DEPT.TITLE                                                AS DEPT_NAME,
                           COALESCE(ARD.AMOUNT, 0)                                   AS ORIG_AMOUNT,
                           COALESCE(ARP_INV.AMT * -1, 0)                             AS AMT_PAID,
                           COALESCE(ARP_CM.AMT, 0)                                   AS AMT_CM_APPLIED,
                           COALESCE(ROUND(ARDET1.AMT, 2), 0) * -1                    AS PAYMENT_APPLIED,
                           ORIG_AMOUNT + AMT_PAID + AMT_CM_APPLIED + PAYMENT_APPLIED AS BALANCE,
                           CASE WHEN AGE <= 0 THEN BALANCE ELSE 0 END                AS A_0_OR_LESS,
                           CASE WHEN AGE BETWEEN 1 AND 30 THEN BALANCE ELSE 0 END    AS A_1_TO_30,
                           CASE WHEN AGE BETWEEN 31 AND 60 THEN BALANCE ELSE 0 END   AS A_31_TO_60,
                           CASE WHEN AGE BETWEEN 61 AND 90 THEN BALANCE ELSE 0 END   AS A_61_TO_90,
                           CASE WHEN AGE BETWEEN 91 AND 120 THEN BALANCE ELSE 0 END  AS A_91_TO_120,
                           CASE WHEN AGE >= 121 THEN BALANCE ELSE 0 END              AS A_121_AND_UP,
                           COALESCE(COLLECTOR.COLLECTOR, '(No Collector Assigned)')  AS COLLECTOR,
                           COALESCE(COLLECTOR.MARKET, '(No Market Specified)')       AS MARKET
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
                                              ARP.PAYMENTDATE <= {% date_end as_of_date %}
                                          GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_INV
                                         ON ARH.RECORDNO = ARP_INV.RECORDKEY AND ARD.RECORDNO = ARP_INV.PAIDITEMKEY
                               LEFT JOIN (SELECT
                                              ARP.PAYMENTKEY,
                                              ARP.PAYITEMKEY,
                                              SUM(ARP.TRX_AMOUNT) AS AMT
                                          FROM
                                              ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                                          WHERE
                                              ARP.PAYMENTDATE <= {% date_end as_of_date %}
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
                                    ARIP.ENTRY_DATE <= {% date_end as_of_date %}
                                GROUP BY ARD.RECORDKEY) AS ARDET1 ON ARH.RECORDNO = ARDET1.RECORDKEY
                               LEFT JOIN(SELECT DISTINCT
                                             CCA.COMPANY_ID                                AS CUSTOMER_ID,
                                             CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS MARKET,
                                             CASE
                                                 WHEN COGL.CUSTOMER_ID IS NOT NULL THEN 'LEGAL'
                                                 ELSE CCA.FINAL_COLLECTOR END              AS COLLECTOR
                                         FROM
                                             ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
                                                 LEFT JOIN ANALYTICS.GS.COLLECTOR_OIL_GAS_LEGAL COGL
                                                           ON CCA.COMPANY_ID = COGL.CUSTOMER_ID) COLLECTOR
                                        ON TRY_TO_NUMBER(ARH.CUSTOMERID) = COLLECTOR.CUSTOMER_ID
                               LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
                               LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD.DEPARTMENTID = DEPT.DEPARTMENTID
                       WHERE
                             ((ARH.WHENPOSTED <= {% date_end as_of_date %} AND ARH.RECORDTYPE != 'aradvance') OR
                              (ARH.WHENPAID <= {% date_end as_of_date %} AND ARH.RECORDTYPE = 'aradvance'))
                         AND ARH.RECORDTYPE NOT IN ('arpayment', 'aroverpayment')) AR_AGING
                  GROUP BY
                      AR_AGING.CUSTOMER_ID,
                      AR_AGING.RECORD_ID,
                      AR_AGING.ACCOUNT) END
                 ON INVOICE.CUSTOMER_ID = END.CUSTOMER_ID AND INVOICE.DOCUMENT = END.INV_NUMBER AND
                    INVOICE.GL_ACCOUNT = END.INV_GL_ACCOUNT
        LEFT JOIN (SELECT DISTINCT
                       ARH.RECORDID
                   FROM
                       ANALYTICS.INTACCT.ARRECORD ARH
                           LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
                           LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS CECL_ACCT
                                     ON ARD.ACCOUNTNO = CECL_ACCT.GL_ACCOUNT
                   WHERE
                         ARH.RECORDTYPE IN ('arinvoice')
                     AND CECL_ACCT.FN_ALLOCATION = 'Rental'
                     AND {% condition version_filter %} CECL_ACCT.VERSION {% endcondition %}) RENTAL_INVS ON INVOICE.DOCUMENT = RENTAL_INVS.RECORDID
        LEFT JOIN (SELECT
                       GL_ACCOUNT,
                       FN_ALLOCATION
                   FROM
                       ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS
                   WHERE
                    {% condition version_filter %} VERSION {% endcondition %}
                     AND FN_ALLOCATION != 'Sales Tax') FN_ALLOC ON INVOICE.GL_ACCOUNT = FN_ALLOC.GL_ACCOUNT
        LEFT JOIN (SELECT DISTINCT
                       TO_CHAR(CECL_LEGAL.COMPANY_ID) AS CUST_ID
                   FROM
                       ANALYTICS.FINANCIAL_SYSTEMS.CECL_CUST_COLLECT_GRP CECL_LEGAL
                   WHERE
                       CAST(AS_OF_DATE AS DATE) = {% date_end as_of_date %} ) IS_LEGAL_CUSTOMER
                  ON INVOICE.CUSTOMER_ID = IS_LEGAL_CUSTOMER.CUST_ID
ORDER BY
    INVOICE.DOC_DATE,
    INVOICE.CUSTOMER_ID,
    INVOICE.DOCUMENT,
    INVOICE.GL_ACCOUNT
    ;;

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
   type: string
   sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: due_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
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

  measure: invoice_amt {
    type: sum
    sql: ${TABLE}."INVOICE_AMT" ;;
  }

  dimension: gl {
    type: string
    sql: ${TABLE}."GL" ;;
  }

  dimension: date_paid {
    convert_tz: no
    type: date
    sql: ${TABLE}."DATE_PAID" ;;
  }

  dimension: date_written_off {
    convert_tz: no
    type: date
    sql: ${TABLE}."DATE_WRITTEN_OFF" ;;
  }

  measure: wo_amt {
    type: sum
    sql: ${TABLE}."WO_AMT" ;;
  }

  measure: open_amount {
    type: sum
    sql: ${TABLE}."OPEN_AMOUNT" ;;
  }

  measure: amount_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_PAID" ;;
  }

  dimension: fn_allocation {
    type: string
    sql: ${TABLE}."FN_ALLOCATION" ;;
  }

  dimension: in_legal {
    type: string
    sql: ${TABLE}."IN_LEGAL" ;;
  }

  set: detail {
    fields: [
     customer_id,
     customer_name,
     invoice_number,
     invoice_date,
     due_date,
     age,
     a_0_or_less,
     a_1_to_30,
     a_31_to_60,
     a_61_to_90,
     a_91_to_120,
     a_121_and_up,
     invoice_amt,
     gl,
     date_paid,
     date_written_off,
     wo_amt,
     open_amount,
     amount_paid,
     fn_allocation,
     in_legal
    ]
  }
  filter: as_of_date {
    type: date
    }

  filter: version_filter {
    type: string
  }
}
