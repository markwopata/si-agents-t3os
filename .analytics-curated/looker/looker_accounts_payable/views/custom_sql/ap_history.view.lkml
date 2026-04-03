view: ap_history {
  derived_table: {
    sql: SELECT
          VEND.VENDORID                                                                                                AS VENDOR_ID,
          VEND.NAME                                                                                                    AS VENDOR_NAME,
          VEND.VENDTYPE                                                                                                AS VENDOR_TYPE,
          VEND.VENDOR_CATEGORY                                                                                         AS VENDOR_CATEGORY,
          VEND.TERMNAME                                                                                                AS TERMS,
          CASE
              WHEN VEND.PAYMETHODREC = 1 THEN 'CHECK'
              ELSE CASE
                       WHEN VEND.PAYMETHODREC = 3 THEN 'CREDIT CARD'
                       ELSE CASE
                                WHEN VEND.PAYMETHODREC = 6 THEN 'CASH'
                                ELSE CASE WHEN VEND.PAYMETHODREC = 12 THEN 'ACH' ELSE 'None Specified' END END END END AS PREF_PAY_METHOD,
          VEND.STATUS                                                                                                  AS STATUS,
          CASE WHEN VEND.ONHOLD THEN 'Yes' ELSE 'No' END                                                               AS ON_HOLD,
          COA.ACCOUNTNO                                                                                                AS GL_ACCOUNT,
          COA.TITLE                                                                                                    AS GL_NAME,
          APT.PERIOD                                                                                                   AS PERIOD,
          SUM(CASE WHEN APT.TRANS_TYPE = 'PAYMENT' THEN APT.AMOUNT ELSE 0 END)                                         AS PAYED_AMOUNT,
          SUM(CASE WHEN APT.TRANS_TYPE = 'PAYMENT' THEN APT.COUNT ELSE 0 END)                                          AS PAYED_COUNT_BY_GL,
          SUM(CASE WHEN APT.TRANS_TYPE = 'BILL' THEN APT.AMOUNT ELSE 0 END)                                            AS BILLED_AMOUNT,
          SUM(CASE WHEN APT.TRANS_TYPE = 'BILL_COUNT' THEN APT.COUNT ELSE 0 END)                                       AS BILLED_COUNT_BY_GL
      FROM
          ANALYTICS.INTACCT.VENDOR VEND
              LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT COA
              LEFT JOIN (SELECT
                             APRH.VENDORID                           AS VENDOR_ID,
                             DATE_TRUNC('MONTH', APBPMT.PAYMENTDATE) AS PERIOD,
                             APRD.ACCOUNTNO                          AS ACCOUNT,
                             'PAYMENT'                               AS TRANS_TYPE,
                             COUNT(APBPMT.RECORDNO)                  AS COUNT,
                             SUM(APBPMT.AMOUNT)                      AS AMOUNT
                         FROM
                             ANALYTICS.INTACCT.APBILLPAYMENT APBPMT
                                 LEFT JOIN ANALYTICS.INTACCT.APRECORD APRH
                                           ON APBPMT.RECORDKEY = APRH.RECORDNO AND
                                              APRH.RECORDTYPE IN ('apbill', 'apadjustment')
                                 LEFT JOIN ANALYTICS.INTACCT.APDETAIL APRD
                                           ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
                                 LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APRH.VENDORID = VEND.VENDORID
                                 LEFT JOIN ANALYTICS.INTACCT.APRECORD APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
                         WHERE
                               APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT --WHEN THESE DON'T EQUAL IT IS A CREDIT MEMO APPLICATION I THINK
                           AND APRHPAY.RECORDTYPE = 'appayment'
                         GROUP BY
                             APRH.VENDORID,
                             DATE_TRUNC('MONTH', APBPMT.PAYMENTDATE),
                             APRD.ACCOUNTNO
                         UNION ALL
                         SELECT
                             APBH.VENDORID                        AS VENDOR_ID,
                             DATE_TRUNC('MONTH', APBH.WHENPOSTED) AS PERIOD,
                             APBD.ACCOUNTNO                       AS ACCOUNT,
                             'BILL'                               AS TRANS_TYPE,
                             0                                    AS COUNT,
                             SUM(APBD.AMOUNT)                     AS AMOUNT
                         FROM
                             ANALYTICS.INTACCT.APRECORD APBH
                                 LEFT JOIN ANALYTICS.INTACCT.APDETAIL APBD ON APBH.RECORDNO = APBD.RECORDKEY
                                 LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APBH.VENDORID = VEND.VENDORID
                                 LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON APBD.ACCOUNTNO = GLA.ACCOUNTNO
                         WHERE
                             APBH.RECORDTYPE = 'apbill'
                         GROUP BY
                             APBH.VENDORID,
                             DATE_TRUNC('MONTH', APBH.WHENPOSTED),
                             APBD.ACCOUNTNO
                         UNION ALL
                         SELECT
                             APH2.VENDORID                        AS VENDOR_ID,
                             DATE_TRUNC('MONTH', APH2.WHENPOSTED) AS PERIOD,
                             APD2.ACCOUNTNO                       AS ACCOUNT,
                             'BILL_COUNT'                         AS TRANS_TYPE,
                             COUNT(APH2.RECORDNO)                 AS COUNT,
                             0                                    AS AMOUNT
                         FROM
                             ANALYTICS.INTACCT.APRECORD APH2
                                 LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD2 ON APH2.RECORDNO = APD2.RECORDKEY
                         WHERE
                             APH2.RECORDTYPE = 'apbill'
                         GROUP BY
                             APH2.VENDORID,
                             APD2.ACCOUNTNO,
                             DATE_TRUNC('MONTH', APH2.WHENPOSTED)) APT
                        ON VEND.VENDORID = APT.VENDOR_ID AND COA.ACCOUNTNO = APT.ACCOUNT


      GROUP BY
      VEND.VENDORID,
      VEND.NAME,
      VEND.VENDTYPE,
      VEND.VENDOR_CATEGORY,
      VEND.TERMNAME,
      CASE
      WHEN VEND.PAYMETHODREC = 1 THEN 'CHECK'
      ELSE CASE
      WHEN VEND.PAYMETHODREC = 3 THEN 'CREDIT CARD'
      ELSE CASE
      WHEN VEND.PAYMETHODREC = 6 THEN 'CASH'
      ELSE CASE WHEN VEND.PAYMETHODREC = 12 THEN 'ACH' ELSE 'None Specified' END END END END,
      VEND.STATUS,
      CASE WHEN VEND.ONHOLD THEN 'Yes' ELSE 'No' END,
      COA.ACCOUNTNO,
      COA.TITLE,
      APT.PERIOD
      HAVING
      PERIOD IS NOT NULL
      ORDER BY
      VEND.VENDORID, COA.ACCOUNTNO, APT.PERIOD
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  dimension: pref_pay_method {
    type: string
    sql: ${TABLE}."PREF_PAY_METHOD" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: on_hold {
    type: string
    sql: ${TABLE}."ON_HOLD" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: gl_name {
    type: string
    sql: ${TABLE}."GL_NAME" ;;
  }

  dimension: period {
    type: date
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: month {
    type: string
    label: "Month"
    sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
  }

  dimension: payed_amount {
    type: number
    sql: ${TABLE}."PAYED_AMOUNT" ;;
  }

  dimension: payed_count_by_gl {
    type: number
    sql: ${TABLE}."PAYED_COUNT_BY_GL" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: billed_count_by_gl {
    type: number
    sql: ${TABLE}."BILLED_COUNT_BY_GL" ;;
  }

  measure: paid {
    label: "Paid Amount"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${payed_amount} ;;
  }

  measure: paid_count_by_gl {
    label: "Paid Count by GL"
    type: sum
    sql: ${payed_count_by_gl} ;;
  }

  measure: billed {
    label: "Billed Amount"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${billed_amount} ;;
  }

  measure: billed_count {
    label: "Billed Count by GL"
    type: sum
      sql: ${billed_count_by_gl} ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      terms,
      pref_pay_method,
      status,
      on_hold,
      gl_account,
      gl_name,
      period,
      payed_amount,
      payed_count_by_gl,
      billed_amount,
      billed_count_by_gl
    ]
  }
}
