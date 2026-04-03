view: aprecord {
  sql_table_name: "PUBLIC"."APRECORD"
    ;;

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: auwhencreated {
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
    sql: CAST(${TABLE}."AUWHENCREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
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

  dimension: clrdate {
    type: string
    sql: ${TABLE}."CLRDATE" ;;
  }

  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }

  dimension_group: ddsreadtime {
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
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
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
    type: number
    sql: ${TABLE}."DUE_IN_DAYS" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: exch_rate_date {
    type: string
    sql: ${TABLE}."EXCH_RATE_DATE" ;;
  }

  dimension: exch_rate_type_id {
    type: string
    sql: ${TABLE}."EXCH_RATE_TYPE_ID" ;;
  }

  dimension: exchange_rate {
    type: string
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

  dimension: form1099_box {
    type: string
    sql: ${TABLE}."FORM1099BOX" ;;
  }

  dimension: form1099_type {
    type: string
    sql: ${TABLE}."FORM1099TYPE" ;;
  }

  dimension: inclusivetax {
    type: string
    sql: ${TABLE}."INCLUSIVETAX" ;;
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
    type: string
    sql: ${TABLE}."NR_TOTALENTERED" ;;
  }

  dimension: nr_trx_totalentered {
    type: string
    sql: ${TABLE}."NR_TRX_TOTALENTERED" ;;
  }

  dimension: onhold {
    type: string
    sql: ${TABLE}."ONHOLD" ;;
  }

  dimension: paymentamount {
    type: number
    sql: ${TABLE}."PAYMENTAMOUNT" ;;
  }

  dimension_group: paymentdate {
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
    sql: CAST(${TABLE}."PAYMENTDATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: paymentpriority {
    type: string
    sql: ${TABLE}."PAYMENTPRIORITY" ;;
  }

  dimension: paymenttype {
    type: string
    sql: ${TABLE}."PAYMENTTYPE" ;;
  }

  dimension: payto_taxgroup_recordno {
    type: string
    sql: ${TABLE}."PAYTO_TAXGROUP_RECORDNO" ;;
  }

  dimension: prbatch {
    type: string
    sql: ${TABLE}."PRBATCH" ;;
  }

  dimension: prbatch_nogl {
    type: string
    sql: ${TABLE}."PRBATCH_NOGL" ;;
  }

  dimension: prbatch_open {
    type: string
    sql: ${TABLE}."PRBATCH_OPEN" ;;
  }

  dimension: prbatchkey {
    type: number
    sql: ${TABLE}."PRBATCHKEY" ;;
  }

  dimension: rawstate {
    type: string
    sql: ${TABLE}."RAWSTATE" ;;
  }

  dimension_group: receiptdate {
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
    sql: CAST(${TABLE}."RECEIPTDATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: recon {
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
    sql: CAST(${TABLE}."RECON_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: recordid {
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: recordtype {
    type: string
    sql: ${TABLE}."RECORDTYPE" ;;
  }

  dimension: recpaymentdate {
    type: string
    sql: ${TABLE}."RECPAYMENTDATE" ;;
  }

  dimension: retainagepercentage {
    type: string
    sql: ${TABLE}."RETAINAGEPERCENTAGE" ;;
  }

  dimension: schopkey {
    type: string
    sql: ${TABLE}."SCHOPKEY" ;;
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
    type: string
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
    type: string
    sql: ${TABLE}."TRX_TOTALRELEASED" ;;
  }

  dimension: trx_totalretained {
    type: string
    sql: ${TABLE}."TRX_TOTALRETAINED" ;;
  }

  dimension: trx_totalselected {
    type: number
    sql: ${TABLE}."TRX_TOTALSELECTED" ;;
  }

  dimension: userkey {
    type: number
    sql: ${TABLE}."USERKEY" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendorname {
    type: string
    sql: ${TABLE}."VENDORNAME" ;;
  }

  dimension: vendtype1099_type {
    type: string
    sql: ${TABLE}."VENDTYPE1099TYPE" ;;
  }

  dimension_group: whencreated {
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
    sql: CAST(${TABLE}."WHENCREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: whendiscount {
    type: string
    sql: ${TABLE}."WHENDISCOUNT" ;;
  }

  dimension_group: whendue {
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
    sql: CAST(${TABLE}."WHENDUE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: whenmodified {
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
    sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: whenpaid {
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
    sql: CAST(${TABLE}."WHENPAID" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: whenposted {
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
    sql: CAST(${TABLE}."WHENPOSTED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: yooz_docid {
    type: number
    value_format_name: id
    sql: ${TABLE}."YOOZ_DOCID" ;;
  }

  dimension: yooz_url {
    type: string
    sql: ${TABLE}."YOOZ_URL" ;;
  }

  measure: count {
    type: count
    drill_fields: [billtopaytocontactname, vendorname, termname, shiptoreturntocontactname, megaentityname]
  }
}
