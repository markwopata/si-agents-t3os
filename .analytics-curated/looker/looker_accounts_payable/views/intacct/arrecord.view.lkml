view: arrecord {
  sql_table_name: "INTACCT"."ARRECORD" ;;



  measure: reimbursement_amount_invoiced {
    type: sum
    drill_fields: [detail*]
    sql: ${TABLE}."TRX_TOTALENTERED" ;;
  }
  # dimension: trx_totalentered {
  #   type: string
  #   sql: ${TABLE}."TRX_TOTALENTERED" ;;
  # }
  dimension: customer_starts_with_c {
    type: yesno
    sql: CASE WHEN UPPER(LEFT(${customerid}, 2)) = 'C-' THEN 'yes' ELSE 'no' END ;;
    hidden: yes
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: auwhencreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."AUWHENCREATED" AS TIMESTAMP_NTZ) ;;
  }
  # dimension: whencreated_string {
  #   type: string
  #   sql: ${TABLE}."AUWHENCREATED" ;;
  # }
  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
  }
  dimension: batchtitle {
    type: string
    sql: ${TABLE}."BATCHTITLE" ;;
  }
  dimension: billbacktemplatekey {
    type: number
    sql: ${TABLE}."BILLBACKTEMPLATEKEY" ;;
  }
  dimension: billto_cellphone {
    type: string
    sql: ${TABLE}."BILLTO_CELLPHONE" ;;
  }
  dimension: billto_companyname {
    type: string
    sql: ${TABLE}."BILLTO_COMPANYNAME" ;;
  }
  dimension: billto_contactname {
    type: string
    sql: ${TABLE}."BILLTO_CONTACTNAME" ;;
  }
  dimension: billto_email1 {
    type: string
    sql: ${TABLE}."BILLTO_EMAIL1" ;;
  }
  dimension: billto_email2 {
    type: string
    sql: ${TABLE}."BILLTO_EMAIL2" ;;
  }
  dimension: billto_fax {
    type: string
    sql: ${TABLE}."BILLTO_FAX" ;;
  }
  dimension: billto_firstname {
    type: string
    sql: ${TABLE}."BILLTO_FIRSTNAME" ;;
  }
  dimension: billto_initial {
    type: string
    sql: ${TABLE}."BILLTO_INITIAL" ;;
  }
  dimension: billto_lastname {
    type: string
    sql: ${TABLE}."BILLTO_LASTNAME" ;;
  }
  dimension: billto_mailaddress_address1 {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ADDRESS1" ;;
  }
  dimension: billto_mailaddress_address2 {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ADDRESS2" ;;
  }
  dimension: billto_mailaddress_city {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_CITY" ;;
  }
  dimension: billto_mailaddress_country {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_COUNTRY" ;;
  }
  dimension: billto_mailaddress_countrycode {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_COUNTRYCODE" ;;
  }
  dimension: billto_mailaddress_recordkey {
    type: number
    sql: ${TABLE}."BILLTO_MAILADDRESS_RECORDKEY" ;;
  }
  dimension: billto_mailaddress_state {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_STATE" ;;
  }
  dimension: billto_mailaddress_zip {
    type: string
    sql: ${TABLE}."BILLTO_MAILADDRESS_ZIP" ;;
  }
  dimension: billto_pager {
    type: string
    sql: ${TABLE}."BILLTO_PAGER" ;;
  }
  dimension: billto_phone1 {
    type: string
    sql: ${TABLE}."BILLTO_PHONE1" ;;
  }
  dimension: billto_phone2 {
    type: string
    sql: ${TABLE}."BILLTO_PHONE2" ;;
  }
  dimension: billto_prefix {
    type: string
    sql: ${TABLE}."BILLTO_PREFIX" ;;
  }
  dimension: billto_printas {
    type: string
    sql: ${TABLE}."BILLTO_PRINTAS" ;;
  }
  dimension: billto_url1 {
    type: string
    sql: ${TABLE}."BILLTO_URL1" ;;
  }
  dimension: billto_url2 {
    type: string
    sql: ${TABLE}."BILLTO_URL2" ;;
  }
  dimension: billto_visible {
    type: yesno
    sql: ${TABLE}."BILLTO_VISIBLE" ;;
  }
  dimension: billtopaytocontactname {
    type: string
    sql: ${TABLE}."BILLTOPAYTOCONTACTNAME" ;;
  }
  dimension: billtopaytokey {
    type: number
    sql: ${TABLE}."BILLTOPAYTOKEY" ;;
  }
  dimension: cleared {
    type: string
    sql: ${TABLE}."CLEARED" ;;
  }
  dimension_group: clrdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CLRDATE" ;;
  }
  dimension: contact_cellphone {
    type: string
    sql: ${TABLE}."CONTACT_CELLPHONE" ;;
  }
  dimension: contact_companyname {
    type: string
    sql: ${TABLE}."CONTACT_COMPANYNAME" ;;
  }
  dimension: contact_contactname {
    type: string
    sql: ${TABLE}."CONTACT_CONTACTNAME" ;;
  }
  dimension: contact_email1 {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL1" ;;
  }
  dimension: contact_email2 {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL2" ;;
  }
  dimension: contact_fax {
    type: string
    sql: ${TABLE}."CONTACT_FAX" ;;
  }
  dimension: contact_firstname {
    type: string
    sql: ${TABLE}."CONTACT_FIRSTNAME" ;;
  }
  dimension: contact_initial {
    type: string
    sql: ${TABLE}."CONTACT_INITIAL" ;;
  }
  dimension: contact_lastname {
    type: string
    sql: ${TABLE}."CONTACT_LASTNAME" ;;
  }
  dimension: contact_mailaddress_address1 {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_ADDRESS1" ;;
  }
  dimension: contact_mailaddress_address2 {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_ADDRESS2" ;;
  }
  dimension: contact_mailaddress_city {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_CITY" ;;
  }
  dimension: contact_mailaddress_country {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_COUNTRY" ;;
  }
  dimension: contact_mailaddress_countrycode {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_COUNTRYCODE" ;;
  }
  dimension: contact_mailaddress_state {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_STATE" ;;
  }
  dimension: contact_mailaddress_zip {
    type: string
    sql: ${TABLE}."CONTACT_MAILADDRESS_ZIP" ;;
  }
  dimension: contact_pager {
    type: string
    sql: ${TABLE}."CONTACT_PAGER" ;;
  }
  dimension: contact_phone1 {
    type: string
    sql: ${TABLE}."CONTACT_PHONE1" ;;
  }
  dimension: contact_phone2 {
    type: string
    sql: ${TABLE}."CONTACT_PHONE2" ;;
  }
  dimension: contact_prefix {
    type: string
    sql: ${TABLE}."CONTACT_PREFIX" ;;
  }
  dimension: contact_printas {
    type: string
    sql: ${TABLE}."CONTACT_PRINTAS" ;;
  }
  dimension: contact_url1 {
    type: string
    sql: ${TABLE}."CONTACT_URL1" ;;
  }
  dimension: contact_url2 {
    type: string
    sql: ${TABLE}."CONTACT_URL2" ;;
  }
  dimension: contact_visible {
    type: yesno
    sql: ${TABLE}."CONTACT_VISIBLE" ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }
  dimension: custemailoptin {
    type: yesno
    sql: ${TABLE}."CUSTEMAILOPTIN" ;;
  }
  dimension: custentity {
    type: string
    sql: ${TABLE}."CUSTENTITY" ;;
  }
  dimension: custmessageid {
    type: string
    sql: ${TABLE}."CUSTMESSAGEID" ;;
  }
  dimension: customerid {
    type: string
    sql: ${TABLE}."CUSTOMERID" ;;
  }


  dimension: customername {
    type: string
    sql: ${TABLE}."CUSTOMERNAME" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: delivery_options {
    type: string
    sql: ${TABLE}."DELIVERY_OPTIONS" ;;
  }
  dimension: deliverymethod {
    type: string
    sql: ${TABLE}."DELIVERYMETHOD" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: description2 {
    type: string
    sql: ${TABLE}."DESCRIPTION2" ;;
  }
  dimension: docnumber {
    type: string
    sql: ${TABLE}."DOCNUMBER" ;;
  }
  dimension: documentnumber {
    type: string
    sql: ${TABLE}."DOCUMENTNUMBER" ;;
  }
  dimension: due_in_days {
    type: string
    sql: ${TABLE}."DUE_IN_DAYS" ;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }
  dimension_group: exch_rate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EXCH_RATE_DATE" ;;
  }
  dimension: exch_rate_type_id {
    type: number
    sql: ${TABLE}."EXCH_RATE_TYPE_ID" ;;
  }
  dimension: exchange_rate {
    type: number
    sql: ${TABLE}."EXCHANGE_RATE" ;;
  }
  dimension: financialaccount {
    type: string
    sql: ${TABLE}."FINANCIALACCOUNT" ;;
  }
  dimension: financialentity {
    type: string
    sql: ${TABLE}."FINANCIALENTITY" ;;
  }
  dimension: haspostedrevrec {
    type: string
    sql: ${TABLE}."HASPOSTEDREVREC" ;;
  }
  dimension: locationkey {
    type: number
    sql: ${TABLE}."LOCATIONKEY" ;;
  }
  dimension: megaentityid {
    type: string
    sql: ${TABLE}."MEGAENTITYID" ;;
  }
  dimension: megaentitykey {
    type: number
    sql: ${TABLE}."MEGAENTITYKEY" ;;
  }
  dimension: megaentityname {
    type: string
    sql: ${TABLE}."MEGAENTITYNAME" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: modulekey {
    type: string
    sql: ${TABLE}."MODULEKEY" ;;
  }
  dimension: nr_totalentered {
    type: number
    sql: ${TABLE}."NR_TOTALENTERED" ;;
  }
  dimension: nr_trx_totalentered {
    type: number
    sql: ${TABLE}."NR_TRX_TOTALENTERED" ;;
  }
  dimension: onhold {
    type: yesno
    sql: ${TABLE}."ONHOLD" ;;
  }
  dimension: paymentamount {
    type: number
    sql: ${TABLE}."PAYMENTAMOUNT" ;;
  }
  dimension_group: paymentdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENTDATE" ;;
  }
  dimension: paymentmethod {
    type: string
    sql: ${TABLE}."PAYMENTMETHOD" ;;
  }
  dimension: paymentmethodkey {
    type: number
    sql: ${TABLE}."PAYMENTMETHODKEY" ;;
  }
  dimension: paymenttype {
    type: string
    sql: ${TABLE}."PAYMENTTYPE" ;;
  }
  dimension_group: postingdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POSTINGDATE" ;;
  }
  dimension: prbatch {
    type: string
    sql: ${TABLE}."PRBATCH" ;;
  }
  dimension: prbatchkey {
    type: number
    sql: ${TABLE}."PRBATCHKEY" ;;
  }
  dimension: projectcontractid {
    type: string
    sql: ${TABLE}."PROJECTCONTRACTID" ;;
  }
  dimension: projectcontractkey {
    type: number
    sql: ${TABLE}."PROJECTCONTRACTKEY" ;;
  }
  dimension: rawstate {
    type: string
    sql: ${TABLE}."RAWSTATE" ;;
  }
  dimension_group: receiptdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RECEIPTDATE" ;;
  }
  dimension_group: recon {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RECON_DATE" ;;
  }
  dimension: recordid {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }
  # dimension: recordno {
  #   type: number
  #   sql: ${TABLE}."RECORDNO" ;;
  # }
  dimension: recordno {
    primary_key: yes
    type: string
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: recordtype {
    type: string
    sql: ${TABLE}."RECORDTYPE" ;;
  }
  dimension: retainagepercentage {
    type: number
    sql: ${TABLE}."RETAINAGEPERCENTAGE" ;;
  }
  dimension: schopkey {
    type: number
    sql: ${TABLE}."SCHOPKEY" ;;
  }
  dimension: shipto_cellphone {
    type: string
    sql: ${TABLE}."SHIPTO_CELLPHONE" ;;
  }
  dimension: shipto_companyname {
    type: string
    sql: ${TABLE}."SHIPTO_COMPANYNAME" ;;
  }
  dimension: shipto_contactname {
    type: string
    sql: ${TABLE}."SHIPTO_CONTACTNAME" ;;
  }
  dimension: shipto_email1 {
    type: string
    sql: ${TABLE}."SHIPTO_EMAIL1" ;;
  }
  dimension: shipto_email2 {
    type: string
    sql: ${TABLE}."SHIPTO_EMAIL2" ;;
  }
  dimension: shipto_fax {
    type: string
    sql: ${TABLE}."SHIPTO_FAX" ;;
  }
  dimension: shipto_firstname {
    type: string
    sql: ${TABLE}."SHIPTO_FIRSTNAME" ;;
  }
  dimension: shipto_initial {
    type: string
    sql: ${TABLE}."SHIPTO_INITIAL" ;;
  }
  dimension: shipto_lastname {
    type: string
    sql: ${TABLE}."SHIPTO_LASTNAME" ;;
  }
  dimension: shipto_mailaddress_address1 {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_ADDRESS1" ;;
  }
  dimension: shipto_mailaddress_address2 {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_ADDRESS2" ;;
  }
  dimension: shipto_mailaddress_city {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_CITY" ;;
  }
  dimension: shipto_mailaddress_country {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_COUNTRY" ;;
  }
  dimension: shipto_mailaddress_countrycode {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_COUNTRYCODE" ;;
  }
  dimension: shipto_mailaddress_recordkey {
    type: number
    sql: ${TABLE}."SHIPTO_MAILADDRESS_RECORDKEY" ;;
  }
  dimension: shipto_mailaddress_state {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_STATE" ;;
  }
  dimension: shipto_mailaddress_zip {
    type: string
    sql: ${TABLE}."SHIPTO_MAILADDRESS_ZIP" ;;
  }
  dimension: shipto_pager {
    type: string
    sql: ${TABLE}."SHIPTO_PAGER" ;;
  }
  dimension: shipto_phone1 {
    type: string
    sql: ${TABLE}."SHIPTO_PHONE1" ;;
  }
  dimension: shipto_phone2 {
    type: string
    sql: ${TABLE}."SHIPTO_PHONE2" ;;
  }
  dimension: shipto_prefix {
    type: string
    sql: ${TABLE}."SHIPTO_PREFIX" ;;
  }
  dimension: shipto_printas {
    type: string
    sql: ${TABLE}."SHIPTO_PRINTAS" ;;
  }
  dimension: shipto_taxgroup_recordno {
    type: number
    sql: ${TABLE}."SHIPTO_TAXGROUP_RECORDNO" ;;
  }
  dimension: shipto_url1 {
    type: string
    sql: ${TABLE}."SHIPTO_URL1" ;;
  }
  dimension: shipto_url2 {
    type: string
    sql: ${TABLE}."SHIPTO_URL2" ;;
  }
  dimension: shipto_visible {
    type: yesno
    sql: ${TABLE}."SHIPTO_VISIBLE" ;;
  }
  dimension: shiptoreturntocontactname {
    type: string
    sql: ${TABLE}."SHIPTORETURNTOCONTACTNAME" ;;
  }
  dimension: shiptoreturntokey {
    type: number
    sql: ${TABLE}."SHIPTORETURNTOKEY" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: supdocid {
    type: string
    sql: ${TABLE}."SUPDOCID" ;;
  }
  dimension: systemgenerated {
    type: string
    sql: ${TABLE}."SYSTEMGENERATED" ;;
  }
  dimension: taxsolutionid {
    type: string
    sql: ${TABLE}."TAXSOLUTIONID" ;;
  }
  dimension: termkey {
    type: number
    sql: ${TABLE}."TERMKEY" ;;
  }
  dimension: termname {
    type: string
    sql: ${TABLE}."TERMNAME" ;;
  }
  dimension: termvalue {
    type: string
    sql: ${TABLE}."TERMVALUE" ;;
  }
  dimension: totaldue {
    type: number
    sql: ${TABLE}."TOTALDUE" ;;
  }
  dimension: totalentered {
    type: number
    sql: ${TABLE}."TOTALENTERED" ;;
  }
  dimension: totalpaid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTALPAID" ;;
  }
  dimension: totalretained {
    type: number
    sql: ${TABLE}."TOTALRETAINED" ;;
  }
  dimension: totalselected {
    type: number
    sql: ${TABLE}."TOTALSELECTED" ;;
  }
  dimension: trx_entitydue {
    type: number
    sql: ${TABLE}."TRX_ENTITYDUE" ;;
  }
  dimension: trx_totaldue {
    type: number
    sql: ${TABLE}."TRX_TOTALDUE" ;;
  }
  dimension: trx_totalentered {
    type: number
    sql: ${TABLE}."TRX_TOTALENTERED" ;;
  }
  dimension: trx_totalpaid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRX_TOTALPAID" ;;
  }
  dimension: trx_totalreleased {
    type: number
    sql: ${TABLE}."TRX_TOTALRELEASED" ;;
  }
  dimension: trx_totalretained {
    type: number
    sql: ${TABLE}."TRX_TOTALRETAINED" ;;
  }
  dimension: trx_totalselected {
    type: number
    sql: ${TABLE}."TRX_TOTALSELECTED" ;;
  }
  dimension: undepositedaccountno {
    type: string
    sql: ${TABLE}."UNDEPOSITEDACCOUNTNO" ;;
  }
  dimension: userkey {
    type: number
    sql: ${TABLE}."USERKEY" ;;
  }
  dimension_group: whencreated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENCREATED" ;;
  }
    dimension_group: whendiscount {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENDISCOUNT" ;;
  }
  dimension_group: whendue {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENDUE" ;;
  }
  dimension_group: whenmodified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: whenpaid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENPAID" ;;
  }
  dimension_group: whenposted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENPOSTED" ;;
  }

  dimension: invoice_quarter {
    type: string
    sql: ${TABLE}."FOR_QUARTER" ;;
  }

  dimension: quarter_date {
    type: date
    sql:
      CASE
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q1' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 1, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q2' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 4, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q3' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 7, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q4' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 10, 1))
      END ;;
  }

  dimension_group: quarter_date_group {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CASE
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q1' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 1, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q2' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 4, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q3' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 7, 1))
        WHEN ${TABLE}."FOR_QUARTER" LIKE '%-Q4' THEN DATE_TRUNC('quarter', DATE_FROM_PARTS(SUBSTRING(${TABLE}."FOR_QUARTER", 1, 4)::INT, 10, 1))
      END ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      recordid
  , recordno
  , customerid
  , customername
  , trx_totalentered
  , prbatch
  , docnumber
  , recordtype

  , systemgenerated

  ]
  }

  measure: amount_owed {
    type: number
    drill_fields: [owed_detail*]
    sql: SUM(${trx_totalentered}) - COALESCE(SUM(${arinvoicepayment_sum.total_paid}), 0) ;;
    value_format_name: "decimal_0"
  }


  # measure: amount_owed_new {
  #   type: number
  #   drill_fields: [owed_detail*]
  #   sql: SUM(${trx_totalentered}) - COALESCE(SUM(${arinvoicepayment.amount_paid}), 0) ;;
  # }


  # ----- Sets of fields for drilling ------
  set: owed_detail {
    fields: [
      amount_owed,
      customername,
      recordid,
      trx_totalentered,
      arinvoicepayment_sum.total_paid
     ]

}
}
