
include: "/_standard/people_analytics/looker/engineering_scorecard_feedback.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"


explore: engineering_scorecard_feedback{
  label: "Engineering Scorecard Data"


  join: v_dim_candidate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${engineering_scorecard_feedback.candidate_id}::varchar = ${v_dim_candidate.candidate_id}::varchar;;
  }

  join: v_dim_application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${engineering_scorecard_feedback.application_id}::varchar = ${v_dim_application.application_id}::varchar;;
  }

}
