view: cmrecord {
  sql_table_name: "INTACCT"."CMRECORD" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension_group: auwhencreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."AUWHENCREATED" ;;
  }
  dimension: bankaccountcurr {
    type: string
    sql: ${TABLE}."BANKACCOUNTCURR" ;;
  }
  dimension: bankaccountid {
    type: string
    sql: ${TABLE}."BANKACCOUNTID" ;;
  }
  dimension: bankaccountname {
    type: string
    sql: ${TABLE}."BANKACCOUNTNAME" ;;
  }
  dimension: bankname {
    type: string
    sql: ${TABLE}."BANKNAME" ;;
  }
  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
  }
  dimension: cleared {
    type: string
    sql: ${TABLE}."CLEARED" ;;
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
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DDSREADTIME" ;;
  }
  dimension_group: depositdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DEPOSITDATE" ;;
  }
  dimension: depositid {
    type: string
    sql: ${TABLE}."DEPOSITID" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: description2 {
    label: "Payer"
    type: string
    sql: ${TABLE}."DESCRIPTION2" ;;
  }
  dimension: docnumber {
    type: string
    sql: ${TABLE}."DOCNUMBER" ;;
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
    type: string
    sql: ${TABLE}."EXCH_RATE_TYPE_ID" ;;
  }
  dimension: exchange_rate {
    type: number
    sql: ${TABLE}."EXCHANGE_RATE" ;;
  }
  dimension: financialentity {
    type: string
    sql: ${TABLE}."FINANCIALENTITY" ;;
  }
  dimension: fromaccountcurr {
    type: string
    sql: ${TABLE}."FROMACCOUNTCURR" ;;
  }
  dimension: fromaccountid {
    type: string
    sql: ${TABLE}."FROMACCOUNTID" ;;
  }
  dimension: fromaccountname {
    type: string
    sql: ${TABLE}."FROMACCOUNTNAME" ;;
  }
  dimension: fromglaccountno {
    type: string
    sql: ${TABLE}."FROMGLACCOUNTNO" ;;
  }
  dimension: impliedlocation {
    type: number
    sql: ${TABLE}."IMPLIEDLOCATION" ;;
  }
  dimension: inclusivetax {
    type: yesno
    sql: ${TABLE}."INCLUSIVETAX" ;;
  }
  dimension: liabacctkey {
    type: number
    sql: ${TABLE}."LIABACCTKEY" ;;
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
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: parentpayment {
    type: number
    sql: ${TABLE}."PARENTPAYMENT" ;;
  }
  dimension: paymentkey {
    type: number
    sql: ${TABLE}."PAYMENTKEY" ;;
  }
  dimension: paymethod {
    type: string
    sql: ${TABLE}."PAYMETHOD" ;;
  }
  dimension: prbatchkey {
    type: number
    sql: ${TABLE}."PRBATCHKEY" ;;
  }
  dimension: rawstate {
    type: string
    sql: ${TABLE}."RAWSTATE" ;;
  }
  dimension_group: recon {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RECON_DATE" ;;
  }
  dimension: recordid {
    type: string
    sql: ${TABLE}."RECORDID" ;;
  }
  dimension: recordno {
    primary_key: yes
    type: string
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: recordtype {
    type: string
    sql: ${TABLE}."RECORDTYPE" ;;
  }
  dimension: reversaldate {
    type: string
    sql: ${TABLE}."REVERSALDATE" ;;
  }
  dimension: reversalkey {
    type: number
    sql: ${TABLE}."REVERSALKEY" ;;
  }
  dimension: reverseddate {
    type: string
    sql: ${TABLE}."REVERSEDDATE" ;;
  }
  dimension: reversedkey {
    type: number
    sql: ${TABLE}."REVERSEDKEY" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: taxsolutionid {
    type: string
    sql: ${TABLE}."TAXSOLUTIONID" ;;
  }
  dimension: toaccountcurr {
    type: string
    sql: ${TABLE}."TOACCOUNTCURR" ;;
  }
  dimension: toaccountid {
    type: string
    sql: ${TABLE}."TOACCOUNTID" ;;
  }
  dimension: toaccountname {
    type: string
    sql: ${TABLE}."TOACCOUNTNAME" ;;
  }
  dimension: toglaccountno {
    type: string
    sql: ${TABLE}."TOGLACCOUNTNO" ;;
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
  dimension: totalselected {
    type: number
    sql: ${TABLE}."TOTALSELECTED" ;;
  }
  dimension: transactiontype {
    type: string
    sql: ${TABLE}."TRANSACTIONTYPE" ;;
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
  dimension: trx_totalselected {
    type: number
    sql: ${TABLE}."TRX_TOTALSELECTED" ;;
  }
  dimension_group: whencreated {
    label: "Bill"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENCREATED" ;;
  }
  dimension_group: whenmodified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."WHENMODIFIED" ;;
  }
  dimension_group: whenpaid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WHENPAID" ;;
  }
  measure: total_entered {
    type: sum
    sql: ${TABLE}."TOTALENTERED" ;;
    drill_fields: [cmdetail.accounttitle, cmdetail.departmentname, cmdetail.description, cmdetail.amount]
  }
  measure: count {
    type: count
    drill_fields: [fromaccountname, megaentityname, bankname, bankaccountname, toaccountname]
  }
}
