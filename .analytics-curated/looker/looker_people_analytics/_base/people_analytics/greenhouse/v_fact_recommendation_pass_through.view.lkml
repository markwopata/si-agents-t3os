view: recommendation_pass_through {
  sql_table_name: PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_RECOMMENDATION_PASS_THROUGH ;;

  dimension: candidate_full_name {
    type: string
    sql: ${TABLE}.candidate_full_name ;;
  }

  dimension: candidate_key {
    type: string
    sql: ${TABLE}.candidate_key ;;
    hidden: yes
  }

  dimension: candidate_id {
    type: string
    sql: ${TABLE}.candidate_id ;;
    hidden: yes
  }

  dimension: stage_name {
    type: string
    sql: ${TABLE}.stage_name ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}.application_id ;;
  }

  dimension: application_key {
    type: string
    sql: ${TABLE}.application_key ;;
    hidden: yes
  }

  dimension: application_history_date {
    type: date
    sql: ${TABLE}.application_history_date ;;
  }

  dimension: application_history_days_in_stage {
    type: number
    sql: ${TABLE}.application_history_days_in_stage ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: requisition_name {
    type: string
    sql: ${TABLE}.requisition_name ;;
  }

  dimension: requisition_id {
    type: string
    sql: ${TABLE}.requisition_id ;;
    hidden: yes
  }

  dimension: application_source_name {
    type: string
    sql: ${TABLE}.application_source_name ;;
  }

  dimension: application_rejection_reason {
    type: string
    sql: ${TABLE}.application_rejection_reason ;;
  }

  dimension: greenhouse_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id | url_encode }}#application" target="_blank">Greenhouse Link</a></font></u>;;
    sql: 'Link' ;;
  }
}
