view: docebo_enrollments {
  # # You can specify the table name if it's different from the view name:
  sql_table_name:"ANALYTICS"."DOCEBO"."ENROLLMENTS";;
  #
  # # Define your dimensions and measures here, like this:
  dimension: unique_record {
    type: string
    primary_key: yes
    sql:  CONCAT(CONCAT(${course_uid}, '_'), ${user_id}) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID";;
  }

  dimension: username {
    type:  number
    sql:  ${TABLE}."USERNAME" ;;
  }

  dimension: course_id {
    type: number
    sql:  ${TABLE}."COURSE_ID" ;;
  }

  dimension: course_uid {
    type:  string
    sql:  ${TABLE}."COURSE_UID" ;;

  }
  dimension: course_code {
    type: string
    sql:  ${TABLE}."COURSE_CODE" ;;
  }

  dimension: course_name {
    type:  string
    sql:  ${TABLE}."COURSE_NAME" ;;
  }

  dimension: course_type {
    type: string
    sql:  ${TABLE}."COURSE_TYPE" ;;
  }

  dimension: course_start_date {
    type:  date
    sql:  ${TABLE}."COURSE_BEGIN_DATE";;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: course_end_date {
    type:  date
    sql:  ${TABLE}."COURSE_END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: level {
    type: string
    sql:  ${TABLE}."ENROLLMENT_LEVEL" ;;
  }

  dimension: status {
    type: string
    sql:  ${TABLE}."ENROLLMENT_STATUS" ;;
  }

  dimension: enrolled_by_id {
    type: number
    sql:  ${TABLE}."ENROLLMENT_CREATED_BY" ;;
  }


  dimension: enrollment_score {
    type:  number
    sql:  ${TABLE}."ENROLLMENT_SCORE" ;;
  }

  dimension: self_enrolled {
    type:  yesno
    sql:  ${enrolled_by_id} = ${user_id} ;;
  }

  dimension: completion_date {
    type:  date
    sql:  ${TABLE}."ENROLLMENT_COMPLETION_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }
}
