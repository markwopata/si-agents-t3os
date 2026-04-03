view: disc_master {
  sql_table_name: "PUBLIC"."DISC_MASTER"
    ;;

  dimension: applicant {
    type: string
    sql: ${TABLE}."APPLICANT" ;;
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

  dimension: disc_sent_date {
    type: string
    sql: ${TABLE}."DISC_SENT_DATE" ;;
  }

  dimension: disc_website_link {
    type: string
    sql: ${TABLE}."DISC_WEBSITE_LINK" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: environment_style {
    type: string
    sql: ${TABLE}."ENVIRONMENT_STYLE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: main_strength {
    type: string
    sql: ${TABLE}."MAIN_STRENGTH" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }
}
