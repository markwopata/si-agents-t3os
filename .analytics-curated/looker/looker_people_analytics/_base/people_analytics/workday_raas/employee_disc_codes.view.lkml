view: employee_disc_codes {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."EMPLOYEE_DISC_CODES" ;;

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: fivetran_synced {
    type: date_raw
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }
  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: date_hired {
    type: date_raw
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }
  dimension: fivetran_deleted {
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension: date_terminated {
    type: date_raw
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }
}
