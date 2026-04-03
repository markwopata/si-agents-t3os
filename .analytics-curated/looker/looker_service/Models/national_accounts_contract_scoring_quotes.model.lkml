connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/na_contract_scoring_quotes_audit_details.view.lkml"
include: "/views/ANALYTICS/na_contract_scoring_quotes_audit_summary.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_users_fleet_opt.view.lkml"

case_sensitive: no
# persist_for: "24 hours"

explore: na_contract_scoring_quotes_audit_summary {

  join: na_contract_scoring_quotes_audit_details {
    relationship: one_to_many
    sql_on: ${na_contract_scoring_quotes_audit_details.quote_file_url} = ${na_contract_scoring_quotes_audit_summary.quote_file_url} ;;
  }
  join: dim_users_fleet_opt {
    relationship: many_to_one
    sql_on: ${na_contract_scoring_quotes_audit_summary.created_by} = ${dim_users_fleet_opt.user_username} ;;
    # sql_where: ${dim_users_fleet_opt.user_username} IS NOT NULL ;;
  }
}
