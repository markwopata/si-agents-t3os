view: disc_master_historic {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."DISC_MASTER_HISTORIC" ;;

  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }
  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  dimension: disc_sent {
    type: date_raw
    sql: ${TABLE}."DISC_SENT_DATE" ;;
  }
  dimension: completed {
    type: date_raw
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }
  dimension: environment_style {
    type: string
    sql: ${TABLE}."ENVIRONMENT_STYLE" ;;
  }
  dimension: basic_style {
    type: string
    sql: ${TABLE}."BASIC_STYLE" ;;
  }
  dimension: blend {
    type: string
    sql: ${TABLE}."BLEND" ;;
  }
  dimension: main_strength {
    type: string
    sql: ${TABLE}."MAIN_STRENGTH" ;;
  }
  dimension: applicant {
    type: string
    sql: ${TABLE}."APPLICANT" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: updated {
    type: date_raw
    sql: ${TABLE}."UPDATED_DATE" ;;
  }
}
