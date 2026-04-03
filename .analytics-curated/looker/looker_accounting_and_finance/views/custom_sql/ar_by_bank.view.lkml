view: ar_by_bank {
  derived_table: {
    sql: SELECT
    ARH.WHENPOSTED           AS POSTED_DATE,
    ARIP.PAYMENTDATE         AS PAYMENT_DATE,
    ARD_ADPY.AMOUNT          AS FULL_INVOICE_AMOUNT,
    ARH_ADPY.FINANCIALENTITY AS BANK_ACCOUNT,
    ARIP.PAYMENTDATE         AS APPLIED_DATE,
    ARH_INV.CUSTOMERID       AS CUSTOMER_ID,
    CUST.NAME                AS CUSTOMER_NAME,
    ARH_INV.RECORDID         AS INVOICE_NUMBER,
    ARH_INV.WHENPOSTED       AS INVOICE_POSTED_DATE,
    ARD_INV.ACCOUNTNO        AS GL_ACCOUNT_NUMBER,
    GLA.TITLE                AS GL_ACCOUNT_NAME,
    ARD_INV.DEPARTMENTID     AS BRANCH_ID,
    DEPT.TITLE               AS BRANCH_NAME,
    ARD_INV.AMOUNT           AS INVOICE_LINE_AMOUNT,
    ARIP.AMOUNT              AS PAID_AMOUNT
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
  AND ARH_ADPY.FINANCIALENTITY IS NOT NULL
ORDER BY
    ARH_INV.RECORDID
                ;;
  }

  ########## DIMENSIONS ##########
  dimension: bank_account  {
    type: string
    sql: ${TABLE}.BANK_ACCOUNT ;;
  }

  dimension: customer_id  {
    type: string
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension:  customer_name {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension: gl_account_number   {
    label: "GL Account Number"
    type: string
    sql: ${TABLE}.GL_ACCOUNT_NUMBER ;;
  }

  dimension: gl_account_name  {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}.GL_ACCOUNT_NAME ;;
  }

  dimension: branch_id  {
    type: string
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: branch_name  {
    type: string
    sql: ${TABLE}.BRANCH_NAME ;;
  }


  ########## DATES ##########
  dimension: payment_date {
    type: date
    sql: ${TABLE}.PAYMENT_DATE ;;
  }

  dimension: applied_date  {
    type: date
    sql: ${TABLE}.APPLIED_DATE ;;
  }

  dimension: invoice_posted_date   {
    type: date
    sql: ${TABLE}.INVOICE_POSTED_DATE ;;
  }



  ########## MEASURES ##########
  measure: full_invoice_amount  {
    type: sum
    value_format: "$#,###.00;($#,###.00);-"
    #drill_fields: [ar_details*]
    sql: ${TABLE}.FULL_INVOICE_AMOUNT ;;
  }

  measure: invoice_line_amount  {
    type: sum
    value_format: "$#,###.00;($#,###.00);-"
    #drill_fields: [ar_details*]
    sql: ${TABLE}.INVOICE_LINE_AMOUNT ;;
  }

  measure: paid_amount   {
    type: sum
    value_format: "$#,###.00;($#,###.00);-"
    #drill_fields: [ar_details*]
    sql: ${TABLE}.PAID_AMOUNT ;;
  }

  ########## DRILL FIELDS ##########
  #set: ar_details {
  #  fields: []
  #}


























  }
