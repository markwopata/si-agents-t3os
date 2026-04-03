include: "/_base/people_analytics/greenhouse/v_dim_stage.view.lkml"


view: +v_dim_stage {
  label: "Dim Stage"

  ################ DIMENSIONS ################

  dimension: stage_key {
    value_format_name: id
    description: "Stage Key used to join Fact Application Requisition Offer table"
  }

  dimension: stage_job_id {
    value_format_name: id
    description: "Stage ID used to pair to certain Requsition or Job"
  }

  dimension: stage_id {
    value_format_name: id
    description: "The ID used to identify a specific stage"
  }

  dimension: stage_order_priority {
    type: number
    sql: CASE WHEN ${stage_name} = 'Application Review' THEN 0
    WHEN ${stage_name} = 'Recruiter Review' THEN 1
    WHEN ${stage_name} = 'Hiring Manager Initial Review' THEN 2
    WHEN ${stage_name} = 'Recruiter Phone Screen' THEN 3
    WHEN ${stage_name} = 'Personality Insights Assessment' THEN 4
    WHEN ${stage_name} = 'Sent to Hiring Manager' THEN 5
    WHEN ${stage_name} = 'Hiring Manager Interview(s)' THEN 6
    WHEN ${stage_name} = 'Final Interview' THEN 7
    WHEN ${stage_name} = 'Offer Pending Approvals' THEN 8
    WHEN ${stage_name} = 'Verbal Offer' THEN 9
    WHEN ${stage_name} = 'Offer Letter Sent' THEN 10
    ELSE null END;;
  }
}
