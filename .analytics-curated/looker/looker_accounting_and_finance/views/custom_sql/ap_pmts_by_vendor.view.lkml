view: ap_pmts_by_vendor {
  derived_table: {
    sql: SELECT
        APR.VENDORID AS VENDOR_ID,
        V.NAME AS VENDOR_NAME,
        V.VENDOR_CATEGORY AS VENDORY_CATEGORY,
        V.TERMNAME AS TERMS,
        APB.PAYMENTDATE AS PAID_DATE,
        APR2.STATE AS PAID_STATE,
        APD.ACCOUNTNO AS GL_ACCTNO,
        GLA.TITLE AS GL_ACCTNAME,
        SUM(APB.AMOUNT) AS PAID_AMOUNT
        FROM ANALYTICS.INTACCT.APBILLPAYMENT AS APB
        LEFT JOIN ANALYTICS.INTACCT.APRECORD AS APR ON APB.RECORDKEY = APR.RECORDNO AND APR.RECORDTYPE IN ('apbill','apadjustment')
        LEFT JOIN ANALYTICS.INTACCT.APDETAIL AS APD ON APB.PAIDITEMKEY = APD.RECORDNO AND APR.RECORDNO = APD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.VENDOR AS V ON APR.VENDORID = V.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT AS GLA ON APD.ACCOUNTNO = GLA.ACCOUNTNO
        LEFT JOIN ANALYTICS.INTACCT.APRECORD AS APR2 ON APB.PAYMENTKEY = APR2.RECORDNO
        WHERE APB.PAYMENTKEY = APB.PARENTPYMT
        AND APR2.RECORDTYPE = 'appayment'
        GROUP BY
        APR.VENDORID,
        V.NAME,
        V.VENDOR_CATEGORY,
        V.TERMNAME,
        APB.PAYMENTDATE,
        APR2.STATE,
        APD.ACCOUNTNO,
        GLA.TITLE
          ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}.VENDOR_CATEGORY ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}.TERMS ;;
  }

  dimension_group: paid_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: paid_state {
    type: string
    sql: ${TABLE}.PAID_STATE ;;
  }

  dimension: gl_acctno {
    type: string
    sql: ${TABLE}.GL_ACCTNO ;;
  }

  dimension: gl_acctname {
    type: string
    sql: ${TABLE}.GL_ACCTNAME ;;
  }

  measure: paid_amount {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [ap_pmt_details*]
    sql: ${TABLE}.PAID_AMOUNT ;;
  }

  measure: count {
    type: count
    value_format: "#,##0"
    drill_fields: [ap_pmt_details*]
  }


  set: ap_pmt_details {fields: [vendor_id, vendor_name, vendor_category, terms, paid_date_date, paid_state, gl_acctno, gl_acctname, paid_amount]}


  }
