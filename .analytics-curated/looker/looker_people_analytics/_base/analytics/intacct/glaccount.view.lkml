view: glaccount {
  sql_table_name: "INTACCT"."GLACCOUNT" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }
  dimension: accounttype {
    type: string
    sql: ${TABLE}."ACCOUNTTYPE" ;;
  }
  dimension: alternativeaccount {
    type: string
    sql: ${TABLE}."ALTERNATIVEACCOUNT" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: categorykey {
    type: string
    sql: ${TABLE}."CATEGORYKEY" ;;
  }
  dimension: closetoacctkey {
    type: number
    sql: ${TABLE}."CLOSETOACCTKEY" ;;
  }
  dimension: closingtype {
    type: string
    sql: ${TABLE}."CLOSINGTYPE" ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
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
  dimension: mrccode {
    type: string
    sql: ${TABLE}."MRCCODE" ;;
  }
  dimension: normalbalance {
    type: string
    sql: ${TABLE}."NORMALBALANCE" ;;
  }
  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: requireclass {
    type: yesno
    sql: ${TABLE}."REQUIRECLASS" ;;
  }
  dimension: requirecustomer {
    type: yesno
    sql: ${TABLE}."REQUIRECUSTOMER" ;;
  }
  dimension: requiredept {
    type: yesno
    sql: ${TABLE}."REQUIREDEPT" ;;
  }
  dimension: requireemployee {
    type: yesno
    sql: ${TABLE}."REQUIREEMPLOYEE" ;;
  }
  dimension: requiregldimasset {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMASSET" ;;
  }
  dimension: requiregldimtransaction_identifier {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMTRANSACTION_IDENTIFIER" ;;
  }
  dimension: requiregldimud_loan {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMUD_LOAN" ;;
  }
  dimension: requireitem {
    type: yesno
    sql: ${TABLE}."REQUIREITEM" ;;
  }
  dimension: requireloc {
    type: yesno
    sql: ${TABLE}."REQUIRELOC" ;;
  }
  dimension: requirevendor {
    type: yesno
    sql: ${TABLE}."REQUIREVENDOR" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: subledgercontrolon {
    type: yesno
    sql: ${TABLE}."SUBLEDGERCONTROLON" ;;
  }
  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }
  dimension: taxcode {
    type: string
    sql: ${TABLE}."TAXCODE" ;;
  }
  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
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
    drill_fields: [megaentityname]
  }
}
