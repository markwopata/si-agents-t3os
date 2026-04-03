connection: "es_snowflake"

include: "/views/service_outside_labor_enhancement.view.lkml"

explore: service_outside_labor_enhancement {
  label: "Service Outside Labor with PO Grain"
  case_sensitive: no

}
