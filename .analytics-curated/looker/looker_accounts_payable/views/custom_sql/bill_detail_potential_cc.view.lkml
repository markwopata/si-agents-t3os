view: bill_detail_potential_cc {
  derived_table: {
    sql: SELECT
    APH.VENDORID                                                                                 AS VENDOR_ID,
    VEND.NAME                                                                                    AS VENDOR_NAME,
    APH.RECORDID                                                                                 AS BILL_NUMBER,
    APH.WHENPOSTED                                                                               AS POST_DATE,
    CASE WHEN APD.ACCOUNTNO = '2014' THEN SUBSTR(APD.ITEMID, 2, 4) ELSE APD.ACCOUNTNO END        AS GL_ACCOUNT_NUMBER,
    GLA.TITLE                                                                                    AS GL_ACCOUNT_NAME,
    APD.DEPARTMENTID                                                                             AS DEPARTMENT_ID,
    DEPT.TITLE                                                                                   AS DEPARTMENT_NAME,
    APD.AMOUNT                                                                                   AS BILL_AMOUNT
FROM
    ANALYTICS.INTACCT.APRECORD APH
        LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.APPAYMETHOD PM ON VEND.PAYMETHODREC = PM.PAYMETHODREC
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON APD.DEPARTMENTID = DEPT.DEPARTMENTID
        LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT AS GLA ON GL_ACCOUNT_NUMBER = GLA.ACCOUNTNO
WHERE
      APH.RECORDTYPE = 'apbill'
  AND APH.WHENPOSTED >= '2023-05-01' and APH.WHENPOSTED <= CURRENT_DATE
  AND GL_ACCOUNT_NUMBER IN ('6305','6306','7003','7007','7106','7401','7405','7406','7407','7408','7430','7604','7607','7609','7900','7904')
;;
  }

  ############ DIMENSIONS ############

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: post_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: gl_account_number {
    label: "GL Account Number"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  dimension: gl_account_name {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  ############ MEASURES ############

  measure: bill_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }






}
