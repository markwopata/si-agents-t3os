view: glentry {
  # sql_table_name: "ANALYTICS"."INTACCT"."GLENTRY" ;;

  derived_table: {
    sql: SELECT * FROM "ANALYTICS"."INTACCT"."GLENTRY"
      WHERE entry_date <= CURRENT_DATE() ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }
  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }
  dimension: adj {
    type: string
    sql: ${TABLE}."ADJ" ;;
  }
  dimension: allocationkey {
    type: number
    sql: ${TABLE}."ALLOCATIONKEY" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
  }
  dimension: batchno {
    type: number
    sql: ${TABLE}."BATCHNO" ;;
  }
  dimension: batchtitle {
    type: string
    sql: ${TABLE}."BATCHTITLE" ;;
  }
  dimension: billable {
    type: yesno
    sql: ${TABLE}."BILLABLE" ;;
  }
  dimension: billed {
    type: yesno
    sql: ${TABLE}."BILLED" ;;
  }
  dimension: classdimkey {
    type: number
    sql: ${TABLE}."CLASSDIMKEY" ;;
  }
  dimension: classid {
    type: string
    sql: ${TABLE}."CLASSID" ;;
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
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }
  dimension: customerdimkey {
    type: number
    sql: ${TABLE}."CUSTOMERDIMKEY" ;;
  }
  dimension: customerid {
    type: string
    sql: ${TABLE}."CUSTOMERID" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: departmentkey {
    type: number
    sql: ${TABLE}."DEPARTMENTKEY" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: document {
    type: string
    sql: ${TABLE}."DOCUMENT" ;;
  }
  dimension: employeedimkey {
    type: number
    sql: ${TABLE}."EMPLOYEEDIMKEY" ;;
  }
  dimension: employeeid {
    type: string
    sql: ${TABLE}."EMPLOYEEID" ;;
  }
  dimension_group: entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ENTRY_DATE" ;;
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
  dimension: gldimasset {
    type: string
    sql: ${TABLE}."GLDIMASSET" ;;
  }
  dimension: gldimexpense_line {
    type: string
    sql: ${TABLE}."GLDIMEXPENSE_LINE" ;;
  }
  dimension: gldimtransaction_identifier {
    type: string
    sql: ${TABLE}."GLDIMTRANSACTION_IDENTIFIER" ;;
  }
  dimension: gldimud_loan {
    type: string
    sql: ${TABLE}."GLDIMUD_LOAN" ;;
  }
  dimension: itemdimkey {
    type: number
    sql: ${TABLE}."ITEMDIMKEY" ;;
  }
  dimension: itemid {
    type: string
    sql: ${TABLE}."ITEMID" ;;
  }
  dimension: line_no {
    type: number
    sql: ${TABLE}."LINE_NO" ;;
  }
  dimension: loan_memo {
    type: string
    sql: ${TABLE}."LOAN_MEMO" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: locationkey {
    type: number
    sql: ${TABLE}."LOCATIONKEY" ;;
  }
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension_group: recon {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RECON_DATE" ;;
  }
  dimension: recordno {
    type: number
    primary_key: yes
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: statistical {
    type: string
    sql: ${TABLE}."STATISTICAL" ;;
  }
  dimension: timeperiod {
    type: number
    sql: ${TABLE}."TIMEPERIOD" ;;
  }
  dimension: tr_type {
    type: number
    sql: ${TABLE}."TR_TYPE" ;;
  }
  dimension: trx_amount {
    type: number
    sql: ${TABLE}."TRX_AMOUNT" ;;
  }
  dimension: ud_esadmin_invoice_number {
    type: string
    sql: ${TABLE}."UD_ESADMIN_INVOICE_NUMBER" ;;
  }
  dimension: ud_estrack_workorder_number {
    type: string
    sql: ${TABLE}."UD_ESTRACK_WORKORDER_NUMBER" ;;
  }
  dimension: userno {
    type: number
    sql: ${TABLE}."USERNO" ;;
  }
  dimension: vendordimkey {
    type: number
    sql: ${TABLE}."VENDORDIMKEY" ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }
  dimension_group: whencreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENCREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: whenmodified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  measure: total_amount {
    type: sum
    sql:  -1 * ${TABLE}.amount * ${TABLE}.tr_type ;;
  }
  measure: count {
    type: count
  }
}
