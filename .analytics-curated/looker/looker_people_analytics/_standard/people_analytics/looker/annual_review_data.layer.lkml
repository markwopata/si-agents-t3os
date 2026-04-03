include: "/_base/people_analytics/looker/annual_review_data.view.lkml"

view: +annual_review_data {

  # dimension: days_to_review {
  #   type: number
  #   sql: ${TABLE}."DAYS_TO_REVIEW" ;;
  # }
  dimension: abs_days_to_review {
    type: number
    sql: abs(${days_to_review}) ;;
    description: "Absolute value of days calculation to eliminate negatives."
  }
  dimension: employee_id {
    value_format_name:id
  }
  # dimension: name {
  #   type: string
  #   sql: ${TABLE}."NAME" ;;
  # }
  dimension_group: date_hired {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_hired} ;;
  }
  # dimension: reason_code {
  #   type: string
  #   sql: ${TABLE}."REASON_CODE" ;;
  # }
  # dimension: record_id {
  #   type: string
  #   sql: ${TABLE}."RECORD_ID" ;;
  # }
  dimension: review_ind {
    type: yesno
    sql: case
         when ${reason_code} in ('90 Day Review','Annual Review','Merit Increase','Performance Evaluation','Promotion') then "yes"
        else "no" end;;
  }
  dimension_group: review_actual {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${review_actual} ;;
  }
  dimension_group: review_target {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${review_target} ;;
  }
  dimension: review_timing_id {
    value_format_name: id
  }

  # dimension: review_timing_name {
  #   type: string
  #   sql: ${TABLE}."REVIEW_TIMING_NAME" ;;
  # }
  # dimension: region {
  #   type: string
  #   sql:  ${TABLE}."REGION" ;;
  # }
  # dimension: district {
  #   type: string
  #   sql: ${TABLE}."DISTRICT" ;;
  # }
  # dimension: department {
  #   type: string
  #   sql: ${TABLE}."DEPARTMENT" ;;
  # }
  # dimension: sub_department {
  #   type: string
  #   sql: ${TABLE}."SUB_DEPARTMENT" ;;
  # }
  # dimension: direct_manager_name {
  #   type: string
  #   sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  # }
  dimension: direct_manager_employee_id {
    value_format_name: id
  }

  dimension: review_target_last_12_months {
    type: yesno
    sql: ${review_target_date} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
    and ${review_target_date} <= dateadd('second',-1,date_trunc('month',current_date));;
  }

  dimension: review_actual_last_12_months {
    type: yesno
    sql: ${review_actual_date} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
      and ${review_actual_date} <= dateadd('second',-1,date_trunc('month',current_date));;
  }
  #dimension: company_tenure {
    #type: string
    #sql: CASE WHEN ${date_terminated_date} is not null THEN DATEDIFF(month, ${date_hired_date},${date_terminated_date})
      #ELSE DATEDIFF(month, ${date_hired_date},${_es_update_timestamp_date}) END;;
  #}

  measure: total_count {
    type: count_distinct
    sql: ${employee_id};;
    drill_fields: [user_details*]
  }

  measure: no_review_count {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [max_review_count: "1",no_review_ind: "Yes"]
    drill_fields: [user_details*]
  }

  measure: completed_review_count {
    type: count_distinct
    sql: ${employee_id} ;;
    filters: [no_review_ind: "No" ,review_ind: "Yes"]
    drill_fields: [user_details*]
  }

  measure: count {
    type: count
    drill_fields: [user_details*]
  }

  set: user_details {
    fields: [employee_id,
            name,
            department,
            sub_department,
            direct_manager_name,
            reason_code,
            date_hired_date,
            review_target_date,
            review_actual_date,
            review_timing_name,
            days_to_review]
}
}
