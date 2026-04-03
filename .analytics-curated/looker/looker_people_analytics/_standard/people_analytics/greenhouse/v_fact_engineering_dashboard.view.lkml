view: v_fact_engineering_dashboard {
  sql_table_name: people_analytics.greenhouse.v_fact_recommendation_by_stage ;;
  label: "Fact Engineering Scorecard"

  # === Base Identifiers ===
  dimension: interview_id {
    value_format_name: id
    description: "The ID used to identify a specific interview."
    sql: ${TABLE}.interview_id ;;
  }

  dimension: application_key {
    value_format_name: id
    description: "The Key used to join the Application table. Also is the application ID"
    sql: ${TABLE}.application_key ;;
  }

  dimension: requisition_key {
    value_format_name: id
    description: "The Key used to join the Requisition table."
    sql: ${TABLE}.requisition_key ;;
  }

  dimension: stage_key {
    value_format_name: id
    description: "The Key used to join the Stage table."
    sql: ${TABLE}.stage_key ;;
  }

  dimension: offer_key {
    value_format_name: id
    description: "The Key used to join the Offer table."
    sql: ${TABLE}.offer_key ;;
  }

  dimension: candidate_key {
    value_format_name: id
    description: "The Key used to join Stage table"
    sql: ${TABLE}.candidate_key ;;
  }

  dimension: department_key {
    value_format_name: id
    description: "The Key used to join the Department table."
    sql: ${TABLE}.department_key ;;
  }

  dimension: scorecard_id {
    value_format_name: id
    description: "The ID used to identify a unique scorecard."
    sql: ${TABLE}.scorecard_id ;;
  }

  dimension: scorecard_recommendation {
    type: string
    sql: ${TABLE}.scorecard_recommendation ;;
  }

  dimension: interview_status {
    type: string
    sql: ${TABLE}.interview_status ;;
  }

  dimension: unsubmitted_scorecard_link {
    type: string
    html: <font color="blue "><u><a href = "https://app.greenhouse.io/guides/{{ interview_id | url_encode }}/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id }}#scorecard" target="_blank">Scorecard Link</a></font></u>;;
    sql: 'Link' ;;
  }

  # === Time Dimensions ===
  dimension: start_of_interview {
    type: date
    sql: ${TABLE}.start_of_interview ;;
  }

  dimension: end_of_interview {
    type: date
    sql: ${TABLE}.end_of_interview ;;
  }

  dimension: application_applied {
    type: date
    sql: ${TABLE}.application_applied ;;
  }

  dimension: offer_resolved {
    type: date
    sql: ${TABLE}.offer_resolved ;;
  }

  dimension: offer_sent {
    type: date
    sql: ${TABLE}.offer_sent ;;
  }

  dimension: offer_created {
    type: date
    sql: ${TABLE}.offer_created ;;
  }

  dimension: offer_starts_at {
    type: date
    sql: ${TABLE}.offer_starts_at ;;
  }

  dimension: job_closed {
    type: date
    sql: ${TABLE}.job_closed ;;
  }

  dimension: job_created {
    type: date
    sql: ${TABLE}.job_created ;;
  }

  # === Time Groups ===
  dimension_group: start_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${start_of_interview} ;;
  }

  dimension_group: end_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${end_of_interview} ;;
  }

  dimension_group: application_applied {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_applied} ;;
  }

  dimension_group: offer_resolved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_resolved} ;;
  }

  dimension_group: offer_sent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_sent} ;;
  }

  dimension_group: offer_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_created} ;;
  }

  dimension_group: offer_starts_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_starts_at} ;;
  }

  dimension_group: job_closed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_closed} ;;
  }

  dimension_group: job_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_created} ;;
  }

  dimension: interviewer_name {
    type: string
    sql: ${TABLE}.interviewer_name ;;
  }


  ################ MEASURES ################

  set: interview_drill_fields {
    fields: [interview_id,
      interview_status,
      v_dim_candidate.candidate_full_name,
      scorecard_recommendation,
      unsubmitted_scorecard_link,
      start_of_interview_date]
  }

  measure: total_interviews {
    type: count_distinct
    sql: ${interview_id} ;;
  }

  measure: unique_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct interviews."
  }

  measure: completed_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "complete"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  measure: scheduled_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "scheduled"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of scheduled interviews."
  }

  measure: awaiting_feedback_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "awaiting_feedback"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of interviews awaiting feedback."
  }

  measure: to_be_scheduled_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "to_be_scheduled"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of interviews to be scheduled."
  }

  measure: skipped_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "skipped"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of skipped interviews."
  }

  ################ STAGE LOGIC ################
  dimension: renamed_stage_name {
    type: string
    label: "Renamed Stage Name"
    sql:
    CASE
      WHEN ${v_dim_stage.stage_name} = 'Recruiter Phone Screen'
        AND ${v_dim_department.department_name} = 'Engineering'
        AND (
          ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
          OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
        )
      THEN 'Recruiter Phone Screen'

      WHEN ${v_dim_stage.stage_name} = 'Application Review'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND (
      ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      )
      THEN 'Application Review'

      WHEN ${v_dim_stage.stage_name} = 'Sent to Hiring Manager'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND (
      ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      )
      THEN 'Director Resume Review'

      WHEN ${v_dim_stage.stage_name} = 'Recruiter Review'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND (
      ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      )
      THEN 'Recruiter Review'

      WHEN ${v_dim_stage.stage_name} = 'Hiring Manager Interview(s)'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      THEN 'Light Tech Screen'

      WHEN ${v_dim_stage.stage_name} = 'Hiring Manager Interview(s)'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      THEN 'Initial Interview w/ Director'

      WHEN ${v_dim_stage.stage_name} = 'Final Interview'
      AND ${interviewer_name} IN ('Theo Carpenter', 'Benjamin Solwitz', 'Charlyn Gee')
      THEN 'Leadership Interview w/ Director'


      WHEN ${v_dim_stage.stage_name} = 'Final Interview'
      THEN 'Tech Panel Interview'

      WHEN ${v_dim_stage.stage_name} = 'Offer Pending Approvals'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND (
      ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      )
      THEN 'Offer Pending Approvals'

      WHEN ${v_dim_stage.stage_name} = 'Verbal Offer'
      AND ${v_dim_department.department_name} = 'Engineering'
      AND (
      ${v_dim_requisition.requisition_name} LIKE '%Software Engineer%'
      OR ${v_dim_requisition.requisition_name} LIKE '%Engineering Manager%'
      )
      THEN 'Verbal Offer'

      ELSE ${v_dim_stage.stage_name}
      END ;;
  }


  dimension: requisition_role_filter_flag {
    label: "Requisition Role Filter Flag"
    type: number
    hidden: no
    sql:
      CASE
        WHEN {% parameter requisition_role_filter %} = 'ic' AND (
          ${v_dim_requisition.requisition_name} IN ('Senior Software Engineer', 'Staff Software Engineer')
        ) THEN 1

      WHEN {% parameter requisition_role_filter %} = 'manager' AND (
      ${v_dim_requisition.requisition_name} IN ('Engineering Manager', 'Software Engineering Manager')
      ) THEN 1

      WHEN {% parameter requisition_role_filter %} = 'all' THEN 1

      ELSE NULL
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


  dimension: renamed_stage_name_formatted {
    label: "Stage"
    type: string
    html: "<div style='font-weight:600; font-size:14px; padding-left:4px;'>${renamed_stage_name}</div>" ;;
    sql: ${renamed_stage_name} ;;
  }

  ################ RECRUITER ACCURACY ################

  dimension: is_accurate_decision_numeric {
    type: number
    label: "Accurate Interviewer Decision (1/0)"
    sql:
      CASE
        WHEN ${scorecard_recommendation} IN ('yes', 'strong_yes') AND ${v_fact_application_history.rejected_indicator} = 0 THEN 1
        WHEN ${scorecard_recommendation} IN ('no', 'definitely_not') AND ${v_fact_application_history.rejected_indicator} = 1 THEN 1
        ELSE 0
      END ;;
  }

  dimension: is_inaccurate_decision_numeric {
    type: number
    label: "Inaccurate Interviewer Decision (1/0)"
    sql:
      CASE
        WHEN ${scorecard_recommendation} IN ('yes', 'strong_yes') AND ${v_fact_application_history.rejected_indicator} = 1 THEN 1
        WHEN ${scorecard_recommendation} IN ('no', 'definitely_not') AND ${v_fact_application_history.rejected_indicator} = 0 THEN 1
        ELSE 0
      END ;;
  }

  measure: total_interviews_with_recommendation {
    type: count
    filters: [scorecard_recommendation: "-null"]
    label: "Total Evaluated Interviews"
  }

  measure: accurate_decision_count {
    type: sum
    sql: ${is_accurate_decision_numeric} ;;
    label: "Accurate Decisions"
  }

  measure: inaccurate_decision_count {
    type: sum
    sql: ${is_inaccurate_decision_numeric} ;;
    label: "Inaccurate Decisions"
  }

  measure: percent_accurate {
    type: number
    label: "% Accurate"
    value_format_name: "percent_1"
    sql:
      CASE
        WHEN ${total_interviews_with_recommendation} = 0 THEN NULL
        ELSE ${accurate_decision_count} / ${total_interviews_with_recommendation}
      END ;;
  }

  measure: percent_inaccurate {
    type: number
    label: "% Inaccurate"
    value_format_name: "percent_1"
    sql:
      CASE
        WHEN ${total_interviews_with_recommendation} = 0 THEN NULL
        ELSE ${inaccurate_decision_count} / ${total_interviews_with_recommendation}
      END ;;
  }

  ################ PASS-THROUGH FUNNEL ################

  dimension: passed_rps {
    type: yesno
    sql:
      CASE
        WHEN ${renamed_stage_name} = 'Recruiter Phone Screen'
          AND ${scorecard_recommendation} IN ('yes', 'strong_yes') THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: rejected_later {
    type: yesno
    sql: ${v_fact_application_history.rejected_indicator} = 1 ;;
  }

  dimension: rejection_stage {
    type: string
    sql:
      CASE
        WHEN ${rejected_later} = TRUE THEN ${renamed_stage_name}
        ELSE NULL
      END ;;
  }

  dimension: was_hired {
    type: yesno
    sql: ${v_dim_offer.offer_status} = 'hired' ;;
  }

  dimension: final_outcome_stage {
    type: string
    sql:
      CASE
        WHEN ${v_fact_application_history.rejected_indicator} = 1 THEN ${renamed_stage_name}
        WHEN ${v_dim_offer.offer_status} = 'hired' THEN 'Hired'
        ELSE 'In Process'
      END ;;
  }

  dimension: hired_from_rps {
    type: yesno
    sql: ${passed_rps} = TRUE AND ${v_dim_offer.offer_status} = 'hired' ;;
  }

  dimension: rejection_stage_from_rps {
    type: string
    sql:
      CASE
        WHEN ${v_fact_application_history.rejected_indicator} = 1
          AND ${application_key} IN (
            SELECT application_key
            FROM people_analytics.greenhouse.v_fact_interview_scorecard
            WHERE stage_name = 'Recruiter Phone Screen'
              AND scorecard_recommendation IN ('yes', 'strong_yes')
          )
        THEN ${renamed_stage_name}
        ELSE NULL
      END ;;
  }

  measure: count_passed_rps {
    type: count
    filters: [passed_rps: "yes"]
    label: "Passed at RPS"
  }

  measure: count_rejected_at_stage {
    type: count
    filters: [passed_rps: "yes", rejected_later: "yes"]
    label: "Rejected After RPS"
  }

  measure: count_hired {
    type: count
    filters: [passed_rps: "yes", was_hired: "yes"]
    label: "Hired After RPS"
  }

  measure: count_passed_rps_final_outcome {
    type: count
    filters: [passed_rps: "yes"]
    label: "Passed RPS → Final Outcome"
  }

  measure: rps_passed_candidate_count {
    type: count_distinct
    sql: ${application_key} ;;
    label: "RPS-Passed Candidate Count"
  }

  ################ HIRING FUNNEL: IC + MANAGER ################

  # You'll repeat similar patterns as above for:
  # - IC: passed_light_tech_screen_ic, moved_to_tech_panel_ic, moved_to_leadership_from_ic
  # - Manager: passed_initial_director_eng_manager, moved_to_tech_panel_eng_manager, etc.

  dimension: hired_ic_any {
    type: yesno
    label: "Hired (IC Roles - Any Path)"
    sql: ${application_key} IN (
      SELECT application_key
      FROM people_analytics.greenhouse.v_dim_application
      WHERE application_status = 'hired'
    ) ;;
  }

  measure: count_hired_ic_any {
    type: count
    filters: [hired_ic_any: "yes"]
    label: "Hired (IC Roles - Any Path)"
  }

  dimension: hired_eng_manager {
    type: yesno
    label: "Hired (Eng Manager)"
    sql: ${application_key} IN (
      SELECT application_key
      FROM people_analytics.greenhouse.v_dim_application
      WHERE application_status = 'hired'
    ) AND ${v_dim_requisition.requisition_name} = 'Engineering Manager' ;;
  }

  measure: count_hired_eng_manager {
    type: count
    filters: [hired_eng_manager: "yes"]
    label: "Hired (Eng Manager)"
  }

  dimension: is_strong_yes {
    type: yesno
    sql: ${scorecard_recommendation} = 'strong_yes' ;;
  }

  dimension: is_yes {
    type: yesno
    sql: ${scorecard_recommendation} = 'yes' ;;
  }

  dimension: is_no {
    type: yesno
    sql: ${scorecard_recommendation} = 'no' ;;
  }

  dimension: is_definitely_not {
    type: yesno
    sql: ${scorecard_recommendation} = 'definitely_not' ;;
  }

  measure: count_strong_yes {
    type: count
    filters: [is_strong_yes: "yes"]
    label: "Strong Yes Count"
  }

  measure: count_yes {
    type: count
    filters: [is_yes: "yes"]
    label: "Yes Count"
  }

  measure: count_no {
    type: count
    filters: [is_no: "yes"]
    label: "No Count"
  }

  measure: count_definitely_not {
    type: count
    filters: [is_definitely_not: "yes"]
    label: "Definitely Not Count"
  }

  measure: total_positive_recommendations {
    type: number
    sql: ${count_yes} + ${count_strong_yes} ;;
    label: "Total Positive (Yes + Strong Yes)"
  }

  measure: total_negative_recommendations {
    type: number
    sql: ${count_no} + ${count_definitely_not} ;;
    label: "Total Negative (No + Definitely Not)"
  }

# Positive
  measure: distinct_yes_candidates {
    type: count_distinct
    sql: CASE WHEN ${is_yes} THEN ${candidate_key} ELSE NULL END ;;
    label: "Distinct Candidates with Yes"
  }

  measure: distinct_strong_yes_candidates {
    type: count_distinct
    sql: CASE WHEN ${is_strong_yes} THEN ${candidate_key} ELSE NULL END ;;
    label: "Distinct Candidates with Strong Yes"
  }

  measure: total_distinct_positive_recommendations {
    type: number
    sql: ${distinct_yes_candidates} + ${distinct_strong_yes_candidates} ;;
    label: "Total Distinct Positive (Yes + Strong Yes)"
  }

  measure: distinct_no_candidates {
    type: count_distinct
    sql: CASE WHEN ${is_no} THEN ${candidate_key} ELSE NULL END ;;
    label: "Distinct Candidates with No"
  }

  measure: distinct_definitely_not_candidates {
    type: count_distinct
    sql: CASE WHEN ${is_definitely_not} THEN ${candidate_key} ELSE NULL END ;;
    label: "Distinct Candidates with Definitely Not"
  }

  measure: total_distinct_negative_recommendations {
    type: number
    sql: ${distinct_no_candidates} + ${distinct_definitely_not_candidates} ;;
    label: "Total Distinct Negative (No + Definitely Not)"
  }


  dimension: scorecard_sentiment {
    label: "Scorecard Recommendation (Combined)"
    type: string
    sql:
    CASE
      WHEN ${scorecard_recommendation} IN ('yes', 'strong_yes') THEN 'Yes'
      WHEN ${scorecard_recommendation} IN ('no', 'definitely_not') THEN 'No'
      ELSE 'Other'
    END ;;
  }

  dimension: application_applied_bucket {
    type: string
    sql:
    CASE
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 7 THEN '0–7 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 30 THEN '0–30 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 60 THEN '0–60 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 90 THEN '0–90 days'
      ELSE 'Over 90 days'
    END
  ;;
  }

  dimension: application_applied_bucket_order {
    type: number
    sql:
    CASE
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 7 THEN 1
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 30 THEN 2
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 60 THEN 3
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_application_applied_date_date}, CURRENT_DATE) <= 90 THEN 4
      ELSE 5
    END
  ;;
  }

  dimension: prior_stage_age_bucket {
    type: string
    sql:
    CASE
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) <= 7 THEN '0–7 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 8 AND 30 THEN '8–30 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 31 AND 60 THEN '31–60 days'
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 61 AND 90 THEN '61–90 days'
      ELSE 'Over 90 days'
    END
  ;;
  }

  dimension: prior_stage_age_bucket_order {
    type: number
    sql:
    CASE
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) <= 7 THEN 1
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 8 AND 30 THEN 2
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 31 AND 60 THEN 3
      WHEN DATEDIFF('day', ${v_fact_application_history.application_history_prior_stage_date_date}, CURRENT_DATE) BETWEEN 61 AND 90 THEN 4
      ELSE 5
    END
  ;;
  }

  measure: total_comp_rejections {
    type: count_distinct
    sql: ${v_dim_candidate.candidate_id} ;;
    filters: [
      v_dim_application.application_rejection_reason: "Compensation not aligned, Outside salary range, Took competing job offer"
    ]
    label: "Compensation-Related Rejections"
    description: "Unique candidates rejected for compensation-related reasons"
    drill_fields: [v_dim_candidate.candidate_full_name, v_dim_candidate.candidate_id, v_dim_candidate.greenhouse_link]
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



  }

################ CLOSE VIEW BLOCK ################
