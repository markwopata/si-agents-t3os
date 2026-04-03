view: reversed_warranty_payments {
  derived_table: {
    sql: SELECT ARPAY.PAYMENT_ID                                                     AS PAYMENT_ID,
       CONCAT('https://admin.equipmentshare.com/#/home/payments/', ARPAY.PAYMENT_ID) AS ADMIN_URL,
       CAST(ARPAY.PAYMENT_DATE AS DATE)                                              AS PAYMENT_DATE,
       ARPAY.COMPANY_ID                                                              AS CUSTOMER_ID,
       CUST.NAME                                                                     AS CUSTOMER_NAME,
       INTCUST.VENDOR_ID_REF                                                         AS VENDOR_ID,
       CAST(ARPAY.DATE_CREATED AS DATE)                                              AS PAYMENT_CREATED_DATE,
       ARPAY.AMOUNT                                                                  AS AMOUNT,
       CONCAT(PUI.FIRST_NAME, ' ', PUI.LAST_NAME)                                    AS PAYMENT_CREATED_BY_USER,
       ARPAY.REFERENCE                                                               AS REFERENCE,
       CAST(PH.DATE AS DATE)                                                         AS REVERSAL_DATE,
       PH.DESCRIPTION                                                                AS REVERSAL_DETAILS,
       CONCAT(RUI.FIRST_NAME, ' ', RUI.LAST_NAME)                                    AS REVERSED_BY_USER,
       CASE WHEN AP.RECORDID IS NULL THEN 'Not in Intacct' ELSE AP.RECORDID END      AS INTACCT_BILL_NUMBER,
       URL.RECORD_URL                                                                AS INTACCT_URL,
       AP.DOCNUMBER                                                                  AS INTACCT_REFERENCE,
       COUNT(DISTINCT AP.RECORDID) OVER (PARTITION BY AP.DOCNUMBER)                  AS CNT_INT_RECORDS,
       AP.STATE                                                                      AS INTACCT_STATE
FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
         LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP
                   ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
--     TYPE = 1; RECEIVED
--     TYPE = 2; ???
--     TYPE = 3; REVERSAL
--     TYPE = 4; PAYMENT APPLICATION
--     TYPE = 5; REVERSED APPLICATION
         LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_HISTORY PH ON ARPAY.PAYMENT_ID = PH.PAYMENT_ID AND PH.TYPE = 3
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES CUST ON ARPAY.COMPANY_ID = CUST.COMPANY_ID
         LEFT JOIN ANALYTICS.INTACCT.CUSTOMER INTCUST ON TO_CHAR(ARPAY.COMPANY_ID) = INTCUST.CUSTOMERID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS PUI ON ARPAY.CREATED_BY_USER_ID = PUI.USER_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS RUI ON PH.USER_ID = RUI.USER_ID
         LEFT JOIN ANALYTICS.INTACCT.APRECORD AP
                   ON CONCAT('WTY_PMT_ID:', ARPAY.PAYMENT_ID) = AP.DOCNUMBER AND AP.RECORDTYPE = 'apbill'
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL URL ON AP.RECORDNO = URL.RECORDNO AND URL.INTACCT_OBJECT = 'APBILL'
WHERE 1 = 1
  AND ARPAY.STATUS = 1
  AND BANK_ERP.INTACCT_UNDEPFUNDSACCT = 2303
ORDER BY REVERSAL_DATE DESC
       ;;
  }

  dimension: payment_id {
    type: number
    label: "Payment ID"
    sql: ${TABLE}."PAYMENT_ID" ;;
    html: <a href='https://admin.equipmentshare.com/#/home/payments/{{ payment_id._value }}'
      target='_blank'
      style='color: blue;'
      >{{ payment_id._value | escape }}</a> ;;
  }


   dimension: payment_date {
     type: date
     label: "Payment Date"
     sql: ${TABLE}."PAYMENT_DATE" ;;
   }

   dimension: customer_id {
     type: number
     label: "Customer ID"
     sql: ${TABLE}."CUSTOMER_ID" ;;
   }

   dimension: customer_name {
     type: string
     label: "Customer Name"
     sql: ${TABLE}."CUSTOMER_NAME" ;;
   }

   dimension: vendor_id {
     type: string
     label: "Vendor ID"
     sql: ${TABLE}."VENDOR_ID" ;;
   }

   dimension: payment_created_date {
     type: date
     label: "Payment Created Date"
     sql: ${TABLE}."PAYMENT_CREATED_DATE" ;;
   }

   dimension: amount {
     type: number
     label: "Amount"
     sql: ${TABLE}."AMOUNT" ;;
   }

   dimension: payment_created_by_user {
     type: string
     label: "Payment Created By User"
     sql: ${TABLE}."PAYMENT_CREATED_BY_USER" ;;
   }

   dimension: reference {
     type: string
     label: "Reference"
     sql: ${TABLE}."REFERENCE" ;;
   }

   dimension: reversal_date {
     type: date
     label: "Reversal Date"
     sql: ${TABLE}."REVERSAL_DATE" ;;
   }

   dimension: reversal_details {
     type: string
     label: "Reversal Details"
     sql: ${TABLE}."REVERSAL_DETAILS" ;;
   }

   dimension: reversed_by_user {
     type: string
     label: "Reversed By User"
     sql: ${TABLE}."REVERSED_BY_USER" ;;
   }

  dimension: intacct_url {
    type: string
    label: "Intacct URL"
    sql: ${TABLE}."INTACCT_URL" ;;
  }

  dimension: intacct_bill_number {
    type: string
    label: "Intacct Bill Number"
    sql: ${TABLE}."INTACCT_BILL_NUMBER" ;;
    html: <a href='{{ intacct_url._value }}'
      target='_blank'
      style='color: blue;'
      >{{ intacct_bill_number._value | escape }}</a> ;;
  }


   dimension: intacct_reference {
     type: string
     label: "Intacct Reference"
     sql: ${TABLE}."INTACCT_REFERENCE" ;;
   }

   dimension: cnt_int_records {
     type: number
     label: "Count Int Records"
     sql: ${TABLE}."CNT_INT_RECORDS" ;;
   }

   dimension: intacct_state {
     type: string
     label: "Intacct State"
     sql: ${TABLE}."INTACCT_STATE" ;;
   }

   set: payment_details {
     fields: [
       payment_id,
       payment_date,
       customer_id,
       customer_name,
       vendor_id,
       payment_created_date,
       amount,
       payment_created_by_user,
       reference,
       reversal_date,
       reversal_details,
       reversed_by_user,
      intacct_url,
       intacct_bill_number,
       intacct_reference,
       cnt_int_records,
       intacct_state
     ]
   }
  }
