connection: "reportingc_warehouse"

include: "/views/analytics_quick_insights.view.lkml"


explore: analytics_quick_insights {
  group_label: "Analytics"
  label: "Quick Insights"
  case_sensitive: no
  persist_for: "10 minutes"
}
