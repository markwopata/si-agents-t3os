view: preferred_vendor {
    derived_table: {
      sql: SELECT
    APH.VENDORID                                                                                 AS VENDOR_ID,
    VEND.NAME                                                                                    AS VENDOR_NAME,
    VEND.TERMNAME                                                                                AS TERMS,
    PM.PAY_METHOD_DESC                                                                           AS PAY_METHOD,
    APH.RECORDID                                                                                 AS BILL_NUMBER,
    APH.WHENCREATED                                                                              AS BILL_DATE,
    APH.WHENPOSTED                                                                               AS POST_DATE,
    APH.WHENDUE                                                                                  AS DUE_DATE,
    CASE WHEN APH.DOCNUMBER = 'nan' THEN NULL ELSE APH.DOCNUMBER END                             AS PO_OR_REFERENCE,
    APH.STATE                                                                                    AS STATE,
    APH.DESCRIPTION                                                                              AS HEADER_DESCRIPTION,
    CASE WHEN LEFT(APH.YOOZ_URL, 23) = 'https://www2.justyoozit' THEN NULL ELSE APH.YOOZ_URL END AS URL,
    APD.LINE_NO                                                                                  AS LINE,
    APD.ACCOUNTNO                                                                                AS ACCOUNT,
    APD.DEPARTMENTID                                                                             AS DEPT_ID,
    APD.LOCATIONID                                                                               AS ENTITY,
    APD.AMOUNT                                                                                   AS AMOUNT,
    APD.ENTRYDESCRIPTION                                                                         AS LINE_DESCRIPTION
FROM
    ANALYTICS.INTACCT.APRECORD APH
        LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.APPAYMETHOD PM ON VEND.PAYMETHODREC = PM.PAYMETHODREC
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON APD.DEPARTMENTID = DEPT.DEPARTMENTID
WHERE
    APH.RECORDTYPE = 'apbill';;

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

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
    }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
    }

  dimension: bill_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
    }

  dimension: post_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."POST_DATE" ;;
    }

  dimension: due_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
    }

  dimension: po_or_reference {
    type: string
    sql: ${TABLE}."PO_OR_REFERENCE" ;;
    }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
    }

  dimension: header_description {
    type: string
    sql: ${TABLE}."HEADER_DESCRIPTION" ;;
    }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
    }

  dimension: line {
    type: string
    sql: ${TABLE}."LINE" ;;
    }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
    }

  dimension: dept_id {
    type: string
    sql: ${TABLE}."DEPT_ID" ;;
    }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
    }

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    }

  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
    }

    set: detail {
      fields: [
        vendor_id,
        vendor_name,
        terms,
        bill_number,
        bill_date,
        post_date,
        due_date,
        po_or_reference,
        state,
        header_description,
        url,
        line,
        account,
        dept_id,
        entity,
        amount,
        line_description
      ]
    }
  }
