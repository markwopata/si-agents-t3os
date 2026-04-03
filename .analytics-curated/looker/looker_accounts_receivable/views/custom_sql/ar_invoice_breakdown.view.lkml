view: ar_invoice_breakdown {
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
    ARD.DEPARTMENTID                                                                  AS DEPT_ID,
    DEPT.TITLE                                                                        AS DEPT_NAME,
    COALESCE(ARD.AMOUNT, 0)                                                           AS ORIG_AMOUNT,
    COALESCE(ARP_CM.AMT * -1, 0)                                                      AS AMT_CM_APPLIED,
    COALESCE(ARP_PA.AMT * -1, 0) - COALESCE(BAD_DEBT.WO_AMOUNT * - 1, 0)              AS AMT_PAY_APPLIED,
    COALESCE(BAD_DEBT.WO_AMOUNT * - 1, 0)                                             AS AMT_WO_APPLIED,
    ORIG_AMOUNT + AMT_CM_APPLIED + AMT_PAY_APPLIED + AMT_WO_APPLIED                   AS BALANCE
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
                           JOIN ANALYTICS.INTACCT.ARRECORD ARCM
                                ON ARP.PAYMENTKEY = ARCM.RECORDNO AND ARCM.RECORDTYPE = 'aradjustment'
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter %}
                   GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_CM
                  ON ARH.RECORDNO = ARP_CM.RECORDKEY AND ARD.RECORDNO = ARP_CM.PAIDITEMKEY
        LEFT JOIN (SELECT
                       ARP.RECORDKEY,
                       ARP.PAIDITEMKEY,
                       SUM(ARP.TRX_AMOUNT) AS AMT
                   FROM
                       ANALYTICS.INTACCT.ARINVOICEPAYMENT ARP
                           JOIN ANALYTICS.INTACCT.ARRECORD ARCM
                                ON ARP.PAYMENTKEY = ARCM.RECORDNO AND ARCM.RECORDTYPE = 'aroverpayment'
                   WHERE
                       ARP.PAYMENTDATE <= {% date_end date_filter %}
                   GROUP BY ARP.RECORDKEY, ARP.PAIDITEMKEY) ARP_PA
                  ON ARH.RECORDNO = ARP_PA.RECORDKEY AND ARD.RECORDNO = ARP_PA.PAIDITEMKEY
        LEFT JOIN(SELECT
                      ARH_INV.RECORDNO AS INV_HEAD_RECORDNO,
                      ARD_INV.RECORDNO AS INV_LINE_RECORDNO,
                      SUM(ARIP.AMOUNT) AS WO_AMOUNT
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
                    AND ARH_ADPY.UNDEPOSITEDACCOUNTNO IN ('1205', '5316')
                    AND ARH.WHENPOSTED <= {% date_end date_filter %}
                  GROUP BY ALL) BAD_DEBT
                 ON ARH.RECORDNO = BAD_DEBT.INV_HEAD_RECORDNO AND ARD.RECORDNO = BAD_DEBT.INV_LINE_RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD.DEPARTMENTID = DEPT.DEPARTMENTID
WHERE
      ((ARH.WHENPOSTED <= {% date_end date_filter %} AND ARH.RECORDTYPE != 'aradvance') OR
       (ARH.WHENPAID <= {% date_end date_filter %} AND ARH.RECORDTYPE = 'aradvance'))
  AND ARH.RECORDTYPE IN ('arinvoice')
  AND LEFT(ARH.CUSTOMERID,2) != 'C-'
       ;;

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: header_recordno {type: number sql: ${TABLE}."HEADER_RECORDNO" ;;}
  dimension: customer_id {type: string sql: ${TABLE}."CUSTOMER_ID" ;;}
  dimension: customer_name {type: string sql: ${TABLE}."CUSTOMER_NAME" ;;}
  dimension_group: post_date {
    type: time
    view_label: "Period"
    timeframes: [
      month,
      year
      ]
      sql: ${TABLE}.POST_DATE;;
      convert_tz: no}
  dimension: document {type: string sql: ${TABLE}."DOCUMENT" ;;}
  dimension: due_date {convert_tz: no type: date sql: ${TABLE}."DUE_DATE" ;;}
  dimension: age {type: number sql: ${TABLE}."AGE" ;;}
  dimension: record_id {type: string sql: ${TABLE}."RECORD_ID" ;;}
  dimension: ref_number {type: string sql: ${TABLE}."REF_NUMBER" ;;}
  dimension: pay_method {type: string sql: ${TABLE}."PAY_METHOD" ;;}
  dimension: record_type {type: string sql: ${TABLE}."RECORD_TYPE" ;;}
  dimension: detail_recordno {type: number sql: ${TABLE}."DETAIL_RECORDNO" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  dimension: account {type: string sql: ${TABLE}."ACCOUNT" ;;}
  dimension: account_name {type: string sql: ${TABLE}."ACCOUNT_NAME" ;;}
  dimension: dept_id {type: string sql: ${TABLE}."DEPT_ID" ;;}
  dimension: dept_name {type: string sql: ${TABLE}."DEPT_NAME" ;;}
  measure: orig_amount {type: sum sql: ${TABLE}."ORIG_AMOUNT" ;;}
  measure: amt_cm_applied {type: sum sql: ${TABLE}."AMT_CM_APPLIED" ;;}
  measure: amt_pay_applied {type: sum sql: ${TABLE}."AMT_PAY_APPLIED" ;;}
  measure: amt_wo_applied {type: sum sql: ${TABLE}."AMT_WO_APPLIED" ;;}
  measure: balance {type: sum sql: ${TABLE}."BALANCE" ;;}

  set: detail {
    fields: [
      header_recordno,
      customer_id,
      customer_name,
      post_date_month,
      post_date_year,
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
      dept_id,
      dept_name,
      orig_amount,
      amt_cm_applied,
      amt_pay_applied,
      amt_wo_applied,
      balance
    ]
  }

  filter: date_filter {
    type: date
  }

}
