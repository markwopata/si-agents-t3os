view: ap_bill_by_method {
  derived_table: {
    sql: --VERSION 02
      SELECT
          APB.VENDORID AS "VENDOR_ID",
          APB.VENDORNAME AS "VENDOR_NAME",
          CASE WHEN APB.SYSTEMGENERATED ='T'
              THEN 'Manual'
              ELSE
                  CASE WHEN APB.DESCRIPTION_2 != ''
                      THEN
                          CASE WHEN APB.YOOZ_DOCID != 0
                              THEN 'Purchase Conversion by Yooz'
                              ELSE 'Purchase Conversion by Intacct'
                              END
                      ELSE
                          CASE WHEN APB.YOOZ_DOCID != 0
                              THEN 'Yooz AP Bill'
                              ELSE 'Direct AP Bill'
                              END
                      END
              END AS "Processing_Method",
          APB.RECORDNO AS "Count",
          CAST(APB.WHENCREATED AS DATE) AS "Bill_Date",
          CAST(APB.WHENPOSTED AS DATE) AS "GL_Posting_Date",
          SUM(APB.TRX_TOTALENTERED) AS "Amount"
      FROM "ANALYTICS"."SAGE_INTACCT"."AP_BILL" APB
      GROUP BY
          APB.VENDORID,
          APB.VENDORNAME,
          APB.RECORDNO,
          CAST(APB.WHENCREATED AS DATE),
          CAST(APB.WHENPOSTED AS DATE),
          CASE WHEN APB.SYSTEMGENERATED ='T'
              THEN 'Manual'
              ELSE
                  CASE WHEN APB.DESCRIPTION_2 != ''
                      THEN
                          CASE WHEN APB.YOOZ_DOCID != 0
                              THEN 'Purchase Conversion by Yooz'
                              ELSE 'Purchase Conversion by Intacct'
                              END
                      ELSE
                          CASE WHEN APB.YOOZ_DOCID != 0
                              THEN 'Yooz AP Bill'
                              ELSE 'Direct AP Bill'
                              END
                      END
              END
       ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: processing_method {
    type: string
    sql: ${TABLE}."Processing_Method" ;;
  }

  dimension: recordno {
    type: string
    sql: ${TABLE}."Count" ;;
  }

  measure: count {
    type: count
  }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension: gl_posting_date {
    type: date
    sql: ${TABLE}."GL_Posting_Date" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      processing_method,
      count,
      bill_date,
      gl_posting_date,
      amount
    ]
  }
}
