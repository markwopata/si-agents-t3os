view: warranty_credits_and_denials_log {
  derived_table: {
    sql: with denials as (
    select wi.invoice_id
        , 'Denial to 5316' as type
        , d.date_denied::DATE as date_created
        , d.denied_amount as amount
        , d.user_id
        , null as line_item_type
        , d.reference as note
    from ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
    JOIN (
        SELECT PAY_APPLY.AMOUNT  AS DENIED_AMOUNT
            , pay_apply.date as date_denied
            , pay_apply.user_id
            , ADMINV.INVOICE_NO
            , ADMINV.INVOICE_ID
            , arpay.reference
        FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP
            ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY
            ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV
            ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
        LEFT JOIN (
            SELECT DISTINCT SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
            FROM ANALYTICS.INTACCT.APRECORD APR
            WHERE APR.RECORDTYPE = 'apbill'
                AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%')
            ) PMT_ID_SYNCED
            ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
        WHERE BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('5316', '1212')
            AND ARPAY.STATUS != 1 --PAYMENT NOT REVERSED
            AND ADMINV.COMPANY_ID NOT IN (
                SELECT COMPANY_ID
                FROM ANALYTICS.PUBLIC.ES_COMPANIES
                )
        ) d
        ON wi.invoice_id = d.invoice_id
)

, credit_memo as (
    SELECT I.INVOICE_ID,
        'Credit Memo' as type,
        ard.WHENCREATED::DATE as created_date,
        ARD.AMOUNT,
        ard.createdby as user_id,
        ard.accounttitle as line_item_type,
        arh.description as note
    FROM ANALYTICS.INTACCT.ARRECORD ARH
    LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD
        ON ARH.RECORDNO = ARD.RECORDKEY
    LEFT JOIN ES_WAREHOUSE.Public.Invoices I
        ON ARH.DOCNUMBER = I.INVOICE_NO
    join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on wi.invoice_id = i.invoice_id
    WHERE ARH.RECORDTYPE = 'aradjustment'
        AND ARD.AMOUNT != 0
        AND i.COMPANY_ID NOT IN (
            SELECT COMPANY_ID
            FROM ANALYTICS.PUBLIC.ES_COMPANIES
            )
)

select cm.*
from credit_memo cm

union

select d.*
from denials d ;;
  }

  dimension: invoice_id{
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id  ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type  ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}.created_date ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.amount ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.user_id ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}.line_item_type ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
  }
  }
