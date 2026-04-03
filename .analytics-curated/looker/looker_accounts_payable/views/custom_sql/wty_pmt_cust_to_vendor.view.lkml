view: wty_pmt_cust_to_vendor {
    derived_table: {
      sql: SELECT DISTINCT
    ARPAY.COMPANY_ID                                                                                 AS CUSTOMER_ID,
    CUST.NAME                                                                                        AS CUSTOMER_NAME,
    CASE WHEN INTCUST.VENDOR_ID_REF IS NULL THEN 'Customer is missing Vendor reference' ELSE '-' END AS VENDOR_CHECK,
    INTCUST.VENDOR_ID_REF                                                                            AS VENDOR_ID,
    COUNT(ARPAY.PAYMENT_ID)                                                                          AS WTY_PMT_COUNT,
FROM
    ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS UI ON ARPAY.CREATED_BY_USER_ID = UI.USER_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON ARPAY.COMPANY_ID = CUST.COMPANY_ID
        LEFT JOIN ANALYTICS.INTACCT.CUSTOMER INTCUST ON TO_CHAR(ARPAY.COMPANY_ID) = INTCUST.CUSTOMERID
        LEFT JOIN(SELECT DISTINCT
                      INVH1.INVOICE_ID             AS INVOICE_ID,
                      BERPR1.INTACCT_DEPARTMENT_ID AS BRANCH_ID
                  FROM
                      ES_WAREHOUSE.PUBLIC.INVOICES INVH1
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS INVD1 ON INVH1.INVOICE_ID = INVD1.INVOICE_ID
                          LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR1
                                    ON INVD1.BRANCH_ID = BERPR1.BRANCH_ID) TRUEBRANCH
                 ON ADMINV.INVOICE_ID = TRUEBRANCH.INVOICE_ID
        LEFT JOIN(SELECT DISTINCT
                      SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
                  FROM
                      ANALYTICS.INTACCT.APRECORD APR
                  WHERE
                        APR.RECORDTYPE = 'apbill'
                    AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%%')) PMT_ID_SYNCED
                 ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
WHERE
      BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('2303')
  AND ARPAY.STATUS != 1 --PAYMENT NOT REVERSED
  AND PMT_ID_SYNCED.PAYMENT_ID IS NULL
  GROUP BY
    ALL;;
    }

measure: count {type: count drill_fields: [detail*]}

  dimension: customer_id {type: string sql: ${TABLE}."CUSTOMER_ID" ;;}
  dimension: customer_name {type: string sql: ${TABLE}."CUSTOMER_NAME" ;;}
  dimension: vendor_check {type: string sql: ${TABLE}."VENDOR_CHECK" ;;}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  measure: wty_pmt_count {type: sum sql: ${TABLE}."WTY_PMT_COUNT" ;;}

    set: detail {
      fields: [
        customer_id,
        customer_name,
        vendor_check,
        vendor_id,
        wty_pmt_count
      ]
    }
  }
