view: cpe_bills_posted_via_yooz {
  derived_table: {
    sql: SELECT *
          FROM "ANALYTICS"."INTACCT"."APDETAIL" APD
      WHERE to_varchar(APD.DEPARTMENTID) IN ('61102','61104','61105','61106','61108','40698')
      AND APD.CREATEDBY = 17
      AND APD.RECORDTYPE = 'apbillentry'
      And APD.WHENCREATED >= '2022-04-30'
      ORDER BY APD.WHENCREATED DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: gldimud_loan {
    type: string
    sql: ${TABLE}."GLDIMUD_LOAN" ;;
  }

  dimension: gldimasset {
    type: string
    sql: ${TABLE}."GLDIMASSET" ;;
  }

  dimension: gldimtransaction_identifier {
    type: string
    sql: ${TABLE}."GLDIMTRANSACTION_IDENTIFIER" ;;
  }

  dimension: accountlabelkey {
    type: number
    sql: ${TABLE}."ACCOUNTLABELKEY" ;;
  }

  dimension: entrydescription {
    type: string
    sql: ${TABLE}."ENTRYDESCRIPTION" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: allocation {
    type: string
    sql: ${TABLE}."ALLOCATION" ;;
  }

  dimension: line_no {
    type: string
    sql: ${TABLE}."LINE_NO" ;;
  }

  dimension: form1099 {
    type: string
    sql: ${TABLE}."FORM1099" ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }

  dimension: exch_rate_date {
    type: date
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

  dimension: trx_amount {
    type: number
    sql: ${TABLE}."TRX_AMOUNT" ;;
  }

  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: locationid {
    type: string
    sql: ${TABLE}."LOCATIONID" ;;
  }

  dimension: departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }

  dimension: accountlabel {
    type: string
    sql: ${TABLE}."ACCOUNTLABEL" ;;
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}."ENTRY_DATE" ;;
  }

  dimension: recordkey {
    type: number
    sql: ${TABLE}."RECORDKEY" ;;
  }

  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }

  dimension: accounttitle {
    type: string
    sql: ${TABLE}."ACCOUNTTITLE" ;;
  }

  dimension: locationname {
    type: string
    sql: ${TABLE}."LOCATIONNAME" ;;
  }

  dimension: departmentname {
    type: string
    sql: ${TABLE}."DEPARTMENTNAME" ;;
  }

  dimension: totalselected {
    type: number
    sql: ${TABLE}."TOTALSELECTED" ;;
  }

  dimension: totalpaid {
    type: number
    sql: ${TABLE}."TOTALPAID" ;;
  }

  dimension: parententry {
    type: number
    sql: ${TABLE}."PARENTENTRY" ;;
  }

  dimension: lineitem {
    type: string
    sql: ${TABLE}."LINEITEM" ;;
  }

  dimension: baselocation {
    type: number
    sql: ${TABLE}."BASELOCATION" ;;
  }

  dimension: allocationkey {
    type: number
    sql: ${TABLE}."ALLOCATIONKEY" ;;
  }

  dimension: trx_totalselected {
    type: number
    sql: ${TABLE}."TRX_TOTALSELECTED" ;;
  }

  dimension: trx_totalpaid {
    type: number
    sql: ${TABLE}."TRX_TOTALPAID" ;;
  }

  dimension: billable {
    type: yesno
    sql: ${TABLE}."BILLABLE" ;;
  }

  dimension: billed {
    type: yesno
    sql: ${TABLE}."BILLED" ;;
  }

  dimension: releasetopay {
    type: yesno
    sql: ${TABLE}."RELEASETOPAY" ;;
  }

  dimension: prentryoffsetaccountno {
    type: string
    sql: ${TABLE}."PRENTRYOFFSETACCOUNTNO" ;;
  }

  dimension: offsetglaccountno {
    type: string
    sql: ${TABLE}."OFFSETGLACCOUNTNO" ;;
  }

  dimension: offsetglaccounttitle {
    type: string
    sql: ${TABLE}."OFFSETGLACCOUNTTITLE" ;;
  }

  dimension: subtotal {
    type: string
    sql: ${TABLE}."SUBTOTAL" ;;
  }

  dimension: basecurr {
    type: string
    sql: ${TABLE}."BASECURR" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: recordtype {
    type: string
    sql: ${TABLE}."RECORDTYPE" ;;
  }

  dimension: partialexempt {
    type: yesno
    sql: ${TABLE}."PARTIALEXEMPT" ;;
  }

  dimension: form1099_type {
    type: string
    sql: ${TABLE}."FORM1099TYPE" ;;
  }

  dimension: form1099_box {
    type: string
    sql: ${TABLE}."FORM1099BOX" ;;
  }

  dimension: trx_amountretained {
    type: number
    sql: ${TABLE}."TRX_AMOUNTRETAINED" ;;
  }

  dimension: trx_amountreleased {
    type: number
    sql: ${TABLE}."TRX_AMOUNTRELEASED" ;;
  }

  dimension: retainagepercentage {
    type: number
    sql: ${TABLE}."RETAINAGEPERCENTAGE" ;;
  }

  dimension: amountretained {
    type: number
    sql: ${TABLE}."AMOUNTRETAINED" ;;
  }

  dimension: customerid {
    type: string
    sql: ${TABLE}."CUSTOMERID" ;;
  }

  dimension: customerdimkey {
    type: number
    sql: ${TABLE}."CUSTOMERDIMKEY" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendordimkey {
    type: number
    sql: ${TABLE}."VENDORDIMKEY" ;;
  }

  dimension: employeeid {
    type: string
    sql: ${TABLE}."EMPLOYEEID" ;;
  }

  dimension: employeedimkey {
    type: number
    sql: ${TABLE}."EMPLOYEEDIMKEY" ;;
  }

  dimension: itemid {
    type: string
    sql: ${TABLE}."ITEMID" ;;
  }

  dimension: itemdimkey {
    type: number
    sql: ${TABLE}."ITEMDIMKEY" ;;
  }

  dimension: classid {
    type: string
    sql: ${TABLE}."CLASSID" ;;
  }

  dimension: classdimkey {
    type: number
    sql: ${TABLE}."CLASSDIMKEY" ;;
  }

  dimension_group: whenmodified {
    type: time
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  dimension_group: whencreated {
    type: time
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }

  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: ud_esadmin_invoice_number {
    type: string
    sql: ${TABLE}."UD_ESADMIN_INVOICE_NUMBER" ;;
  }

  dimension: ud_estrack_workorder_number {
    type: string
    sql: ${TABLE}."UD_ESTRACK_WORKORDER_NUMBER" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: revrectemplate {
    type: string
    sql: ${TABLE}."REVRECTEMPLATE" ;;
  }

  dimension: revrecstartdate {
    type: date
    sql: ${TABLE}."REVRECSTARTDATE" ;;
  }

  dimension: revrecenddate {
    type: date
    sql: ${TABLE}."REVRECENDDATE" ;;
  }

  dimension: gloffset {
    type: number
    sql: ${TABLE}."GLOFFSET" ;;
  }

  dimension: deferrevenue {
    type: yesno
    sql: ${TABLE}."DEFERREVENUE" ;;
  }

  dimension: revrectemplatekey {
    type: number
    sql: ${TABLE}."REVRECTEMPLATEKEY" ;;
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

  dimension: vendoracctnokeyversion {
    type: number
    sql: ${TABLE}."VENDORACCTNOKEYVERSION" ;;
  }

  dimension: locationkey {
    type: number
    sql: ${TABLE}."LOCATIONKEY" ;;
  }

  dimension: departmentkey {
    type: number
    sql: ${TABLE}."DEPARTMENTKEY" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: ddsreadtime {
    type: time
    sql: ${TABLE}."DDSREADTIME" ;;
  }

  set: detail {
    fields: [
      gldimud_loan,
      gldimasset,
      gldimtransaction_identifier,
      accountlabelkey,
      entrydescription,
      amount,
      allocation,
      line_no,
      form1099,
      currency,
      exch_rate_date,
      exch_rate_type_id,
      exchange_rate,
      trx_amount,
      accountno,
      locationid,
      departmentid,
      accountlabel,
      recordno,
      entry_date,
      recordkey,
      accountkey,
      accounttitle,
      locationname,
      departmentname,
      totalselected,
      totalpaid,
      parententry,
      lineitem,
      baselocation,
      allocationkey,
      trx_totalselected,
      trx_totalpaid,
      billable,
      billed,
      releasetopay,
      prentryoffsetaccountno,
      offsetglaccountno,
      offsetglaccounttitle,
      subtotal,
      basecurr,
      state,
      recordtype,
      partialexempt,
      form1099_type,
      form1099_box,
      trx_amountretained,
      trx_amountreleased,
      retainagepercentage,
      amountretained,
      customerid,
      customerdimkey,
      vendorid,
      vendordimkey,
      employeeid,
      employeedimkey,
      itemid,
      itemdimkey,
      classid,
      classdimkey,
      whenmodified_time,
      whencreated_time,
      createdby,
      modifiedby,
      serial_number,
      order_number,
      ud_esadmin_invoice_number,
      ud_estrack_workorder_number,
      asset_id,
      revrectemplate,
      revrecstartdate,
      revrecenddate,
      gloffset,
      deferrevenue,
      revrectemplatekey,
      deferredrevacctkey,
      deferredrevacctno,
      deferredrevaccttitle,
      vendoracctnokeyversion,
      locationkey,
      departmentkey,
      _es_update_timestamp_time,
      ddsreadtime_time
    ]
  }
}
