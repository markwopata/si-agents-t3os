connection: "es_snowflake_analytics"

# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/views/ANALYTICS/commission_clawback_history.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/greenhouse_ddi_scorecard.view.lkml"
include: "/views/GREENHOUSE/application.view.lkml"
include: "/views/GREENHOUSE/job_stage.view.lkml"
include: "/views/GREENHOUSE/job.view.lkml"
include: "/views/GREENHOUSE/note.view.lkml"
include: "/views/GREENHOUSE/scorecard.view.lkml"
include: "/views/GREENHOUSE/email_address.view.lkml"
include: "/views/GREENHOUSE/source.view.lkml"
include: "/views/GREENHOUSE/candidate.view.lkml"
include: "/views/GREENHOUSE/scheduled_interview.view.lkml"
include: "/views/GREENHOUSE/rejection_reason.view.lkml"
include: "/views/GREENHOUSE/hiring_team.view.lkml"
include: "/views/GREENHOUSE/user.view.lkml"
include: "/views/GREENHOUSE/candidate_tag.view.lkml"
include: "/views/GREENHOUSE/tag.view.lkml"
include: "/views/GREENHOUSE/job_application.view.lkml"
include: "/views/GREENHOUSE/scorecard_qna.view.lkml"
include: "/views/GREENHOUSE/interview.view.lkml"
include: "/views/GREENHOUSE/job_office.view.lkml"
include: "/views/GREENHOUSE/office.view.lkml"
include: "/views/custom_sql/user_recruiters.view.lkml"
include: "/views/custom_sql/user_hiring_managers.view.lkml"
include: "/views/ANALYTICS/greenhouse_job_id_sample.view.lkml"
include: "/views/ANALYTICS/hr_manager_priorities.view.lkml"
include: "/views/ANALYTICS/greenhouse_permission_overrides.view.lkml"
#include: "/views/ANALYTICS/paycor_employees_managers_full_hierarchy.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/commissions.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
#include: "/views/ANALYTICS/intaact_code_by_ee.view.lkml"
include: "/views/ANALYTICS/disc_gh_ukg.view.lkml"
include: "/views/ANALYTICS/employee_branch_ukg.view.lkml"
include: "/views/custom_sql/es_user_info.view.lkml"
include: "/views/ANALYTICS/ukg_employee_hierarchy.view.lkml"
include: "/views/ANALYTICS/corporate_locations.view.lkml"
include: "/views/custom_sql/employee_user_list.view.lkml"

datagroup: corporate_locations_data_update {
  sql_trigger: select max(_fivetran_synced) from analytics.public.corporate_locations ;;
  max_cache_age: "24 hours"
  description: "Looking at coporate locations to grab most recent fivetran update."
}


explore: disc_master {
  group_label: "HR Payroll"
  label: "DISC Master"

  join: disc_gh_ukg {
    type: full_outer
    relationship: one_to_one
    sql_on: ${disc_master.disc_code} = ${disc_gh_ukg.disc_code} ;;
  }

  join: company_directory{
    type: full_outer
    relationship: one_to_one
    sql_on: ${disc_gh_ukg.employee_id}::int = ${company_directory.employee_id}::int ;;
  }

  join: employee_branch_ukg {
    type: left_outer
    relationship: one_to_one
    sql_on: ${disc_gh_ukg.employee_id} = ${employee_branch_ukg.employee_id} ;;
  }
}

