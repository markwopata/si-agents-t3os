view: rebate_activity {
    derived_table: {
      sql: SELECT
       ARH.CUSTOMERID                            AS CUSTOMER_ID,
       ARH.CUSTOMERNAME                          AS CUSTOMER_NAME,
       ARH.RECORDTYPE                            AS TRANSACTION_TYPE,
       COALESCE(ARH.RECORDID, ARH_INV.RECORDID)  AS DOCUMENT_NUMBER,
       ARH.WHENCREATED                           AS DOCUMENT_DATE,
       COALESCE(ARH.WHENPOSTED, ARH.RECEIPTDATE) AS POST_DATE,
       ARH.AUWHENCREATED                         AS WHEN_CREATED,
       USER.DESCRIPTION                          AS CREATED_BY,
       ARH.TRX_TOTALENTERED                      AS AMOUNT,
       COALESCE(ARIP.AMOUNT, 0)                  AS WO_AMOUNT
FROM
    ANALYTICS.INTACCT.ARRECORD ARH
    LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD ON ARH.RECORDNO = ARD.RECORDKEY
    LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_ADPY ON ARD.PARENTENTRY = ARD_ADPY.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_ADPY ON ARD_ADPY.RECORDKEY = ARH_ADPY.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ARINVOICEPAYMENT ARIP ON ARH.RECORDNO = ARIP.PAYMENTKEY AND ARD.RECORDNO = ARIP.PAYITEMKEY
    LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH_INV ON ARIP.RECORDKEY = ARH_INV.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD_INV ON ARH_INV.RECORDNO = ARD_INV.RECORDKEY AND ARIP.PAIDITEMKEY = ARD_INV.RECORDNO
    LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH_INV.CUSTOMERID = CUST.CUSTOMERID
    LEFT JOIN ANALYTICS.INTACCT.USERINFO USER ON ARH.CREATEDBY = USER.RECORDNO
WHERE
    UPPER(LEFT(ARH.CUSTOMERID, 2)) = 'C-'
ORDER BY
    ARH.CUSTOMERID,
    ARH.RECORDTYPE,
    ARH.AUWHENCREATED;;
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

    dimension: transaction_type {
      type: string
      sql: ${TABLE}."TRANSACTION_TYPE" ;;
    }

    dimension: document_number {
      type: string
      sql: ${TABLE}."DOCUMENT_NUMBER" ;;
    }

    dimension: document_date {
      convert_tz: no
      type: date
      sql: ${TABLE}."DOCUMENT_DATE" ;;
    }

    dimension: post_date {
      convert_tz: no
      type: date
      sql: ${TABLE}."POST_DATE" ;;
    }

    dimension: when_created {
      type: date_time
      sql: ${TABLE}."WHEN_CREATED" ;;
    }

    dimension: created_by {
      type: string
      sql: ${TABLE}."CREATED_BY" ;;
    }

    dimension: amount {
      type: number
      sql: ${TABLE}."AMOUNT" ;;
    }

    dimension: wo_amount {
      type: number
      sql: ${TABLE}."WO_AMOUNT" ;;
  }

    set: detail {
      fields: [
        customer_id,
        customer_name,
        transaction_type,
        document_number,
        document_date,
        post_date,
        when_created,
        created_by,
        amount,
        wo_amount
      ]
    }
  }
