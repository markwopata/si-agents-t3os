view: sales_cogs_report {
  derived_table: {
    sql:
select
    LI.ASSET_ID,
    LI.DESCRIPTION sales_inv_descr,
    LI.AMOUNT sales_price,
    I.OWED_AMOUNT,
    I.INVOICE_NO sales_doc,
    CONCAT(U.FIRST_NAME,' ',U.LAST_NAME) AS "APPROVER",
    CONCAT(U2.FIRST_NAME, ' ',U.LAST_NAME) AS "SUBMITTER",
    I.PUBLIC_NOTE curr_note,
    NH.public_note prev_note,
    LIE.INTACCT_GL_ACCOUNT_NO rev_acct,
    LI.BRANCH_ID location,
    C.NAME cust_name,
    O.NAME owner_name,
    --I.BILLING_APPROVED_DATE::date sales_doc_date,
    CAST(CONVERT_TIMEZONE('America/Chicago',I.BILLING_APPROVED_DATE::DATETIME) AS DATE) AS sales_doc_date,
    coalesce(A.VIN, A.SERIAL_NUMBER) admin_sn,
    coalesce(APH.PURCHASE_PRICE, APH.OEC) admin_oec,
    APH.INVOICE_NUMBER admin_vendor_inv_no,
    FT.SERIAL fleet_track_sn,
    FT.NET_PRICE + coalesce(FT.FREIGHT_COST,0) fleet_track_oec,
    FT.INVOICE_NUMBER fleet_track_vendor_inv_no,
    iff(APH.ASSET_ID is null,null,coalesce(TV6.FINANCING_FACILITY_TYPE,'Not financed')) fin_type
from ES_WAREHOUSE.PUBLIC.LINE_ITEMS LI
join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPE_ERP_REFS LIE
    on LI.LINE_ITEM_TYPE_ID = LIE.LINE_ITEM_TYPE_ID
join ES_WAREHOUSE.PUBLIC.INVOICES I
    on LI.INVOICE_ID = I.INVOICE_ID
left join (
            select
                PARAMETERS:invoice_id invoice_id,
                replace(PARAMETERS:changes:public_note, '\\n', ' ') public_note
            from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT CA
            join ES_WAREHOUSE.PUBLIC.INVOICES I
                on CA.PARAMETERS:invoice_id = I.INVOICE_ID
                and CA.DATE_CREATED >= I.BILLING_APPROVED_DATE
            where COMMAND = 'UpdateInvoice'
                and PARAMETERS like '%public_note%'
            qualify rank() over (partition by invoice_id order by CA.DATE_CREATED desc) = 1
    ) NH
    on I.INVOICE_ID = NH.invoice_id
left join ES_WAREHOUSE.PUBLIC.COMPANIES C
    on I.COMPANY_ID = C.COMPANY_ID
left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY SCD
    on LI.ASSET_ID = SCD.ASSET_ID
    and I.BILLING_APPROVED_DATE::date-2 between SCD.DATE_START and SCD.DATE_END
left join ES_WAREHOUSE.PUBLIC.COMPANIES O
    on SCD.COMPANY_ID = O.COMPANY_ID
left join ES_WAREHOUSE.PUBLIC.ASSETS A
    on LI.ASSET_ID = A.ASSET_ID
left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
    on LI.ASSET_ID = APH.ASSET_ID
left join ANALYTICS.DEBT.PHOENIX_ID_TYPES PIT
    on APH.FINANCIAL_SCHEDULE_ID = PIT.FINANCIAL_SCHEDULE_ID
left join "ES_WAREHOUSE"."PUBLIC"."USERS" U
  on U.USER_ID = I.BILLING_APPROVED_BY_USER_ID
left join "ES_WAREHOUSE"."PUBLIC"."USERS" U2
  on U2.USER_ID = I.CREATED_BY_USER_ID
left join ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT TV6
    on PIT.PHOENIX_ID = TV6.PHOENIX_ID
    and CURRENT_VERSION = 'Yes'
    and GAAP_NON_GAAP = 'GAAP'
    and CUSTOMTYPE = 'Loan'
left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS FT
    on LI.ASSET_ID = FT.ASSET_ID
    and ORDER_STATUS = 'Received'
where LI.LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120)

union

select
    LI.ASSET_ID,
    LI.DESCRIPTION sales_inv_descr,
    -CNLI.CREDIT_AMOUNT sales_price,
    I.OWED_AMOUNT,
    concat(CN.CREDIT_NOTE_NUMBER,' from Inv# ', I.INVOICE_NO) sales_doc,
    CONCAT(U.FIRST_NAME,' ',U.LAST_NAME) AS "APPROVER",
    CONCAT(U2.FIRST_NAME, ' ',U.LAST_NAME) AS "SUBMITTER",
    CN.MEMO curr_note,
    null prev_note,
    LIE.INTACCT_GL_ACCOUNT_NO rev_acct,
    LI.BRANCH_ID location,
    C.NAME cust_name,
    O.NAME owner_name,
    --CN.DATE_CREATED::date sales_doc_date,
    CAST(CONVERT_TIMEZONE('America/Chicago',CN.DATE_CREATED::DATETIME) AS DATE) AS sales_doc_date,
    coalesce(A.VIN, A.SERIAL_NUMBER) admin_sn,
    coalesce(APH.PURCHASE_PRICE, APH.OEC) admin_oec,
    APH.INVOICE_NUMBER admin_vendor_inv_no,
    FT.SERIAL fleet_track_sn,
    FT.NET_PRICE + coalesce(FT.FREIGHT_COST,0) fleet_track_oec,
    FT.INVOICE_NUMBER fleet_track_vendor_inv_no,
    iff(APH.ASSET_ID is null,null,coalesce(TV6.FINANCING_FACILITY_TYPE,'Not financed')) fin_type
from ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS CNLI
join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPE_ERP_REFS LIE
    on CNLI.LINE_ITEM_TYPE_ID = LIE.LINE_ITEM_TYPE_ID
join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES CN
    on CNLI.CREDIT_NOTE_ID = CN.CREDIT_NOTE_ID
left join ES_WAREHOUSE.PUBLIC.INVOICES I
    on CN.ORIGINATING_INVOICE_ID = I.INVOICE_ID
left join ES_WAREHOUSE.PUBLIC.COMPANIES C
    on I.COMPANY_ID = C.COMPANY_ID
left join ES_WAREHOUSE.PUBLIC.LINE_ITEMS LI
    on CNLI.LINE_ITEM_ID = LI.LINE_ITEM_ID
left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY SCD
    on LI.ASSET_ID = SCD.ASSET_ID
    and I.BILLING_APPROVED_DATE::date-2 between SCD.DATE_START and SCD.DATE_END
left join ES_WAREHOUSE.PUBLIC.COMPANIES O
    on SCD.COMPANY_ID = O.COMPANY_ID
left join ES_WAREHOUSE.PUBLIC.ASSETS A
    on LI.ASSET_ID = A.ASSET_ID
left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
    on LI.ASSET_ID = APH.ASSET_ID
left join ANALYTICS.DEBT.PHOENIX_ID_TYPES PIT
    on APH.FINANCIAL_SCHEDULE_ID = PIT.FINANCIAL_SCHEDULE_ID
left join "ES_WAREHOUSE"."PUBLIC"."USERS" U
  on U.USER_ID = I.BILLING_APPROVED_BY_USER_ID
left join "ES_WAREHOUSE"."PUBLIC"."USERS" U2
  on U2.USER_ID = I.CREATED_BY_USER_ID
left join ANALYTICS.DEBT.TV6_XML_DEBT_TABLE_CURRENT TV6
    on PIT.PHOENIX_ID = TV6.PHOENIX_ID
    and CURRENT_VERSION = 'Yes'
    and GAAP_NON_GAAP = 'GAAP'
    and CUSTOMTYPE = 'Loan'
left join ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS FT
    on LI.ASSET_ID = FT.ASSET_ID
where LI.LINE_ITEM_TYPE_ID in (24, 50, 80, 81, 110, 111, 118, 120)
       ;;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: sales_inv_descr {
    type: string
    sql: ${TABLE}."SALES_INV_DESCR" ;;
  }

  dimension: sales_price {
    type: number
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."SALES_PRICE" ;;
  }

  dimension: owed_amount {
    type: number
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: sales_doc {
    type: string
    sql: ${TABLE}."SALES_DOC" ;;
  }

  dimension: approver {
    type: string
    sql: ${TABLE}."APPROVER" ;;
  }

  dimension: submitter {
    type: string
    sql: ${TABLE}."APPROVER" ;;
  }

  dimension: current_memo {
    type: string
    sql: ${TABLE}."CURR_NOTE" ;;
  }

  dimension: previous_memo {
    type: string
    sql: ${TABLE}."PREV_NOTE" ;;
  }

  dimension: rev_acct {
    type: string
    sql: ${TABLE}."REV_ACCT" ;;
  }

  dimension: location {
    type: number
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: cust_name {
    type: string
    sql: ${TABLE}."CUST_NAME" ;;
  }

  dimension: owner_name {
    type: string
    sql: ${TABLE}."OWNER_NAME" ;;
  }

  dimension: sales_doc_date {
    type: date
    sql: ${TABLE}."SALES_DOC_DATE" ;;
  }

  dimension: admin_sn {
    type: string
    sql: ${TABLE}."ADMIN_SN" ;;
  }

  dimension: admin_oec {
    type: number
    sql: ${TABLE}."ADMIN_OEC" ;;
  }

  dimension: admin_vendor_inv_no {
    type: string
    sql: ${TABLE}."ADMIN_VENDOR_INV_NO" ;;
  }

  dimension: fleet_track_sn {
    type: string
    sql: ${TABLE}."FLEET_TRACK_SN" ;;
  }

  dimension: fleet_track_oec {
    type: number
    sql: ${TABLE}."FLEET_TRACK_OEC" ;;
  }

  dimension: fleet_track_vendor_inv_no {
    type: string
    sql: ${TABLE}."FLEET_TRACK_VENDOR_INV_NO" ;;
  }

  dimension: fin_type {
    type: string
    sql: ${TABLE}."FIN_TYPE" ;;
  }


}
