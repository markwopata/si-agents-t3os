include: "/_base/people_analytics/greenhouse/v_dim_application.view.lkml"


view: +v_dim_application {
  label: "Dim Application"

  ################ DIMENSIONS ################

  dimension: application_key {
    value_format_name: id
    description: "Application Key used to join to the Bridge Dim Office table"
  }

  dimension: application_id {
    value_format_name: id
    description: "ID used to identify an application"
  }


  ################ MEASURES ################

  measure: unique_application_ids {
    type: count_distinct
    sql: ${application_id} ;;
    description: "Total number of distinct applications"
  }
}
