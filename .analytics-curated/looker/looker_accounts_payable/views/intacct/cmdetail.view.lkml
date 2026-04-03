view: cmdetail {
  sql_table_name: "INTACCT"."CMDETAIL" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }
  dimension: accountlabel {
    type: string
    sql: ${TABLE}."ACCOUNTLABEL" ;;
  }
  dimension: accountlabelkey {
    type: number
    sql: ${TABLE}."ACCOUNTLABELKEY" ;;
  }
  dimension: accountno {
    label: "Account Number"
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }
  dimension: accounttitle {
    type: string
    sql: ${TABLE}."ACCOUNTTITLE" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
  }
  dimension: baselocation {
    type: number
    sql: ${TABLE}."BASELOCATION" ;;
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
  dimension: departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }
  dimension: departmentkey {
    type: number
    sql: ${TABLE}."DEPARTMENTKEY" ;;
  }
  dimension: departmentname {
    type: string
    sql: ${TABLE}."DEPARTMENTNAME" ;;
  }
  dimension: deptkey {
    type: number
    sql: ${TABLE}."DEPTKEY" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: detailid {
    type: string
    sql: ${TABLE}."DETAILID" ;;
  }
  dimension: employeedimkey {
    type: number
    sql: ${TABLE}."EMPLOYEEDIMKEY" ;;
  }
  dimension: employeeid {
    type: string
    sql: ${TABLE}."EMPLOYEEID" ;;
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
    type: string
    sql: ${TABLE}."LINE_NO" ;;
  }
  dimension: lineitem {
    type: string
    sql: ${TABLE}."LINEITEM" ;;
  }
  dimension: locationid {
    type: string
    sql: ${TABLE}."LOCATIONID" ;;
  }
  dimension: locationkey {
    type: number
    sql: ${TABLE}."LOCATIONKEY" ;;
  }
  dimension: locationname {
    type: string
    sql: ${TABLE}."LOCATIONNAME" ;;
  }
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: recordkey {
    type: number
    sql: ${TABLE}."RECORDKEY" ;;
  }
  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: recordtype {
    type: string
    sql: ${TABLE}."RECORDTYPE" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: taxrate {
    type: number
    sql: ${TABLE}."TAXRATE" ;;
  }
  dimension: totalexpensed {
    type: number
    sql: ${TABLE}."TOTALEXPENSED" ;;
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
  dimension: trx_amount {
    type: number
    sql: ${TABLE}."TRX_AMOUNT" ;;
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
  # measure: total_amount {
  #   type: sum
  # }
  # measure: count {
  #   type: count
  #   drill_fields: [locationname, departmentname]
  # }
}
