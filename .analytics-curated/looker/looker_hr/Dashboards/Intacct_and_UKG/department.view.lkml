view: department {
  sql_table_name: "INTACCT"."DEPARTMENT" ;;
  drill_fields: [departmentid]

  dimension: departmentid {
    primary_key: yes
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension: custtitle {
    type: string
    sql: ${TABLE}."CUSTTITLE" ;;
  }
  dimension_group: date_no_longer_new_market {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_NO_LONGER_NEW_MARKET" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: parentkey {
    type: number
    sql: ${TABLE}."PARENTKEY" ;;
  }
  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: state_id {
    type: string
    sql: ${TABLE}."STATE_ID" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: supervisorkey {
    type: number
    sql: ${TABLE}."SUPERVISORKEY" ;;
  }
  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }
  dimension: ud_associated_deliver_to_contact {
    type: string
    sql: ${TABLE}."UD_ASSOCIATED_DELIVER_TO_CONTACT" ;;
  }
  dimension: ud_ultimate_parent_location_id {
    type: string
    sql: ${TABLE}."UD_ULTIMATE_PARENT_LOCATION_ID" ;;
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
    drill_fields: [departmentid]
  }
}
