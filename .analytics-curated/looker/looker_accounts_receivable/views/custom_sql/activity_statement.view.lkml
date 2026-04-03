view: activity_statement {
  derived_table: {
    sql: select
          J.JOURNAL_DATE,
          'Invoice Issued' label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XI.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          I.INVOICE_NUMBER id,
          concat('PO# ',PO.NAME) ref,
          round(abs(sum(JL.GROSS_AMOUNT)),2) amt
      from ANALYTICS.XERO.JOURNAL_LINE JL
      join ANALYTICS.XERO.JOURNAL J
          on JL.JOURNAL_ID = J.JOURNAL_ID
      join ANALYTICS.XERO.INVOICE I
          on J.SOURCE_ID = I.INVOICE_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.INVOICES XI
          on J.SOURCE_ID = XI.XERO_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS
      left join ES_WAREHOUSE.PUBLIC.INVOICES AI
          on I.INVOICE_ID = AI.XERO_ID
      left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS PO
          on AI.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID

      where JL.ACCOUNT_CODE = '1200'
          and J.SOURCE_TYPE = 'ACCREC'
          and I.TYPE = 'ACCREC'

      group by JOURNAL_DATE, SOURCE_TYPE, cust_id, id, ref
      having amt != 0

      union all

      select
          J.JOURNAL_DATE,
          'Payment Received' label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XI.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          XP.PAYMENT_ID::varchar id,
          I.INVOICE_NUMBER ref,
          round(-abs(sum(JL.GROSS_AMOUNT)),2) amt
      from ANALYTICS.XERO.JOURNAL_LINE JL
      join ANALYTICS.XERO.JOURNAL J
          on JL.JOURNAL_ID = J.JOURNAL_ID
      join ANALYTICS.XERO.PAYMENT P
          on J.SOURCE_ID = P.PAYMENT_ID
      join ANALYTICS.XERO.INVOICE I
          on P.INVOICE_ID = I.INVOICE_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.PAYMENTS XP
          on XP.XERO_ID = P.PAYMENT_ID
      left join ES_WAREHOUSE.PUBLIC.INVOICES XI
          on P.INVOICE_ID = XI.XERO_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS

      where JL.ACCOUNT_CODE = '1200'
          and J.SOURCE_TYPE = 'ACCRECPAYMENT'
          and P.STATUS != 'DELETED'
          and I.TYPE = 'ACCREC'

      group by JOURNAL_DATE, SOURCE_TYPE, cust_id, id, ref
      having amt != 0

      union all

      select
          A.DATE journal_date,
          concat(case
              when A.CREDIT_NOTE_ID is not null then 'Credit'
              when A.OVERPAYMENT_ID is not null then 'Overpayment'
              when A.PREPAYMENT_ID is not null then 'Prepayment' end,
              ' Applied') label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XI.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          XCN.CREDIT_NOTE_NUMBER id,
          I.INVOICE_NUMBER ref,
          round(-abs(sum(A.AMOUNT)),2) amt
      from ANALYTICS.XERO.ALLOCATION A
      join ANALYTICS.XERO.INVOICE I
          on A.INVOICE_ID = I.INVOICE_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES XCN
          on coalesce(A.CREDIT_NOTE_ID, A.PREPAYMENT_ID, A.OVERPAYMENT_ID) = XCN.ERP_EXTERNAL_ID
      left join ES_WAREHOUSE.PUBLIC.INVOICES XI
          on A.INVOICE_ID = XI.XERO_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = I.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS

      where I.TYPE = 'ACCREC'

      group by journal_date, label, cust_id, id, ref
      having amt != 0

      union all

      select
          J.JOURNAL_DATE,
          'Credit Issued' label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XCN.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          C.CREDIT_NOTE_NUMBER id,
          J.REFERENCE ref,
          round(-abs(sum(JL.GROSS_AMOUNT)),2) amt
      from ANALYTICS.XERO.JOURNAL_LINE JL
      join ANALYTICS.XERO.JOURNAL J
          on JL.JOURNAL_ID = J.JOURNAL_ID
      join ANALYTICS.XERO.CREDIT_NOTE C
          on J.SOURCE_ID = C.CREDIT_NOTE_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = C.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES XCN
          on J.SOURCE_ID = XCN.ERP_EXTERNAL_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = C.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS

      where JL.ACCOUNT_CODE = '1200'
          and J.SOURCE_TYPE = 'ACCRECCREDIT'
          and C.TYPE = 'ACCRECCREDIT'

      group by JOURNAL_DATE, SOURCE_TYPE, cust_id, id, ref
      having amt != 0

      union all

      select
          J.JOURNAL_DATE,
          'Prepayment Received' label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XCN.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          XCN.CREDIT_NOTE_NUMBER id,
          J.REFERENCE ref,
          round(-abs(sum(JL.GROSS_AMOUNT)),2) amt
      from ANALYTICS.XERO.JOURNAL_LINE JL
      join ANALYTICS.XERO.JOURNAL J
          on JL.JOURNAL_ID = J.JOURNAL_ID
      join ANALYTICS.XERO.PREPAYMENT P
          on J.SOURCE_ID = P.PREPAYMENT_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = P.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES XCN
          on J.SOURCE_ID = XCN.ERP_EXTERNAL_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = P.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS

      where JL.ACCOUNT_CODE = '1200'
          and J.SOURCE_TYPE = 'ARPREPAYMENT'

      group by JOURNAL_DATE, SOURCE_TYPE, cust_id, id, ref
      having amt != 0

      union all

      select
          J.JOURNAL_DATE,
          'Overpayment Received' label,
          coalesce(CUST.ACCOUNT_NUMBER,
                  XC.COMPANY_ID::varchar,
                  XCN.COMPANY_ID::varchar,
                  U.COMPANY_ID::varchar) cust_id,
          XCN.CREDIT_NOTE_NUMBER id,
          J.REFERENCE ref,
          round(-abs(sum(JL.GROSS_AMOUNT)),2) amt
      from ANALYTICS.XERO.JOURNAL_LINE JL
      join ANALYTICS.XERO.JOURNAL J
          on JL.JOURNAL_ID = J.JOURNAL_ID
      join ANALYTICS.XERO.OVERPAYMENT O
          on J.SOURCE_ID = O.OVERPAYMENT_ID
      join ANALYTICS.XERO.CONTACT CUST
          on CUST.CONTACT_ID = O.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES XCN
          on J.SOURCE_ID = XCN.ERP_EXTERNAL_ID
      left join ES_WAREHOUSE.PUBLIC.COMPANIES XC
          on XC.XERO_ID = O.CONTACT_ID
      left join ES_WAREHOUSE.PUBLIC.USERS U
          on CUST.EMAIL_ADDRESS = U.EMAIL_ADDRESS

      where JL.ACCOUNT_CODE = '1200'
          and J.SOURCE_TYPE = 'AROVERPAYMENT'
          and O.STATUS != 'VOIDED'

      group by J.JOURNAL_DATE, SOURCE_TYPE, cust_id, id, ref
      having amt != 0

      union all

      select
          WHENPOSTED::date journal_date,
          'Invoice Issued' label,
          CUSTOMERID cust_id,
          RECORDID id,
          concat('PO# ',PO.NAME) ref,
          round(abs(sum(TOTALENTERED)),2) amt
      from ANALYTICS.SAGE_INTACCT.AR_INVOICE I
      left join ES_WAREHOUSE.PUBLIC.INVOICE_ERP_REFS IR
          on I.RECORDNO = IR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.INVOICES AI
          on IR.INVOICE_ID = AI.INVOICE_ID
      left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS PO
          on AI.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID

      where journal_date > '2021-01-08'

      group by journal_date, label, cust_id, id, ref
      having amt != 0

      union all

      select
          coalesce(IP.WHENCREATED,P.WHENPOSTED)::date journal_date,
          case
              when ARI.RECORDID is not null
                  and P.WHENPOSTED::date = coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Payment Applied'
              when ARI.RECORDID is not null
                  and P.WHENPOSTED::date != coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Payment Received'
              when ARA.RECORDID is not null
                  and P.WHENPOSTED::date = coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Overpayment Applied'
              when ARA.RECORDID is not null
                  and P.WHENPOSTED::date != coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Overpayment Received'
              when P.WHENPOSTED::date = coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Prepayment Applied'
              when P.WHENPOSTED::date != coalesce(IP.WHENCREATED,'2010-01-01')::date
                  then 'Payment Received'
              end label,
          P.CUSTOMERID cust_id,
          coalesce(PR.PAYMENT_ID,PA.PAYMENT_ID)::varchar id,
          coalesce(ARI.RECORDID, ARA.RECORDID,
              iff(P.DOCNUMBER is null or P.DOCNUMBER='',
                  PI.ACCOUNTTITLE,
                  concat(PI.ACCOUNTTITLE,' - ',P.DOCNUMBER))) ref,
          round(-abs(sum(coalesce(PI.AMOUNT,P.TOTALENTERED))),2) amt
      from ANALYTICS.SAGE_INTACCT.AR_PAYMENT P

      left join ES_WAREHOUSE.PUBLIC.PAYMENT_ERP_REFS PR
          on P.RECORDNO = PR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATION_ERP_REFS AR
          on P.RECORDNO = AR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PA
          on AR.PAYMENT_APPLICATION_ID = PA.PAYMENT_APPLICATION_ID
      left join ANALYTICS.SAGE_INTACCT.AR_PAYMENT_ITEM PI
          on P.RECORDNO = PI.RECORDKEY
          and GLOFFSET = -1
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE_PAYMENT IP
          on PI.RECORDNO = IP.PAYITEMKEY
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE ARI
          on IP.RECORDKEY = ARI.RECORDNO
      left join ANALYTICS.SAGE_INTACCT.AR_ADJUSTMENT ARA
          on IP.RECORDKEY = ARA.RECORDNO

      where (journal_date > '2021-01-08' or journal_date is null)

      group by journal_date, label, cust_id, id, ref
      having amt != 0

      union all

      select
          coalesce(IP.WHENCREATED,P.WHENPOSTED)::date journal_date,
          'Overpayment Received' label,
          P.CUSTOMERID cust_id,
          coalesce(PR.PAYMENT_ID,PA.PAYMENT_ID)::varchar id,
          coalesce(ARI.RECORDID, ARA.RECORDID,
              iff(P.DOCNUMBER is null or P.DOCNUMBER='',
                  'Overpayment',
                  concat('Overpayment - ',P.DOCNUMBER))) ref,
          round(-abs(sum(P.TRX_TOTALDUE)),2) amt
      from ANALYTICS.SAGE_INTACCT.AR_PAYMENT P

      left join ES_WAREHOUSE.PUBLIC.PAYMENT_ERP_REFS PR
          on P.RECORDNO = PR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATION_ERP_REFS AR
          on P.RECORDNO = AR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PA
          on AR.PAYMENT_APPLICATION_ID = PA.PAYMENT_APPLICATION_ID
      left join ANALYTICS.SAGE_INTACCT.AR_PAYMENT_ITEM PI
          on P.RECORDNO = PI.RECORDKEY
          and GLOFFSET = -1
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE_PAYMENT IP
          on PI.RECORDNO = IP.PAYITEMKEY
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE ARI
          on IP.RECORDKEY = ARI.RECORDNO
      left join ANALYTICS.SAGE_INTACCT.AR_ADJUSTMENT ARA
          on IP.RECORDKEY = ARA.RECORDNO

      where (journal_date > '2021-01-08' or journal_date is null)

      group by journal_date, label, cust_id, id, ref
      having amt != 0

      union all

      select
          ARA.WHENPOSTED::date journal_date,
          'Credit Issued' label,
          ARA.CUSTOMERID cust_id,
          ARA.RECORDID id,
          CI.INVOICE_NO ref,
          round(-abs(sum(ARA.TOTALENTERED)),2) amt
      from ANALYTICS.SAGE_INTACCT.AR_ADJUSTMENT ARA

      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_ERP_REFS CR
          on ARA.RECORDNO = CR.INTACCT_RECORD_NO
      left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTES CN
          on CR.CREDIT_NOTE_ID = CN.CREDIT_NOTE_ID
      left join ES_WAREHOUSE.PUBLIC.INVOICES CI
          on CN.ORIGINATING_INVOICE_ID = CI.INVOICE_ID
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE_PAYMENT IP
          on ARA.RECORDNO = IP.RECORDKEY
      left join ANALYTICS.SAGE_INTACCT.AR_PAYMENT_ITEM PI
          on IP.PAYITEMKEY = PI.RECORDNO

      where ARA.AUWHENCREATED::date > '2021-01-08'
          and PI.RECORDNO is null

      group by journal_date, label, cust_id, id, ref
      having amt != 0

      union all

      select
          P.WHENMODIFIED::date journal_date,
          'Payment Reversed' label,
          P.CUSTOMERID cust_id,
          null id,
          coalesce(ARI.RECORDID, ARA.RECORDID,
              iff(P.DOCNUMBER is null or P.DOCNUMBER='',
                  PI.ACCOUNTTITLE,
                  concat(PI.ACCOUNTTITLE,' - ',P.DOCNUMBER))) ref,
          round(abs(sum(P.TOTALENTERED)),2) amt
      from ANALYTICS.SAGE_INTACCT.AR_PAYMENT P
      join ANALYTICS.SAGE_INTACCT.AR_PAYMENT_ITEM PI
          on P.RECORDNO = PI.RECORDKEY
          and GLOFFSET = -1
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE_PAYMENT IP
          on PI.RECORDNO = IP.PAYITEMKEY
      left join ANALYTICS.SAGE_INTACCT.AR_INVOICE ARI
          on IP.RECORDKEY = ARI.RECORDNO
      left join ANALYTICS.SAGE_INTACCT.AR_ADJUSTMENT ARA
          on IP.RECORDKEY = ARA.RECORDNO

      where journal_date > '2021-01-08'
          and P.STATE = 'V'

      group by journal_date, label, cust_id, id, ref
      having amt != 0
       ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: journal_date {
    type: date
    sql: ${TABLE}."JOURNAL_DATE" ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}."LABEL" ;;
  }

  dimension: cust_id {
    type: string
    sql: ${TABLE}."CUST_ID" ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension: ref {
    type: string
    sql: ${TABLE}."REF" ;;
  }

  dimension: amt {
    type: number
    sql: ${TABLE}."AMT" ;;
  }

  set: detail {
    fields: []
  }
}
