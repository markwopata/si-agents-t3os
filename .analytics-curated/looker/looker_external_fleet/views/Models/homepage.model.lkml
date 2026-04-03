connection: "es_warehouse"

include: "/views/homepage/*.view.lkml"

explore: homepage_recent_dashboard_views {
  group_label: "Homepage"
  label: "Most Recent Dashboard Views"
  case_sensitive: no
  persist_for: "60 minutes"
}

explore: homepage_visits_by_company {
  group_label: "Homepage"
  label: "Total Dashboard Visits By Company"
  case_sensitive: no
  persist_for: "60 minutes"
}
