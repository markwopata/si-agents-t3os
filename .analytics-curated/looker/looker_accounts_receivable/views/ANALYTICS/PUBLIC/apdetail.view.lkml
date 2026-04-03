view: apdetail {
  sql_table_name: "PUBLIC"."APDETAIL"
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

  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }

  dimension: accountno {
    type: number
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  dimension: accounttitle {
    type: string
    sql: ${TABLE}."ACCOUNTTITLE" ;;
  }

  dimension: amount {
    type: string
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: ap_detail_id {
    type: number
    sql: ${TABLE}."AP_DETAIL_ID" ;;
  }

  dimension: billable {
    type: string
    sql: ${TABLE}."BILLABLE" ;;
  }

  dimension: billed {
    type: string
    sql: ${TABLE}."BILLED" ;;
  }

  dimension: createdby {
    type: string
    sql: ${TABLE}."CREATEDBY" ;;
  }

  dimension: ddsreadtime {
    type: string
    sql: ${TABLE}."DDSREADTIME" ;;
  }

  dimension: departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }

  dimension: departmentkey {
    type: string
    sql: ${TABLE}."DEPARTMENTKEY" ;;
  }

  dimension: departmentname {
    type: string
    sql: ${TABLE}."DEPARTMENTNAME" ;;
  }

  dimension: entry_date {
    type: string
    sql: ${TABLE}."ENTRY_DATE" ;;
  }

  dimension: entrydescription {
    type: string
    sql: ${TABLE}."ENTRYDESCRIPTION" ;;
  }

  dimension: gloffset {
    type: string
    sql: ${TABLE}."GLOFFSET" ;;
  }

  dimension: line_no {
    type: number
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
    type: string
    sql: ${TABLE}."LOCATIONKEY" ;;
  }

  dimension: locationname {
    type: string
    sql: ${TABLE}."LOCATIONNAME" ;;
  }

  dimension: modifiedby {
    type: string
    sql: ${TABLE}."MODIFIEDBY" ;;
  }

  dimension: recordkey {
    type: string
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
    type: string
    sql: ${TABLE}."RELEASETOPAY" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: totalpaid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTALPAID" ;;
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

  dimension: vendordimkey {
    type: string
    sql: ${TABLE}."VENDORDIMKEY" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: whencreated {
    type: string
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: whenmodified {
    type: string
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  measure: count {
    type: count
    drill_fields: [locationname, departmentname]
  }
}
