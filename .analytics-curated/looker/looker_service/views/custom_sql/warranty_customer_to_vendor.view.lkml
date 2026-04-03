view: warranty_customer_to_vendor {
  derived_table: {
    sql: SELECT DISTINCT
          CUST.NAME        AS CUSTOMER_NAME,
          ARPAY.COMPANY_ID AS CUSTOMER_ID,
          NULL             AS VENDOR_ID
      FROM
          ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
              LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS UI ON ARPAY.CREATED_BY_USER_ID = UI.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON ARPAY.COMPANY_ID = CUST.COMPANY_ID
              LEFT JOIN ANALYTICS.INTACCT.CUSTOMER INTCUST ON CUST.COMPANY_ID = INTCUST.CUSTOMERID
      WHERE
              BANK_ERP.INTACCT_UNDEPFUNDSACCT IN (
                                                  '5303', '5304')
        AND   CAST(
                      CONVERT_TIMEZONE(
                              'America/Chicago'
                          , ARPAY.PAYMENT_DATE) AS DATE) >= '2022-01-01'
        AND   LEFT(INTCUST.CUSTOMERID, 2) != 'C-'
        AND   ARPAY.STATUS != 1 --PAYMENT NOT REVERSED
      ORDER BY
          CUST.NAME
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  set: detail {
    fields: [customer_name, customer_id, vendor_id]
  }
}
