view: disc_master {
  sql_table_name: "ANALYTICS"."PUBLIC"."DISC_MASTER" ;;

  dimension: applicant {
    type: string
    sql: ${TABLE}."APPLICANT" ;;
  }
  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension: basic_style {
    type: string
    sql: ${TABLE}."BASIC_STYLE" ;;
  }
  dimension: blend {
    type: string
    sql: ${TABLE}."BLEND" ;;
  }
  dimension: completed_date {
    type: string
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }
  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }
  dimension: disc_sent {
    type: date_raw
    sql: ${TABLE}."DISC_SENT_DATE" ;;
  }
  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  dimension: environment_style {
    type: string
    sql: ${TABLE}."ENVIRONMENT_STYLE" ;;
  }
  dimension: main_strength {
    type: string
    sql: ${TABLE}."MAIN_STRENGTH" ;;
  }
  dimension: report_link {
    type: string
    sql: ${TABLE}."REPORT_LINK" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: updated {
    type: date_raw
    sql: ${TABLE}."UPDATED_DATE" ;;
  }
  measure: count {
    type: count
  }
}