explore: hr_recruiting_pipeline {
  from: candidate
  sql_always_where:
  ${user_recruiters.user_id} is not null
  AND TRIM(LOWER(${job.status})) != 'closed'
  AND
  (
  '{{ _user_attributes['email'] }}' in (
  'leslie.adams@equipmentshare.com',
    'leslie@equipmentshare.com',
  'jabbok@equipmentshare.com',
  'gina.campagna@equipmentshare.com',
  'tiffany.goalder@equipmentshare.com',
  'david.adams@equipmentshare.com')
  OR TRIM(LOWER(${user_recruiters.email}))=  TRIM(LOWER('{{ _user_attributes['email'] }}'))
  OR TRIM(LOWER(${user_hiring_managers.email}))=TRIM(LOWER('{{ _user_attributes['email'] }}'))
  OR TRIM(LOWER(${greenhouse_permission_overrides.user_email}))=TRIM(LOWER('{{ _user_attributes['email'] }}'))
  OR 'hr' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  )
  ;;


  join: application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${hr_recruiting_pipeline.candidate_id}=${application.candidate_id} ;;
  }

  join: job_application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application.application_id}=${job_application.application_id} ;;
  }

  join: job_stage {
    type: left_outer
    relationship: many_to_one
    sql_on: ${application.current_stage_id}=${job_stage.id} ;;
  }

  join: interview {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_stage.id}=${interview.job_stage_id} ;;
  }

  join: hr_manager_priorities {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application.application_id}=${hr_manager_priorities.application_id} ;;
  }

  # join: scheduled_interview {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${application.application_id}=${scheduled_interview.application_id} ;;
  # }

  join: rejection_reason {
    type: left_outer
    relationship: many_to_one
    sql_on: ${application.rejected_reason_id}=${rejection_reason.rejection_reason_type_id} ;;
  }

  join: job {
    type: left_outer
    relationship: many_to_many
    sql_on: ${job_stage.job_id}=${job.job_id} ;;
  }

  # join: greenhouse_job_id_sample {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${job.job_id}=${greenhouse_job_id_sample.job_id} ;;
  # }

  join: greenhouse_permission_overrides {
    type: left_outer
    relationship: many_to_many
    sql_on: ${job.job_id}=${greenhouse_permission_overrides.job_id} ;;
  }

  join: job_office {
    type: left_outer
    relationship: many_to_one
    sql_on: ${job_stage.job_id}=${job_office.job_id} ;;
  }

  join: office {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_office.office_id}=${office.id} ;;
  }

  # join: markets {
  #   sql_table_name: ES_WAREHOUSE.PUBLIC.MARKETS ;;
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${greenhouse_job_id_sample.market_id}=${markets.market_id} ;;
  # }

  # join: market_region_xwalk {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${greenhouse_job_id_sample.market_id}=${market_region_xwalk.market_id} ;;
  # }

  join: user_recruiters {
    type: left_outer
    relationship: many_to_one
    sql_on: ${job.job_id}=${user_recruiters.job_id} ;;
   ## sql_on: ${greenhouse_job_id_sample.job_id}=${user_recruiters.job_id} ;;
  }

  join: user_hiring_managers {
    type: left_outer
    relationship: many_to_one
     sql_on: ${job.job_id}=${user_hiring_managers.job_id} ;;
    ##sql_on: ${greenhouse_job_id_sample.job_id}=${user_hiring_managers.job_id} ;;
  }

  #join: recruiters_full_hierarchy {
  #  from: paycor_employees_managers_full_hierarchy
  #  type: left_outer
  #  relationship: many_to_many
  #  sql_on: trim(lower(${user_recruiters.email}))=trim(lower(${recruiters_full_hierarchy.employee_email})) ;;
  #}

  #join: hiring_managers_full_hierarchy {
  #  from: paycor_employees_managers_full_hierarchy
  #  type: left_outer
  #  relationship: many_to_many
  #  sql_on: trim(lower(${user_hiring_managers.email}))=trim(lower(${hiring_managers_full_hierarchy.employee_email})) ;;
  #}

  join: hiring_team {
    type: left_outer
    relationship: many_to_many
    sql_on: ${job.job_id}=${hiring_team.job_id} ;;
  }

  join: user {
    type: left_outer
    relationship: many_to_one
    sql_on: ${hiring_team.user_id}=${user.id} ;;
  }

  join: note {
    type: left_outer
    relationship: one_to_one
    sql_on: ${hr_recruiting_pipeline.candidate_id}=${note.candidate_id} ;;
  }

  join: scorecard {
    type: left_outer
    relationship: one_to_one
    sql_on:${hr_recruiting_pipeline.candidate_id}= ${scorecard.candidate_id}
            and ${application.application_id}=${scorecard.application_id};;
  }

  join: email_address {
    type: left_outer
    relationship: one_to_one
    sql_on: ${hr_recruiting_pipeline.candidate_id}=${email_address.candidate_id} ;;
  }

  join: source {
    type: left_outer
    relationship: many_to_many
    sql_on: ${application.source_id}=${source.id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: lower(trim(${email_address.email_address}))=lower(trim(${disc_master.email_address})) ;;
  }

  join: candidate_tag {
    type: left_outer
    relationship: one_to_one
    sql_on: ${hr_recruiting_pipeline.candidate_id}=${candidate_tag.candidate_id};;
  }

  join: greenhouse_ddi_scorecard {
    type: left_outer
    relationship: one_to_many
    sql_on: lower(trim(${email_address.email_address}))=lower(trim(${greenhouse_ddi_scorecard.candidate_email})) ;;
  }

  join: scorecard_qna {
    type: left_outer
    relationship: one_to_many
    sql_on: ${scorecard.scorecard_id}=${scorecard_qna.scorecard_id} ;;
  }
}

explore: commissions {
  ##from: commission_clawback_history
  from: commissions
  group_label: "HR Payroll"
  label: "Commissions & Clawbacks"

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commissions.user_id} = ${users.user_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.employee_id} = ${company_directory.employee_id} ;;
  }

  #join: intaact_code_by_ee {
  #  type: left_outer
  #  relationship: one_to_one
  #  sql_on: ${company_directory.employee_id} = ${intaact_code_by_ee.employee_id} ;;
  #}

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.market_id} = ${market_region_xwalk.market_id} ;;
  }

}

explore: es_user_info {
  group_label: "HR"
  label: "ES User by Branch Info"
  case_sensitive: no
  description: "Used for HR to see who is assigned to what branch or not assigned to a branch"
}

explore: ukg_employee_hierarchy {
  group_label: "HR"
  label: "UKG Employeees and Manager Data"
  case_sensitive: no
  description: "Used for HR to identify top level manager for employees"
}

explore: corporate_locations {
  group_label: "Company Directory Dashboard"
  label: "Corporate Locations"
  case_sensitive: no
  persist_with: corporate_locations_data_update
}

explore: employee_user_list {
  label: "Employee User List"
  case_sensitive: no
  description: "Basic list of employee info. Molly Lowe is the requestor"
}
