view: intacct_ar_documents {
  derived_table: {
    sql: SELECT
          ARH.CUSTOMERID                AS CUSTOMER_ID,
          ARH.CUSTOMERNAME              AS CUSTOMER_NAME,
          ARH.WHENCREATED AS DOC_DATE,
          ARH.WHENPOSTED  AS POST_DATE,
          ARH.RECORDID                  AS DOC_NUMBER,
          ARH.RECORDTYPE                AS DOC_TYPE,
          ARD.ACCOUNTNO                 AS GL_ACCOUNT,
          ARD.DEPARTMENTID              AS BRANCH,
          ARD.AMOUNT                    AS AMOUNT
      FROM
          ANALYTICS.INTACCT.ARRECORD ARH
              LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
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

  dimension: doc_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."DOC_DATE" ;;
  }

  dimension: post_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: doc_number {
    type: string
    sql: ${TABLE}."DOC_NUMBER" ;;
  }

  dimension: doc_type {
    type: string
    sql: ${TABLE}."DOC_TYPE" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  set: detail {
    fields: [
      customer_id,
      customer_name,
      doc_date,
      post_date,
      doc_number,
      doc_type,
      gl_account,
      branch,
      amount
    ]
  }

}
