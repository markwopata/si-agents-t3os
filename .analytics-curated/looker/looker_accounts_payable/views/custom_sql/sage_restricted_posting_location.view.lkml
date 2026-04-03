view: sage_restricted_posting_location {
  derived_table: {
    sql: SELECT *
FROM "ANALYTICS"."INTACCT"."DEPARTMENT"

WHERE CAST(DEPARTMENTID AS VARCHAR) IN
      ('15968', '15978', 'R2', '24564', 'PNPR3', 'test', '42308', '42166', '15981', '15983', 'INTERCOMPANY', 'COMPANY3',
       'PNP', '24562', 'CUSTSR', 'NEWMRKT', 'FLEET', 'CORP3', 'CORP4', 'CORP9', 'CORP34', 'CORP23', 'CORP7', 'CORP21',
       'CORP19', 'CORP17', 'CORP13', 'CORP33', 'CORP14', 'CORP12', 'CORP8', 'CORP20', 'CORP15', 'CORP16', 'CORP6',
       'CORP5', 'CORP24', 'CORP29', 'CORP32', 'CORP35', 'CORP30', 'CORP28', 'CORP11', 'CORP31', 'CORP22', 'CORP18',
       'COMPANY', '1000093', 'CORP26', '1000094', 'CORP27', 'CORP10', 'DEPARTMENTS', 'REGIONS', 'FINAN', 'COMPANY2',
       'PNPR1', 'CORP2', '24565', 'NEW', '15979', '24563', '15974', '24561', 'TECH', 'R1', 'R7', 'R4', 'R5', 'R6', 'R3',
       'EXECUT', 'TECH2', '32198', 'ITL', 'ITLR3', '55924', 'LEGAL', 'SERVICE');;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: departmentid {
    type: string
    sql: ${TABLE}."DEPARTMENTID" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: custtitle {
    type: string
    sql: ${TABLE}."CUSTTITLE" ;;
  }

  dimension: parentkey {
    type: number
    sql: ${TABLE}."PARENTKEY" ;;
  }

  dimension: supervisorkey {
    type: number
    sql: ${TABLE}."SUPERVISORKEY" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
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

  dimension: ud_ultimate_parent_location_id {
    type: string
    sql: ${TABLE}."UD_ULTIMATE_PARENT_LOCATION_ID" ;;
  }

  dimension: ud_associated_deliver_to_contact {
    type: string
    sql: ${TABLE}."UD_ASSOCIATED_DELIVER_TO_CONTACT" ;;
  }

  dimension: date_no_longer_new_market {
    type: date
    sql: ${TABLE}."DATE_NO_LONGER_NEW_MARKET" ;;
  }

  dimension: state_id {
    type: string
    sql: ${TABLE}."STATE_ID" ;;
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
      recordno,
      departmentid,
      title,
      custtitle,
      parentkey,
      supervisorkey,
      status,
      whenmodified_time,
      whencreated_time,
      createdby,
      modifiedby,
      ud_ultimate_parent_location_id,
      ud_associated_deliver_to_contact,
      date_no_longer_new_market,
      state_id,
      _es_update_timestamp_time,
      ddsreadtime_time
    ]
  }
}
