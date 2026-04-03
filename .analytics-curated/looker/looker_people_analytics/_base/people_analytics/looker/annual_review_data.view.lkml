view: annual_review_data {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."ANNUAL_REVIEW_DATA" ;;

  dimension: days_to_review {
    type: number
    sql: ${TABLE}."DAYS_TO_REVIEW" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: date_hired {
    type: date_raw
    sql: ${TABLE}."DATE_HIRED" ;;
    hidden: yes
  }
  dimension: reason_code {
    type: string
    sql: ${TABLE}."REASON_CODE" ;;
  }
  dimension: record_id {
    type: string
    sql: ${TABLE}."RECORD_ID" ;;
  }
  dimension: review_actual {
    type: date_raw
    sql: ${TABLE}."REVIEW_ACTUAL_DATE" ;;
    hidden: yes
  }
  dimension: review_target {
    type: date_raw
    sql: ${TABLE}."REVIEW_TARGET_DATE" ;;
    hidden: yes
  }
  dimension: review_timing_id {
    type: number
    sql: ${TABLE}."REVIEW_TIMING_ID" ;;
  }
  dimension: review_timing_name {
    type: string
    sql: ${TABLE}."REVIEW_TIMING_NAME" ;;
  }
  dimension: region {
    type: string
    sql:  ${TABLE}."REGION" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: sub_department {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: direct_manager_employee_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }
  dimension: max_review_count {
    type: number
    sql: ${TABLE}."MAX_REVIEW_CT" ;;
  }
  dimension: no_review_ind {
    type: yesno
    sql: ${TABLE}."NO_REVIEW_IND" ;;
  }
  measure: count {
    type: count
    drill_fields: [name]
  }
}
