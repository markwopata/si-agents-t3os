view: ap_bills_v2 {
  # designed to be a better more optimized way to get ap bill info. Eventually get into a DBT table.
  derived_table: {
    sql: WITH approved_bill_detail AS (
    SELECT  APD.REQUEST_ID,
            APD.POLICY_NAME,
            APD.VENDOR_INVOICE_NUMBER,
            APD.INVOICE_DATE,
            APD.PAYMENT_DUE_DATE,
            APD.INVOICE_RECEIVED_DATE,
            APD.CREATION_DATE,
            APD.SUBMIT_DATE,
            APD.INVOICE_AMOUNT,
            APD.SHIPPING_AMOUNT,
            APD.TAX_AMOUNT,
            (INVOICE_AMOUNT - SHIPPING_AMOUNT - TAX_AMOUNT) AS GOODS_AMOUNT,
            APD.PO_NUMBER,
            APD.JOURNAL_ACCOUNT_CODE,
            CONCAT(APD.EMPLOYEE_FIRST_NAME,' ',APD.EMPLOYEE_LAST_NAME) AS EMPLOYEE_NAME,
            APD.VENDOR_CODE,
            APD.VENDOR_NAME
    FROM ANALYTICS.CONCUR.APPROVED_BILL_DETAIL APD
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
),
intacct_data AS (
    SELECT APR.RECORDNO,
           APR.TRX_TOTALENTERED,
           APR.TRX_TOTALPAID,
           APR.TRX_TOTALDUE,
           APR.ONHOLD,
           APR.WHENPAID,
           APR.STATE,
           APR.CONCUR_IMAGE_ID,
           APR.DESCRIPTION AS SAGE_DESCRIPTION,
           APD.URL_INVOICE AS URL_SAGE,
           APD.URL_CONCUR
    FROM ANALYTICS.INTACCT.APRECORD APR
    LEFT JOIN ANALYTICS.INTACCT_MODELS.AP_DETAIL APD
        ON APR.RECORDNO = APD.FK_AP_HEADER_ID
    WHERE APR.RECORDTYPE = 'apbill'
)
SELECT approved_bill_detail.*,
       intacct_data.TRX_TOTALENTERED,
       intacct_data.TRX_TOTALPAID,
       intacct_data.TRX_TOTALDUE,
       intacct_data.WHENPAID,
       intacct_data.STATE,
       intacct_data.ONHOLD,
       intacct_data.SAGE_DESCRIPTION,
       intacct_data.URL_CONCUR,
       intacct_data.URL_SAGE
FROM approved_bill_detail
LEFT JOIN intacct_data
    ON approved_bill_detail.REQUEST_ID = intacct_data.CONCUR_IMAGE_ID

UNION

SELECT CUI.REQUEST_ID,
       CUI.POLICY,
       CUI.SUPPLIER_INVOICE_NUMBER,
       CUI.INVOICE_DATE,
       CUI.PAYMENT_DUE_DATE,
       CUI.INVOICE_RECEIVED_DATE,
       NULL AS CREATION_DATE,
       NULL AS SUBMIT_DATE,
       CUI.REQUEST_TOTAL,
       NULL AS SHIPPING_AMOUNT,
       NULL AS TAX_AMOUNT,
       CUI.REQUEST_TOTAL AS GOODS_AMOUNT,
       CUI.PURCHASE_ORDER_NUMBER,
       NULL AS JOURNAL_ACCOUNT_CODE,
       NULL AS EMPLOYEE_NAME,
       CUI.SUPPLIER_CODE,
       CUI.SUPPLIER_NAME,
       CUI.REQUEST_TOTAL AS TRX_TOTALENTERED,
       NULL AS TRX_TOTALPAID,
       CUI.REQUEST_TOTAL AS TRX_TOTALDUE,
       NULL AS WHENPAID,
       'Unsubmitted' AS STATE,
       NULL AS ONHOLD,
       NULL AS SAGE_DESCRIPTION,
       CONCAT('https://api.equipmentshare.com/skunkworks/invoices/request-image/',CUI.REQUEST_ID,'?redirect=1') as URL_CONCUR,
       NULL AS URL_SAGE
FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES CUI
where cognos_date = ( --kendall added 3/27/2026
    select max(cognos_date)
    from ANALYTICS.CONCUR.UNSUBMITTED_INVOICES
)
;;
  }


  dimension: request_id {
    type: string
    sql: ${TABLE}.REQUEST_ID ;;
  }

  dimension: policy_name {
    type: string
    sql: ${TABLE}.POLICY_NAME ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.VENDOR_INVOICE_NUMBER ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: payment_due_date {
    type: date
    sql: ${TABLE}.PAYMENT_DUE_DATE ;;
  }

  dimension: invoice_received_date {
    type: date
    sql: ${TABLE}.INVOICE_RECEIVED_DATE ;;
  }

  dimension: creation_date {
    type: date
    sql: ${TABLE}.CREATION_DATE ;;
  }

  dimension: submit_date {
    type: date
    sql: ${TABLE}.SUBMIT_DATE ;;
  }

  dimension: invoice_amount {
    type: number
    sql: ${TABLE}.INVOICE_AMOUNT ;;
  }

  dimension: shipping_amount {
    type: number
    sql: ${TABLE}.SHIPPING_AMOUNT ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}.TAX_AMOUNT ;;
  }

  dimension: goods_amount {
    type: number
    sql: ${TABLE}.GOODS_AMOUNT ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.PO_NUMBER ;;
  }

  dimension: journal_account_code {
    type: string
    sql: ${TABLE}.JOURNAL_ACCOUNT_CODE ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_NAME ;;
  }

  dimension: vendor_code {
    type: string
    sql: ${TABLE}.VENDOR_CODE ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: trx_total_entered {
    type: number
    sql: ${TABLE}.TRX_TOTALENTERED ;;
  }

  dimension: trx_total_paid {
    type: number
    sql: ${TABLE}.TRX_TOTALPAID ;;
  }

  dimension: trx_total_due {
    type: number
    sql: ${TABLE}.TRX_TOTALDUE ;;
  }

  dimension: when_paid {
    type: date
    sql: ${TABLE}.WHENPAID ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: on_hold {
    type: string
    sql: ${TABLE}.ONHOLD ;;
  }

  dimension: sage_url {
    type: string
    sql: ${TABLE}.URL_SAGE ;;
    html: <a href='{{ value }}' target='_blank' style='color: blue;'>{{ value }}</a>
      ;;
  }

  dimension: concur_url {
    type: string
    sql: ${TABLE}.URL_CONCUR ;;
    html: <a href='{{ value }}' target='_blank' style='color: blue;'>{{ value }}</a>
      ;;
  }

  dimension: sage_description {
    type: string
    sql: ${TABLE}.SAGE_DESCRIPTION ;;
  }

}
