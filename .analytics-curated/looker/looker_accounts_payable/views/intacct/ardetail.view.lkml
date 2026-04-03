view: ardetail {
  sql_table_name: "INTACCT"."ARDETAIL" ;;

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
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }
  dimension: accounttitle {
    type: string
    sql: ${TABLE}."ACCOUNTTITLE" ;;
  }
  dimension: allocation {
    type: string
    sql: ${TABLE}."ALLOCATION" ;;
  }
  dimension: allocationkey {
    type: number
    sql: ${TABLE}."ALLOCATIONKEY" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: amountretained {
    type: number
    sql: ${TABLE}."AMOUNTRETAINED" ;;
  }
  dimension: ar_adj_assetid {
    type: string
    sql: ${TABLE}."AR_ADJ_ASSETID" ;;
  }
  dimension: ar_adj_lineitemid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AR_ADJ_LINEITEMID" ;;
  }
  dimension: ar_inv_assetid {
    type: string
    sql: ${TABLE}."AR_INV_ASSETID" ;;
  }
  dimension: ar_inv_lineitemid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AR_INV_LINEITEMID" ;;
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
  dimension: deferredrevacctkey {
    type: number
    sql: ${TABLE}."DEFERREDREVACCTKEY" ;;
  }
  dimension: deferredrevacctno {
    type: string
    sql: ${TABLE}."DEFERREDREVACCTNO" ;;
  }
  dimension: deferredrevaccttitle {
    type: string
    sql: ${TABLE}."DEFERREDREVACCTTITLE" ;;
  }
  dimension: deferrevenue {
    type: yesno
    sql: ${TABLE}."DEFERREVENUE" ;;
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
  dimension_group: entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ENTRY_DATE" ;;
  }
  dimension: entrydescription {
    type: string
    sql: ${TABLE}."ENTRYDESCRIPTION" ;;
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
  dimension: form1099 {
    type: string
    sql: ${TABLE}."FORM1099" ;;
  }
  dimension: gldimasset {
    type: string
    sql: ${TABLE}."GLDIMASSET" ;;
  }
  dimension: gldimtransaction_identifier {
    type: string
    sql: ${TABLE}."GLDIMTRANSACTION_IDENTIFIER" ;;
  }
  dimension: gldimud_loan {
    type: string
    sql: ${TABLE}."GLDIMUD_LOAN" ;;
  }
  dimension: gloffset {
    type: number
    sql: ${TABLE}."GLOFFSET" ;;
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
  dimension: offsetglaccountno {
    type: string
    sql: ${TABLE}."OFFSETGLACCOUNTNO" ;;
  }
  dimension: offsetglaccounttitle {
    type: string
    sql: ${TABLE}."OFFSETGLACCOUNTTITLE" ;;
  }
  dimension: parententry {
    type: number
    sql: ${TABLE}."PARENTENTRY" ;;
  }
  dimension: prentryoffsetaccountno {
    type: string
    sql: ${TABLE}."PRENTRYOFFSETACCOUNTNO" ;;
  }
  dimension: projectcontractid {
    type: string
    sql: ${TABLE}."PROJECTCONTRACTID" ;;
  }
  dimension: projectcontractkey {
    type: number
    sql: ${TABLE}."PROJECTCONTRACTKEY" ;;
  }
  dimension: projectcontractlineid {
    type: string
    sql: ${TABLE}."PROJECTCONTRACTLINEID" ;;
  }
  dimension: projectcontractlinekey {
    type: number
    sql: ${TABLE}."PROJECTCONTRACTLINEKEY" ;;
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
  dimension: releasetopay {
    type: yesno
    sql: ${TABLE}."RELEASETOPAY" ;;
  }
  dimension: retainagepercentage {
    type: number
    sql: ${TABLE}."RETAINAGEPERCENTAGE" ;;
  }
  dimension_group: revrecenddate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REVRECENDDATE" ;;
  }
  dimension_group: revrecstartdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REVRECSTARTDATE" ;;
  }
  dimension: revrectemplate {
    type: string
    sql: ${TABLE}."REVRECTEMPLATE" ;;
  }
  dimension: revrectemplatekey {
    type: number
    sql: ${TABLE}."REVRECTEMPLATEKEY" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: subtotal {
    type: string
    sql: ${TABLE}."SUBTOTAL" ;;
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
  dimension: trx_amountreleased {
    type: number
    sql: ${TABLE}."TRX_AMOUNTRELEASED" ;;
  }
  dimension: trx_amountretained {
    type: number
    sql: ${TABLE}."TRX_AMOUNTRETAINED" ;;
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
  dimension: vendoracctnokeyversion {
    type: number
    sql: ${TABLE}."VENDORACCTNOKEYVERSION" ;;
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
  measure: count {
    type: count
    drill_fields: [locationname, departmentname]
  }
}
