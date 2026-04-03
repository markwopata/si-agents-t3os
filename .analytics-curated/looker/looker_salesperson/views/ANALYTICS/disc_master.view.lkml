view: disc_master {
  derived_table: {
    sql:
     select
    *
    from analytics.public.DISC_MASTER dm
    where status = 'completed'
    ;;
  }

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

  dimension: email_address {
    primary_key: yes
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

  dimension: link_to_disc_pdf {
    type: string
    html: <font color="blue "><u><a href ="https://www.discoveryreport.com/v/{{disc_code._value}}"target="_blank">{{environment_style._value}}</a></font></u> ;;
    sql: ${disc_code} ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }

  dimension: completed_disc {
    type: yesno
    sql: ${status} = 'completed' ;;
  }

  dimension: pending_disc {
    type: yesno
    sql: ${status} = 'pending_completion' OR ${status} is NULL ;;
  }
}
