view: DIM_EMPLOYEE {
  sql_table_name: "BRANCH_EARNINGS"."DIM_EMPLOYEE"
    ;;

  dimension: PK_EMPLOYEE_USER_ID {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK_EMPLOYEE_USER_ID" ;;
  }

  dimension: USER_ID {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: EMPLOYEE_ID {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }


  dimension: USERNAME {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: EMPLOYEE_NAME {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: TIMEZONE {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: EMPLOYEE_TYPE {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: EMPLOYEE_STATUS {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: NBR_YEARS_EMPLOYED {
    type: string
    sql: ${TABLE}."NBR_YEARS_EMPLOYED" ;;
  }

  dimension: DATE_HIRED {
    type: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: EMPLOYEE_TITLE {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: LOCATION {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: DISC_ENVIRONMENT_STYLE {
    type: string
    hidden: yes
    sql: ${TABLE}."DISC_ENVIRONMENT_STYLE" ;;
  }

  dimension: DISC_BASIC_STYLE {
    type: string
    hidden: yes
    sql: ${TABLE}."DISC_BASIC_STYLE" ;;
  }

  dimension: DISC_ENVIRONMENT_D {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_ENVIRONMENT_D" ;;
  }

  dimension: DISC_ENVIRONMENT_I {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_ENVIRONMENT_I" ;;
  }

  dimension: DISC_ENVIRONMENT_S {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_ENVIRONMENT_S" ;;
  }

  dimension: DISC_ENVIRONMENT_C {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_ENVIRONMENT_C" ;;
  }

  dimension: DISC_BASIC_D {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_BASIC_D" ;;
  }

  dimension: DISC_BASIC_I {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_BASIC_I" ;;
  }

  dimension: DISC_BASIC_S {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_BASIC_S" ;;
  }

  dimension: DISC_BASIC_C {
    type: number
    hidden: yes
    sql: ${TABLE}."DISC_BASIC_C" ;;
  }

  dimension: DISC_BLEND {
    type: string
    hidden: yes
    sql: ${TABLE}."DISC_BLEND" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF EMPLOYEES"
    drill_fields: [USER_ID, USERNAME, EMPLOYEE_ID, EMPLOYEE_NAME, EMPLOYEE_STATUS, EMPLOYEE_TITLE, EMPLOYEE_TYPE, LOCATION, DATE_HIRED, DISC_BLEND]
  }
}
