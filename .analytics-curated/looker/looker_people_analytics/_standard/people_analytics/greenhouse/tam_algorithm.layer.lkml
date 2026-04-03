include: "/_base/people_analytics/greenhouse/tam_algorithm.view.lkml"

view: +tam_algorithm {

  ############### DIMENSIONS ###############

  dimension: application_id {
    value_format_name: id
    description: "ID used to identify an application"
  }

  dimension: candidate_id {
    value_format_name: id
    description: "ID used to identify a candidate"
  }

  dimension: job_id {
    value_format_name: id
    description: "ID used to identify a job"
  }

  dimension: total_score {
    value_format: "0"
  }

}
