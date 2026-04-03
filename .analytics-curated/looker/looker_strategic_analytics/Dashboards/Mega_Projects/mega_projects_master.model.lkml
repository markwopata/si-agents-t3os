connection: "es_snowflake_analytics"

include: "/Views/analytics/mega_project_tracker.view.lkml"

explore: mega_project_tracker {
  label: "mega_projects"
  case_sensitive: no
  persist_for: "8 hours"
  description: "Mega projects SSOT"
  }

