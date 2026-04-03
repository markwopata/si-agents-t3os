connection: "reportingc_warehouse"

include: "/views/*.view.lkml"

explore: driver_performance_report {
  view_name: driver_performance
  case_sensitive: no
  persist_for: "30 minutes"
  # sql_always_where: ${company_id} =  {{ _user_attributes['company_id'] }};;
  sql_always_where: ${driver_performance.company_id} = 18415 and ${driver_performance.incident_source} = 'Vehicle Tracker' ;;
}
