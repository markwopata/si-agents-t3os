connection: "es_snowflake_analytics"

include: "/webex/*.view.lkml"                # include all views in the views/ folder in this project

explore: webex_branch_rollovers {
  label: "Webex Branch Rollovers"
  description: "This dashboard summarizes inbound phone activity for each branch, focusing on calls that entered the general queue and ultimately rolled to the Customer Support team when unanswered. Metrics are derived from Webex API call detail data."
  case_sensitive: no
  persist_for: "12 hours"
}
