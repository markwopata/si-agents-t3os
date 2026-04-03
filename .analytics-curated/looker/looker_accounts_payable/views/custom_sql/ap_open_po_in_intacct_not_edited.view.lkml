view: ap_open_po_in_intacct_not_edited {
  derived_table: {
    sql: SELECT
    RECEIPT.PO_NUMBER,
    RECEIPT.RECEIPT_NUMBER,
    RECEIPT.DATE_RECEIVED,
    TO_NUMBER(ROUND(SUM(RECEIPT.EXT_COST), 2), 15, 2) AS CC_TOTAL,
    ROUND(INT_RECEIPT.EXT_COST, 2)                    AS INT_TOTAL,
    ROUND((INT_TOTAL - CC_TOTAL), 2)                  AS DELTA,
    INT_RECEIPT.STATE                                 AS INT_STATE,
    INT_RECEIPT.MODIFIEDBY                            AS MODIFIED_BY_ID,
    USER.LOGINID                                      AS MODIFIED_BY_LOGIN

FROM
    (SELECT
         TO_CHAR(POH.PURCHASE_ORDER_NUMBER)                                   AS PO_NUMBER,
         CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX, CASE
                                                           WHEN PRH.RECEIVER_TYPE = 'ADJUSTMENT' THEN 'A'
                                                           ELSE '' END)       AS RECEIPT_NUMBER,
         CAST(CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) AS DATE) AS DATE_RECEIVED,
         PRL.ACCEPTED_QUANTITY                                                AS ACCEPT_QTY,
         PRL.REJECTED_QUANTITY                                                AS REJECT_QTY,
         PRL.ACCEPTED_QUANTITY + PRL.REJECTED_QUANTITY                        AS RECEIPT_QTY,
         PRL.PRICE_PER_UNIT                                                   AS UNIT_PRICE,
         (PRL.ACCEPTED_QUANTITY + PRL.REJECTED_QUANTITY) * PRL.PRICE_PER_UNIT AS EXT_COST,
         CONVERT_TIMEZONE('America/Chicago', PRH.DATE_CREATED)                AS RECEIPT_CREATED
     FROM
         PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
             LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
             LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS PRH ON POH.PURCHASE_ORDER_ID = PRH.PURCHASE_ORDER_ID
             LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS PRL
                       ON PRH.PURCHASE_ORDER_RECEIVER_ID = PRL.PURCHASE_ORDER_RECEIVER_ID AND
                          POL.PURCHASE_ORDER_LINE_ITEM_ID = PRL.PURCHASE_ORDER_LINE_ITEM_ID
             LEFT JOIN
             (SELECT
                  PURCHASE_ORDER_RECEIVER_ID,
                  CASE
                      WHEN RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC) > 1 THEN CONCAT('-',
                                                                                                                  (RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC)))
                      ELSE '' END AS "SUFFIX"
              FROM
                  "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS") SFX
             ON PRH.PURCHASE_ORDER_RECEIVER_ID = SFX.PURCHASE_ORDER_RECEIVER_ID
     WHERE
           POH.COMPANY_ID = '1854'
       AND PRH.RECEIVER_TYPE IN ('RECEIPT')
--        AND POH.PURCHASE_ORDER_NUMBER = '741906'
    ) RECEIPT
        LEFT JOIN(SELECT
                      POH.DOCNO                    AS DOCUMENT_NUMBER,
                      POH.STATE,
                      POH.MODIFIEDBY,
                      SUM(POL.UIQTY * POL.UIPRICE) AS EXT_COST
                  FROM
                      ANALYTICS.INTACCT.PODOCUMENT POH
                          LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
                          LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON POL.DEPARTMENTID = DEPT.DEPARTMENTID
                          LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON POH.CUSTVENDID = VEND.VENDORID
                  WHERE
                        POH.DOCPARID = 'Purchase Order'
                    AND POH.T3_PR_CREATED_BY IS NOT NULL
                  GROUP BY
                      POH.DOCNO,
                      POH.STATE,
                      POH.MODIFIEDBY) INT_RECEIPT ON RECEIPT.RECEIPT_NUMBER = INT_RECEIPT.DOCUMENT_NUMBER
        LEFT JOIN ANALYTICS.INTACCT.USERINFO USER ON INT_RECEIPT.MODIFIEDBY = USER.RECORDNO
GROUP BY
    ALL
HAVING
      DELTA != 0
  AND INT_STATE IN ('Pending', 'Partially converted');;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: receipt_number {
    type: string
    sql: ${TABLE}."RECEIPT_NUMBER" ;;
  }

  dimension: date_received {
    type: string
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: cost_capture_total {
    type: number
    sql: ${TABLE}."CC_TOTAL" ;;
  }

  dimension: delta {
    type: number
    sql: ${TABLE}."DELTA" ;;
  }

  dimension: intacct_total {
    type: number
    sql: ${TABLE}."INT_TOTAL" ;;
  }

  dimension: intacct_state {
    type: string
    sql: ${TABLE}."INT_STATE" ;;
  }

  dimension: modified_by_id {
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension: modified_by_login {
    type: string
    sql: ${TABLE}."MODIFIED_BY_LOGIN" ;;
  }

  # dimension: po_number {
  #   type: string
  #   sql: ${TABLE}."PO_NUMBER" ;;
  # }

  # dimension: receipt_number {
  #   type: string
  #   sql: ${TABLE}."RECEIPT_NUMBER" ;;
  # }

  # dimension: date_received {
  #   type: date
  #   sql: ${TABLE}."DATE_RECEIVED" ;;
  # }

  # dimension: month {
  #   type: string
  #   label: "Month"
  #   sql: to_varchar(${TABLE}."PERIOD", 'MMMM YYYY');;
  # }

  # dimension: payed_amount {
  #   type: number
  #   sql: ${TABLE}."ACCEPT_QTY" ;;
  # }

  # dimension: payed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."REJECT_QTY" ;;
  # }

  # dimension: billed_amount {
  #   type: number
  #   sql: ${TABLE}."RECEIPT_QTY" ;;
  # }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."UNIT_PRICE" ;;
  # }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."EXT_COST" ;;
  # }

  # dimension: billed_count_by_gl {
  #   type: number
  #   sql: ${TABLE}."RECEIPT_CREATED" ;;
  # }


  # measure: paid {
  #   label: "Paid Amount"
  #   type: sum
  #   value_format: "#,##0;(#,##0);-"
  #   sql: ${payed_amount} ;;
  # }

  # measure: paid_count_by_gl {
  #   label: "Paid Count by GL"
  #   type: sum
  #   sql: ${payed_count_by_gl} ;;
  # }

  # measure: billed {
  #   label: "Billed Amount"
  #   type: sum
  #   value_format: "#,##0;(#,##0);-"
  #   sql: ${billed_amount} ;;
  # }

  # measure: billed_count {
  #   label: "Billed Count by GL"
  #   type: sum
  #   sql: ${billed_count_by_gl} ;;
  # }

  set: detail {
    fields: [
      po_number,
      receipt_number,
      date_received,
      cost_capture_total,
      intacct_total,
      delta,
      intacct_state,
      modified_by_id,
      modified_by_login
    ]
  }
}
