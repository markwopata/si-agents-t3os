view: employee_disc_codes {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."EMPLOYEE_DISC_CODES" ;;

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_hired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension_group: date_terminated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }
  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }
  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }
  dimension: disc_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://www.discoveryreport.com/v/{{ disc_code | url_encode }}" target="_blank">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
