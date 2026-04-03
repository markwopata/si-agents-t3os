include: "/_standard/people_analytics/looker/workforce_planning.layer.lkml"
include: "/_standard/people_analytics/looker/corporate_open_reqs.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/looker/corporate_wfp_goals.layer.lkml"


view: +workforce_planning {

  dimension: total_comp_no_changes {
    type: number
    value_format: "$#,##0.00"
    sql: ${compensation_through_prev_month} + ((${employee_count}*${average_salary})*(${months_left}/12)) ;;
  }
}

view: +company_directory {

  measure: distinct_employee_count {
    type: count_distinct
    sql: ${employee_id} ;;
    drill_fields: [employee_id,
      first_name,
      last_name,
      workforce_planning.department,
      workforce_planning.sub_department,
      employee_title,
      employee_status,
      date_hired,
      date_rehired,
      direct_manager_name]
  }
}

view: +corporate_open_reqs {

  measure: unique_open_req_ids {
    type: count_distinct
    sql: ${open_req_ids};;
    description: "Unique Count of Open Requisition IDs"
    drill_fields: [workforce_planning.department,
      workforce_planning.sub_department,
      open_req_ids,
      v_dim_requisition.requisition_name,
      v_dim_requisition.requisition_status]
  }
}

explore: workforce_planning {
  label: "Workforce Planning Compensation"

  join: corporate_open_reqs {
    type: left_outer
    relationship: one_to_many
    sql_on: ${workforce_planning.department} = ${corporate_open_reqs.department} and ${workforce_planning.sub_department} = ${corporate_open_reqs.sub_department} ;;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: ${workforce_planning.department} = SPLIT_PART(${company_directory.default_cost_centers_full_path},'/',4) and ${workforce_planning.sub_department} = SPLIT_PART(${company_directory.default_cost_centers_full_path},'/',5) ;;
    sql_where: ${company_directory.employee_status} in ('Active','External Payroll','Leave with Pay','Leave without Pay','Work Comp Leave','On Leave','Seasonal (Fixed Term) (Seasonal)','Apprentice') ;;
  }

  join: v_dim_requisition {
    type: left_outer
    relationship: one_to_one
    sql_on: ${corporate_open_reqs.open_req_ids} = ${v_dim_requisition.requisition_id} ;;
  }

  join: corporate_wfp_goals {
    type: left_outer
    relationship: one_to_one
    sql_on: ${workforce_planning.sub_department} = ${corporate_wfp_goals.subdepartment} ;;
  }

  }
