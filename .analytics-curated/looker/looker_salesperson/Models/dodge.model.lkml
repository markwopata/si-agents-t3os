connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/Dodge/ff_out_company.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_company_contacts.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_factor_note.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_project_exception.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_publish_notes.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_county.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_csi.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_firm_relationship.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_flex_value.view.lkml"
#include: "/views/ANALYTICS/Dodge/ff_out_rep_item_code.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_project_capsule.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_project_type.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_stage.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_subproject_capsule.view.lkml"
include: "/views/ANALYTICS/Dodge/ff_out_rep_type_of_item.view.lkml"
include: "/views/custom_sql/dodge_search_query.view.lkml"
include: "/views/custom_sql/msa.view.lkml"
include: "/views/custom_sql/dodge_projects.view.lkml"
include: "/views/custom_sql/dodge_contacts.view.lkml"
include: "/views/custom_sql/dodge_unique_projects.view.lkml"
include: "/views/custom_sql/dodge_existing_company.view.lkml"
include: "/views/custom_sql/market_region_salesperson_email.view.lkml"
include: "/views/custom_sql/dodge_proj_cross_join.view.lkml"
include: "/views/custom_sql/top_rev_by_sales_rep.view.lkml"
include: "/views/ANALYTICS/blue_book.view.lkml"
# datagroup: 6AM_update {
#   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
#   max_cache_age: "24 hours"
# }

# datagroup: Every_Hour_Update {
#   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
#   max_cache_age: "1 hour"
# }

# datagroup: Every_Two_Hours_Update {
#   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
#   max_cache_age: "2 hours"
# }

# datagroup: Every_5_Min_Update {
#   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
#   max_cache_age: "5 minutes"
# }
# explore: blue_book {
#   case_sensitive: no
#   sql_always_where: ${blue_book.project_status} NOT IN ('Design', 'Pre-Design', 'Abandoned', 'Planning-Design Development', 'Delayed')
#                   and ${blue_book.project_structure} NOT IN ('House', 'Residential Building', 'Swimming Pool');;
# }

# explore: ff_out_rep_project_capsule {
#   case_sensitive: no

#   join: ff_out_rep_stage {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${ff_out_rep_stage.dr_nbr} = ${ff_out_rep_project_capsule.dr_nbr} ;;
#     }

#   join: ff_out_rep_firm_relationship {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${ff_out_rep_project_capsule.dr_nbr} = ${ff_out_rep_firm_relationship.dr_nbr} ;;
#   }

#   join: ff_out_company_contacts {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${ff_out_rep_firm_relationship.dcis_factor_code} = ${ff_out_company_contacts.dcis_factor_code} ;;
#   }

#   join: msa {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: substring(${ff_out_rep_project_capsule.p_zip_code},0,5) = ${msa.project_zip_code} and substring(${ff_out_company_contacts.c_zip_code},0,5) = ${msa.project_zip_code} ;;
#   }

#   }

# explore: dodge_search_query {
#   case_sensitive: no

#   join: msa {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: substring(${dodge_search_query.project_zip_code},0,5) = ${msa.project_zip_code} ;;
#   }
#   }

explore: dodge_projects {
  group_label: "Dodge"
  case_sensitive: no
  persist_for: "24 hours"

  join: msa {
    type: left_outer
    relationship: many_to_one
    sql_on: substring(${dodge_projects.zip_code},0,5) = ${msa.project_zip_code}  ;;
  }

  join: dodge_unique_projects {
    type: inner
    relationship: many_to_one
    sql_on: ${dodge_unique_projects.dr_nbr} = ${dodge_projects.dr_nbr} and ${dodge_unique_projects.max_publish_date} = ${dodge_projects.publish_date}
              and ${dodge_unique_projects.max_stage_order} = ${dodge_projects.stage_order} ;;
  }

  join: dodge_proj_cross_join {
    type: inner
    relationship: many_to_one
    sql_on: ${dodge_projects.dr_nbr} = ${dodge_proj_cross_join.dr_nbr}  ;;
  }
}

explore: dodge_contacts {
  group_label: "Dodge"
  case_sensitive: no
  persist_for: "24 hours"

  join: msa {
    type: left_outer
    relationship: many_to_one
    sql_on: substring(${dodge_contacts.zip_code},0,5) = ${msa.project_zip_code}  ;;
  }

  join: dodge_existing_company {
    type: left_outer
    relationship: many_to_one
    sql_on: LOWER(regexp_replace(${dodge_contacts.firm_name}, '[^a-zA-Z0-9]+', ''))||${dodge_contacts.zip_code} = ${dodge_existing_company.es_company_zip}  ;;
  }

}
