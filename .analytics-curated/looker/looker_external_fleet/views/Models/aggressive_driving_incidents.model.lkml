connection: "es_warehouse"

include: "/views/aggressive_driving_incidents/aggressive_driving_incidents.view.lkml"

explore: aggressive_driving_incidents {
  view_name: aggressive_driving_incidents
  group_label: "Fleet"
  label: "Aggressive Driving Incidents"
  case_sensitive: no
  # persist_for: "30 minutes"
  sql_always_where: ${company_id} =  {{ _user_attributes['company_id'] }};;
}
