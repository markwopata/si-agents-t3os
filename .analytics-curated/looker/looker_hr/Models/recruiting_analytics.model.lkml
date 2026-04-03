connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/candidate_info_view.view.lkml"
include: "/views/ANALYTICS/application_info_view.view.lkml"
include: "/views/ANALYTICS/requisition_info_view.view.lkml"
include: "/views/ANALYTICS/application_source_view.view.lkml"
include: "/views/ANALYTICS/hiring_team_by_job_view.view.lkml"
include: "/views/ANALYTICS/locations_by_job_view.view.lkml"
include: "/views/custom_sql/ad_spend_long.view.lkml"
include: "/views/custom_sql/company_directory_merged_ghid.view.lkml"
include: "/views/ANALYTICS/job_opening.view.lkml"
include: "/views/ANALYTICS/offer.view.lkml"
include: "/views/ANALYTICS/activity.view.lkml"
include: "/views/ANALYTICS/stages_info_view.view.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#

explore: application_info_view {
  join: activity {
    relationship: one_to_one
    sql_on: ${activity.candidate_id} = ${application_info_view.candidate_id} ;;
  }

  join: candidate_info_view {
    relationship: many_to_one
    sql_on: ${application_info_view.candidate_id} = ${candidate_info_view.candidate_id} ;;
  }

  join: requisition_info_view {
    relationship: one_to_one
    sql_on: ${requisition_info_view.job_id} = ${application_info_view.job_id} ;;
  }

  join: hiring_team_by_job_view {
    relationship: many_to_one
    sql_on: ${hiring_team_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
  }

  join: locations_by_job_view {
    relationship: many_to_one
    sql_on: ${locations_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
  }

  join: company_directory_merged_ghid {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application_info_view.application_id} = ${company_directory_merged_ghid.GREENHOUSE_APPLICATION_ID} ;;
  }

  join: job_opening {
    relationship: one_to_one
    sql_on: ${job_opening.job_id} = ${application_info_view.job_id} ;;
  }

  join: offer {
    relationship: one_to_one
    sql_on: ${offer.application_id} = ${application_info_view.application_id} ;;
  }

  join: stages_info_view {
    relationship: one_to_one
    sql_on: ${stages_info_view.candidate_id} = ${application_info_view.candidate_id} ;;
  }

  #join: ad_spend_long {
  #  type: full_outer
  #  relationship: many_to_many
  #  sql_on: ${application_info_view.application_source} = ${ad_spend_long.source} ;;
  #}
}

explore: ad_spend_long {
  join: application_info_view {
    type: full_outer
    relationship: one_to_many
    sql_on: ${application_info_view.application_source} = ${ad_spend_long.source} and ${application_info_view.submitted_week} = ${ad_spend_long.week_of_week} ;;
    }
}

# explore: company_directory_merged_ghid { --MB comment out 10-10-23 due to inactivity

# }


explore: requisition_info_view {

  join: application_info_view {
    relationship: one_to_one
    sql_on: ${requisition_info_view.job_id} = ${application_info_view.job_id} ;;
  }

  join: candidate_info_view {
    relationship: many_to_one
    sql_on: ${application_info_view.candidate_id} = ${candidate_info_view.candidate_id} ;;
  }

  join: hiring_team_by_job_view {
    relationship: many_to_one
    sql_on: ${hiring_team_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
  }

  join: locations_by_job_view {
    relationship: many_to_one
    sql_on: ${locations_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
  }

  join: company_directory_merged_ghid {
    type: full_outer
    relationship: one_to_one
    sql_on: ${application_info_view.application_id} = ${company_directory_merged_ghid.GREENHOUSE_APPLICATION_ID} ;;
  }

}

#explore: candidate_info_view {
#  join: application_info_view {
#    relationship: many_to_one
#    sql_on: ${application_info_view.candidate_id} = ${candidate_info_view.candidate_id} ;;
#  }

#  join: requisition_info_view {
#    relationship: one_to_one
#    sql_on: ${requisition_info_view.job_id} = ${application_info_view.job_id} ;;
#  }

#  join: hiring_team_by_job_view {
#    relationship: many_to_one
#    sql_on: ${hiring_team_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
#  }

#  join: locations_by_job_view {
#    relationship: many_to_one
#    sql_on: ${locations_by_job_view.job_id} = ${requisition_info_view.job_id} ;;
#  }

#  join: company_directory_merged_ghid {
#    type: full_outer
#    relationship: one_to_one
#    sql_on: ${application_info_view.application_id} = ${company_directory_merged_ghid.GREENHOUSE_APPLICATION_ID} ;;
#  }

#}
