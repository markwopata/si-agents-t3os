connection: "es_snowflake_analytics"

include: "/views/custom_sql/branch_survey_results.view.lkml"                # include all views in the views/ folder in this project
include: "/views/custom_sql/branch_survey_comment.view.lkml"


explore: branch_survey_results {
  group_label: "Branch Survey"
  case_sensitive: no
}
explore: branch_survey_comment {
  group_label: "Branch Survey"
  case_sensitive: no
}
