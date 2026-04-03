include: "/_base/people_analytics/greenhouse/v_fact_recommendation_by_stage.view.lkml"



view: +v_fact_recommendation_by_stage {
################ STAGE LOGIC ################


dimension: renamed_stage_name {
  type: string
  label: "Renamed Stage Name"
  sql:
    CASE
      WHEN ${stage_name} = 'Recruiter Phone Screen'
        AND ${department_name} = 'Engineering'
        AND (
          ${requisition_name} LIKE '%Software Engineer%'
          OR ${requisition_name} LIKE '%Engineering Manager%'
        )
      THEN 'Recruiter Phone Screen'

    WHEN ${stage_name} = 'Application Review'
    AND ${department_name} = 'Engineering'
    AND (
    ${requisition_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Application Review'

    WHEN (${stage_name} = 'Sent to Hiring Manager' OR ${stage_name} = 'Director Resume Review')
    AND ${department_name} = 'Engineering'
    AND (
    ${requisition_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Director Resume Review'

    WHEN ${stage_name} = 'Recruiter Review'
    AND ${department_name} = 'Engineering'
    AND (
    ${requisition_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Recruiter Review'

    WHEN ${stage_name} = 'Hiring Manager Interview(s)'
    AND ${department_name}= 'Engineering'
    AND ${requisition_name} LIKE '%Software Engineer%'
    THEN 'Light Tech Screen'

    WHEN ${stage_name} = 'Hiring Manager Interview(s)'
    AND ${department_name} = 'Engineering'
    AND ${requisition_name} LIKE '%Engineering Manager%'
    THEN 'Initial Interview w/ Director'

    WHEN ${stage_name} = 'Final Interview'
    AND ${interviewer_name} IN ('Theo Carpenter', 'Benjamin Solwitz', 'Charlyn Gee')
    THEN 'Leadership Interview w/ Director'


    WHEN ${stage_name} = 'Final Interview'
    THEN 'Tech Panel Interview'

    WHEN ${stage_name} = 'Offer Pending Approvals'
    AND ${department_name} = 'Engineering'
    AND (
    ${department_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Offer Pending Approvals'

    WHEN ${stage_name} = 'Verbal Offer'
    AND ${department_name} = 'Engineering'
    AND (
    ${requisition_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Verbal Offer'

     WHEN ${stage_name} = 'Offer Letter Sent'
    AND ${department_name} = 'Engineering'
    AND (
    ${requisition_name} LIKE '%Software Engineer%'
    OR ${requisition_name} LIKE '%Engineering Manager%'
    )
    THEN 'Offer Letter Sent'

    ELSE ${stage_name}
    END ;;
}

dimension: renamed_stage_order_priority {
  label: "Renamed Stage Order Priority"
  type: number
  sql:
    CASE
      WHEN ${renamed_stage_name} = 'Recruiter Review' THEN 1
      WHEN ${renamed_stage_name} = 'Recruiter Phone Screen' THEN 2
      WHEN ${renamed_stage_name} = 'Director Resume Review' THEN 3
      WHEN ${renamed_stage_name} IN ('Light Tech Screen', 'Initial Interview w/ Director') THEN 4
      WHEN ${renamed_stage_name} = 'Tech Panel Interview' THEN 5
      WHEN ${renamed_stage_name} = 'Leadership Interview w/ Director' THEN 6
      WHEN ${renamed_stage_name} = 'Offer Letter Sent' THEN 7
      ELSE NULL
    END ;;
}

  dimension: greenhouse_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id | url_encode }}#application" target="_blank">Greenhouse Link</a></font></u>;;
    sql: 'Link' ;;
  }

  measure: benchmark_pass_through_rate {
    type: number
    sql:
    MAX(
      CASE
        WHEN ${renamed_stage_name} = 'Recruiter Phone Screen' THEN 0.70
        WHEN ${renamed_stage_name} = 'Light Tech Screen' THEN 0.60
        WHEN ${renamed_stage_name} = 'Initial Interview w/ Director' THEN 0.60
        WHEN ${renamed_stage_name} = 'Tech Panel Interview' THEN 0.40
        WHEN ${renamed_stage_name} = 'Leadership Interview w/ Director' THEN 0.35
        ELSE NULL
      END
    ) ;;
    value_format_name: "percent_0"
    label: "Benchmark - Pass Through Rate"
    group_label: "Benchmarks"
  }

  measure: unique_candidate_ids {
    type: count_distinct
    sql: ${candidate_id};;
    description: "The number of unique candidates"
    drill_fields: [candidate_full_name, candidate_id, greenhouse_link]
  }


  dimension_group: application_history_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_date} ;;
  }

}
