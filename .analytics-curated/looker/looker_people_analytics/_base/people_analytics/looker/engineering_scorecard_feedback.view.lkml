view: engineering_scorecard_feedback {
  sql_table_name: "LOOKER"."ENGINEERING_SCORECARD_FEEDBACK" ;;

  dimension: abilitiy_to_communicate {
    type: number
    sql: ${TABLE}."ABILITIY_TO_COMMUNICATE" ;;
  }
  dimension: ability_to_win {
    type: number
    sql: ${TABLE}."ABILITY_TO_WIN" ;;
  }
  dimension: adaptability {
    type: number
    sql: ${TABLE}."ADAPTABILITY" ;;
  }
  dimension: answer {
    type: string
    sql: ${TABLE}."ANSWER" ;;
  }
  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension: aws {
    type: yesno
    sql: ${TABLE}."AWS" ;;
  }
  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: disabled {
    type: yesno
    sql: ${TABLE}."DISABLED" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: javascript {
    type: yesno
    sql: ${TABLE}."JAVASCRIPT" ;;
  }
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }
  dimension: kafka {
    type: yesno
    sql: ${TABLE}."KAFKA" ;;
  }
  dimension: kubernetes {
    type: yesno
    sql: ${TABLE}."KUBERNETES" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: node {
    type: yesno
    sql: ${TABLE}."NODE" ;;
  }
  dimension: overall_recommendation {
    type: string
    sql: ${TABLE}."OVERALL_RECOMMENDATION" ;;
  }
  dimension: postgresql {
    type: yesno
    sql: ${TABLE}."POSTGRESQL" ;;
  }
  dimension: python {
    type: yesno
    sql: ${TABLE}."PYTHON" ;;
  }
  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }
  dimension: react {
    type: yesno
    sql: ${TABLE}."REACT" ;;
  }
  dimension: score {
    type: number
    sql: ${TABLE}."SCORE" ;;
  }
  dimension: scorecard_id {
    type: number
    sql: ${TABLE}."SCORECARD_ID" ;;
  }
  dimension: similar_company_experience {
    type: number
    sql: ${TABLE}."SIMILAR_COMPANY_EXPERIENCE" ;;
  }
  dimension: submitted_by_user_id {
    type: number
    sql: ${TABLE}."SUBMITTED_BY_USER_ID" ;;
  }
  dimension: tech_stack_depth {
    type: number
    sql: ${TABLE}."TECH_STACK_DEPTH" ;;
  }
  dimension: typescript {
    type: yesno
    sql: ${TABLE}."TYPESCRIPT" ;;
  }
  dimension: years_of_applicable_experience {
    type: number
    sql: ${TABLE}."YEARS_OF_APPLICABLE_EXPERIENCE" ;;
  }
  measure: count {
    type: count
    drill_fields: [job_name, last_name, first_name]
  }
}
