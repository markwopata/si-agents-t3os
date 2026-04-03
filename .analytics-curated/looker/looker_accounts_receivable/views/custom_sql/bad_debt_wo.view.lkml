view: bad_debt_wo {
  derived_table: {
    sql: SELECT ARH.WHENPOSTED                AS WHEN_POSTED,
                     ARIP.PAYMENTDATE              AS PMT_DATE,
                     ARD_ADPY.AMOUNT               AS FULL_WO_AMT,
                     ARH_ADPY.UNDEPOSITEDACCOUNTNO AS UNDEP_FUNDS_ACCT,
                     ARIP.PAYMENTDATE              AS WO_APPLICATION_DATE,
                     GLB.BATCH_DATE                AS WRITE_OFF_DATE,
                     ARH_INV.CUSTOMERID            AS CUSTOMER_ID,
                     CUST.NAME                     AS CUSTOMER_NAME,
                     ARH_INV.RECORDID              AS INV_NUMBER,
                     ARH_INV.WHENPOSTED            AS INV_POSTED,
                     ARD_INV.ACCOUNTNO             AS INV_GL_ACCOUNT,
                     ACCT_CLASS.FN_ALLOCATION      AS FN_ALLOC,
                     GLA.TITLE                     AS ACCOUNT_NAME,
                     ARD_INV.DEPARTMENTID          AS INV_DEPT_ID,
                     DEPT.TITLE                    AS INV_DEPT_NAME,
                     ARD_INV.AMOUNT                AS INV_LINE_AMT,
                     ARIP.AMOUNT                   AS WO_AMOUNT,
                     LI.BRANCH_ID                  AS MARKET_ID
-- AR header record (payment applications - only showing recorttype = aroverpayment)
              FROM ANALYTICS.INTACCT.ARRECORD ARH
-- AR detail pulls in line level information
                       LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
-- Join again to AR Detail (pulls in original advance payment)
                       LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_ADPY ON ARD.PARENTENTRY = ARD_ADPY.RECORDNO
-- Header on the original advance payment (only showing recordtype = aradvance)
                       LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_ADPY
                                 ON ARD_ADPY.RECORDKEY = ARH_ADPY.RECORDNO
-- Bring in GLBATCH for Batch posting date
                       LEFT JOIN ANALYTICS.INTACCT.GLBATCH GLB
                                 ON ARH_ADPY.PRBATCHKEY = GLB.PRBATCHKEY
-- Allows joining payment record to invoice record
                       LEFT JOIN ANALYTICS.INTACCT.ARINVOICEPAYMENT ARIP
                                 ON ARH.RECORDNO = ARIP.PAYMENTKEY AND ARD.RECORDNO = ARIP.PAYITEMKEY
-- Invoice header
                       LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_INV
                                 ON ARIP.RECORDKEY = ARH_INV.RECORDNO
-- Invoice lines
                       LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_INV
                                 ON ARH_INV.RECORDNO = ARD_INV.RECORDKEY AND ARIP.PAIDITEMKEY = ARD_INV.RECORDNO
                       LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH_INV.CUSTOMERID = CUST.CUSTOMERID
                       LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ARD_INV.DEPARTMENTID = DEPT.DEPARTMENTID
                       LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON ARD_INV.ACCOUNTNO = GLA.ACCOUNTNO
                       LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.CECL_AR_ACCT_CLASS ACCT_CLASS
                                 ON ARD_INV.ACCOUNTNO = ACCT_CLASS.GL_ACCOUNT
-- Location information for write off's
                       LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES INV on INV.invoice_no = ARH_INV.RECORDID
                       LEFT JOIN (
                                SELECT INVOICE_ID,BRANCH_ID
                                FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS
                                GROUP BY INVOICE_ID, BRANCH_ID
                                ) LI ON LI.INVOICE_ID = INV.invoice_id
              WHERE ARD.LINEITEM = 'T'
                AND ARH_ADPY.UNDEPOSITEDACCOUNTNO IN ('1205')
        AND {% condition version_filter %} ACCT_CLASS.VERSION {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: when_posted {
    type: date
    sql: ${TABLE}."WHEN_POSTED" ;;
  }

  dimension: pmt_date {
    type: date
    sql: ${TABLE}."PMT_DATE" ;;
  }

  dimension: full_wo_amt {
    type: number
    sql: ${TABLE}."FULL_WO_AMT" ;;
  }

  dimension: undep_funds_acct {
    type: string
    sql: ${TABLE}."UNDEP_FUNDS_ACCT" ;;
  }

  dimension: wo_application_date {
    type: date
    sql: ${TABLE}."WO_APPLICATION_DATE" ;;
  }

  dimension: write_off_date {
    type: date
    sql: ${TABLE}."WRITE_OFF_DATE" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: inv_number {
    type: string
    sql: ${TABLE}."INV_NUMBER" ;;
  }

  dimension: inv_posted {
    type: date
    sql: ${TABLE}."INV_POSTED" ;;
  }

  dimension: inv_gl_account {
    type: string
    sql: ${TABLE}."INV_GL_ACCOUNT" ;;
  }

  dimension: fn_alloc {
    type: string
    sql: ${TABLE}."FN_ALLOC" ;;
  }

  dimension: inv_dept_id {
    type: string
    sql: ${TABLE}."INV_DEPT_ID" ;;
  }

  dimension: inv_dept_name {
    type: string
    sql: ${TABLE}."INV_DEPT_NAME" ;;
  }

  dimension: inv_line_amt {
    type: number
    sql: ${TABLE}."INV_LINE_AMT" ;;
  }

  measure: wo_amount {
    type: sum
    sql: ${TABLE}."WO_AMOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  set: detail {
    fields: [
      when_posted,
      pmt_date,
      full_wo_amt,
      undep_funds_acct,
      wo_application_date,
      write_off_date,
      customer_id,
      customer_name,
      inv_number,
      inv_posted,
      inv_gl_account,
      fn_alloc,
      account_name,
      inv_dept_id,
      inv_dept_name,
      inv_line_amt,
      wo_amount
    ]
  }

  filter: version_filter {
    type: string
  }
}
