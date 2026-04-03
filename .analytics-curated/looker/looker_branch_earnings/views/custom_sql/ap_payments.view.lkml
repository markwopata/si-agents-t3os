view: ap_payments {
 derived_table: {
   sql:
with apbillpayment as (
    SELECT apr.RECORDID    as invoice_no,
           apd.ACCOUNTNO,
           gla.title       as account_name,
           apr.VENDORID,
           v.NAME          as vendor_name,
           apr.WHENPOSTED,
           ENTRY_DATE,
           apb.PAYMENTDATE,
           APU.RECORD_URL  as url_sage,
           sum(apb.AMOUNT) as paid_amount
    FROM ANALYTICS.INTACCT.APBILLPAYMENT apb
             LEFT JOIN ANALYTICS.INTACCT.APRECORD apr ON apb.RECORDKEY = apr.RECORDNO AND apr.RECORDTYPE IN ('apbill', 'apadjustment')
             LEFT JOIN ANALYTICS.INTACCT.APDETAIL apd ON apb.PAIDITEMKEY = apd.RECORDNO AND apr.RECORDNO = apd.RECORDKEY
             LEFT JOIN ANALYTICS.INTACCT.VENDOR v ON apr.VENDORID = v.VENDORID
             LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT gla ON apd.ACCOUNTNO = gla.ACCOUNTNO
             LEFT JOIN ANALYTICS.INTACCT.APRECORD APRHPAY ON apb.PAYMENTKEY = APRHPAY.RECORDNO
             LEFT JOIN ANALYTICS.INTACCT.RECORD_URL APU on APR.RECORDNO = APU.RECORDNO AND APU.INTACCT_OBJECT = 'APBILL'
    GROUP BY invoice_no, apd.accountno, account_name, apr.vendorid, vendor_name, apr.whenposted, entry_date,
             apb.paymentdate, url_sage
),
     invoice as (
         select RECORDID as invoice_no,
                ACCOUNTNO,
                apr.VENDORID,
                sum(AMOUNT) as ttl_invoice_amt

         from ANALYTICS.INTACCT.APDETAIL apd
            left join ANALYTICS.INTACCT.APRECORD apr
                on apd.RECORDKEY = apr.RECORDNO
         group by RECORDID, ACCOUNTNO, apr.VENDORID
     )
select apbp.invoice_no,
       apbp.ACCOUNTNO,
       apbp.account_name,
       apbp.VENDORID,
       apbp.vendor_name,
       apbp.WHENPOSTED,
       apbp.ENTRY_DATE,
       apbp.PAYMENTDATE,
       apbp.url_sage,
       apbp.paid_amount,
       inv.ttl_invoice_amt

from apbillpayment apbp
left join invoice inv
    on apbp.invoice_no = inv.invoice_no
        and apbp.ACCOUNTNO = inv.ACCOUNTNO
          and apbp.VENDORID = inv.VENDORID;;
 }

dimension: invoice_no {
  label: "Invoice Number w/ Link"
  type: string
  sql: ${TABLE}."INVOICE_NO" ;;
  link: {
    label: "Sage Link"
    url: "{{ url_sage }}"
  }
}

dimension: accountno {
  label: "Account Number"
  type: string
  sql: ${TABLE}."ACCOUNTNO" ;;
}

dimension: account_name {
  label: "Account Name"
  type: string
  sql: ${TABLE}."ACCOUNT_NAME" ;;
}

dimension: vendorid {
  label: "Vendor ID"
  type: string
  sql: ${TABLE}."VENDORID" ;;
}

dimension: vendor_name {
  label: "Vendor Name"
  type: string
  sql: ${TABLE}."VENDOR_NAME" ;;
}

dimension: whenposted {
  label: "GL Date"
  convert_tz: no
  type: date
  sql: ${TABLE}."WHENPOSTED" ;;
}

dimension: entry_date {
  label: "Invoice Date"
  convert_tz: no
  type: date
  sql: ${TABLE}."ENTRY_DATE" ;;
}

dimension: paymentdate {
  label: "Paid Date"
  convert_tz: no
  type: date
  sql: ${TABLE}."PAYMENTDATE" ;;
}

dimension: url_sage {
  type: string
  sql: ${TABLE}."URL_SAGE" ;;
  html: {% if ap_payments.url_sage._value != null %}
       <a href = "{{ ap_payments.url_sage._value }}" target="_blank">
         <img src="https://www.sageintacct.com/favicon.ico" width="16" height="16"> Intacct</a>
       &nbsp;
     {% endif %} ;;
}

measure: paid_amount {
  label: "Paid Amount"
  type: sum
  sql: ${TABLE}."PAID_AMOUNT" ;;
}

measure: ttl_invoice_amt {
  label: "Total Invoice Amount"
  type: sum
  sql: ${TABLE}."TTL_INVOICE_AMOUNT" ;;
}

dimension: paid_status {
  label: "Paid Status"
  # type: string
  case: {
    when: {
      sql: ${TABLE}."PAID_AMOUNT" = ${TABLE}."TTL_INVOICE_AMT" ;;
      label: "Fully Paid"
    }
    else: "Remaining Balance"
  }
}

set: detail {
  fields: [
    invoice_no,
    accountno,
    account_name,
    vendorid,
    vendor_name,
    entry_date,
    whenposted,
    paymentdate
  ]
}

}
