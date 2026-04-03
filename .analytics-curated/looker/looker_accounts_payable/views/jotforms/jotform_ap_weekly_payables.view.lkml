view: jotform_ap_weekly_payables {
  sql_table_name: "JOTFORM"."AP_WEEKLY_PAYABLES" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension_group: approved_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."APPROVED_TIMESTAMP" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_AT" ;;
  }
  dimension_group: dateof {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATEOF" ;;
  }
  dimension_group: dateof7 {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATEOF7" ;;
  }
  dimension: fileupload {
    type: string
    sql: ${TABLE}."FILEUPLOAD" ;;
  }
  dimension: flag {
    type: number
    sql: ${TABLE}."FLAG" ;;
  }
  dimension: form_id {
    type: number
    sql: ${TABLE}."FORM_ID" ;;
  }
  dimension: formid {
    type: string
    sql: ${TABLE}."FORMID" ;;
  }
  dimension: ip {
    type: string
    sql: ${TABLE}."IP" ;;
  }
  dimension: new {
    type: number
    sql: ${TABLE}."NEW" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: paymenttype {
    type: string
    sql: ${TABLE}."PAYMENTTYPE" ;;
  }
  dimension: reasonfor {
    type: string
    sql: ${TABLE}."REASONFOR" ;;
  }
  dimension: requestby_first {
    type: string
    sql: ${TABLE}."REQUESTBY_FIRST" ;;
  }
  dimension: requestby_last {
    type: string
    sql: ${TABLE}."REQUESTBY_LAST" ;;
  }
  dimension: requesttype {
    type: string
    sql: ${TABLE}."REQUESTTYPE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }
  dimension: totalpayment30 {
    type: string
    sql: ${TABLE}."TOTALPAYMENT30" ;;
  }
  dimension: totalpayment31 {
    type: string
    sql: ${TABLE}."TOTALPAYMENT31" ;;
  }
  dimension: typea22 {
    type: string
    sql: ${TABLE}."TYPEA22" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPDATED_AT" ;;
  }
  dimension: workflowstatus {
    type: string
    sql: ${TABLE}."WORKFLOWSTATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [id]
  }
}
