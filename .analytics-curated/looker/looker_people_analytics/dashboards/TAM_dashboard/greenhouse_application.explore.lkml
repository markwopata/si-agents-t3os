include: "/_standard/people_analytics/greenhouse/tam_algorithm.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_date.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_requisition_dim_employee.layer.lkml"
include: "/_standard/analytics/public/disc_master.layer.lkml"


view: +v_fact_application_history {
  dimension: disc_dimensions_hit {
    label: "DISC Calculator Dimensions"
    type: number
    sql: CASE WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 4
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 3
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 3
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 3
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 3
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 2
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) <= 40 THEN 1
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) <= 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 1
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) >= 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) < 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 1
    WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager')
    AND SPLIT_PART(${disc_master.environment_style},' ',1) < 65 AND SPLIT_PART(${disc_master.environment_style},' ',2) >= 60
    AND SPLIT_PART(${disc_master.environment_style},' ',3) > 30 AND SPLIT_PART(${disc_master.environment_style},' ',4) > 40 THEN 1
    ELSE 0 END;;
  }

  dimension: disc_dimensions_points {
    label: "DISC Calculator Points"
    type: number
    sql: CASE WHEN ${disc_dimensions_hit} = 4 THEN 10
    WHEN ${disc_dimensions_hit} = 3 THEN 8
    WHEN ${disc_dimensions_hit} = 2 THEN 6
    WHEN ${disc_dimensions_hit} = 1 THEN 3
    ELSE 0 END;;
  }

  dimension: days_in_stage_cf {
    type: number
    sql: ${application_history_days_in_stage};;
    html:
    {% if  sla_percent_passed._value < 0.8 %}
    <p style="color: black; background-color: lightgreen;">{{ value }}</p>
    {% elsif sla_percent_passed._value < 1.0001 %}
    <p style="color: black; background-color: yellow;">{{ value }}</p>
    {% elsif sla_percent_passed._value > 1.0001 %}
    <p style="color: black; background-color: red;">{{ value }}</p>
    {% else %}
    <p style="color: black; background-color: white;">{{ value }}</p>
    {% endif %}
    ;;
  }

  dimension: sla_percent_passed {
    type: number
    sql: ${application_history_days_in_stage} / ${v_dim_stage.stage_sla};;
  }

  measure: average_days_in_stage {
    type: average
    sql: ${application_history_days_in_stage};;
    description: "Average days a candidate is in a stage"
    drill_fields: [v_dim_candidate.candidate_full_name,
      v_dim_candidate.greenhouse_link,
      v_dim_stage.stage_name,
      application_history_date,
      application_history_prior_stage_date_date,
      application_history_days_in_stage]
  }


}

view: +v_dim_application {

  measure: unique_application_ids {
    type: count_distinct
    sql: ${application_id} ;;
    description: "Total number of distinct applications"
    drill_fields: [v_dim_office.office_region_name,
      application_id,
      v_dim_candidate.candidate_full_name,
      tam_disc.environment_style,
      v_dim_candidate.disc_link,
      tam_algorithm_application.total_score]
  }
}

view: +v_dim_candidate {

  measure: unique_candidate_ids {
    type: count_distinct
    sql: ${candidate_id} ;;
    drill_fields: [candidate_drills*]
  }

  set: candidate_drills {
    fields: [v_dim_application.application_id,
      v_dim_stage.stage_name,
      candidate_full_name,
      v_dim_requisition.requisition_id,
      v_dim_requisition.requisition_name,
      v_bridge_dim_office.bridge_dim_office_name_full_path,
      greenhouse_link,
      tam_disc.environment_style,
      disc_link,
      tam_algorithm.total_score,
      tam_disc.disc_points]
  }
}

view: +v_dim_stage {

  dimension: stage_sla {
    label: "Stage SLA"
    type: number
    sql:  CASE WHEN ${stage_name} = 'Application Review' THEN 3
    WHEN ${stage_name} = 'Recruiter Review' THEN 1
    WHEN ${stage_name} = 'Hiring Manager Initial Review' THEN 3
    WHEN ${stage_name} = 'Recruiter Phone Screen' THEN 5
    WHEN ${stage_name} = 'DISC' THEN 2
    WHEN ${stage_name} = 'Sent to Hiring Manager' THEN 3
    WHEN ${stage_name} = 'Hiring Manager Interview(s)' THEN 7
    WHEN ${stage_name} = 'Final Interview' THEN 5
    WHEN ${stage_name} = 'Offer Pending Approvals' THEN 1
    WHEN ${stage_name} = 'Verbal Offer' THEN 1
    WHEN ${stage_name} = 'Offer Letter Sent' THEN 1
    ELSE null END;;
  }
}

explore:  v_fact_application_history {
  label: "Greenhouse Application History"

  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_application_key} = ${v_dim_application.application_key} ;;
  }

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_dim_requisition.requisition_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_department {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_department_key} = ${v_dim_department.department_key} ;;
  }

  join: v_dim_date {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_date} = ${v_dim_date.date} ;;
  }

  join:  v_bridge_dim_office {
    type: inner
    relationship: one_to_one
    sql_on: ${v_dim_requisition.requisition_key}= ${v_bridge_dim_office.bridge_dim_office_requisition_key} ;;
  }

  join:  v_dim_office {
    type: inner
    relationship: one_to_many
    sql_on: ${v_dim_office.office_key} = ${v_bridge_dim_office.bridge_dim_office_key};;
  }

  join: v_bridge_dim_requisition_dim_employee {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_bridge_dim_requisition_dim_employee.bridge_dim_requisition_dim_employee_requisition_key} ;;
  }

  join: tam_algorithm_application {
    view_label: "TAM Algorithm by Application"
    from: tam_algorithm
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_id} = ${tam_algorithm_application.application_id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_candidate.candidate_custom_disc_code} = ${disc_master.disc_code} ;;
  }

}
