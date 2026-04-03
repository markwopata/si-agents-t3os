include: "/_base/people_analytics/greenhouse/v_dim_candidate.view.lkml"


view: +v_dim_candidate {
  label: "Dim Candidate"

  ################ DIMENSIONS ################

  dimension: candidate_key {
    primary_key: yes
    value_format_name: id
    description: "Candidate Key used to join to the Fact Application Requisition Offer table"
  }

  dimension: candidate_id {
    value_format_name: id
    description: "ID used to identify a candidate"
  }

  dimension: candidate_full_name {
    type: string
    sql: CONCAT(${candidate_first_name},' ',${candidate_last_name}) ;;
  }

  dimension: greenhouse_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id | url_encode }}#application" target="_blank">Greenhouse Link</a></font></u>;;
    sql: 'Link' ;;
  }

  dimension: disc_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://www.discoveryreport.com/v/{{ v_dim_candidate.candidate_custom_disc_code | url_encode }}" target="_blank">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }

  dimension: candidate_custom_scorecard_score {
    description: "Scorecard score assigned by recruiter"
  }

  ################ DATES ################

  dimension_group: candidate_custom_disc_sent_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${candidate_custom_disc_sent} ;;
  }

  ################ MEASURES ################

  measure: unique_candidate_ids {
    type: count_distinct
    sql: ${candidate_id};;
    description: "The number of unique candidates"
    drill_fields: [candidate_full_name, candidate_id, greenhouse_link]
  }
}
