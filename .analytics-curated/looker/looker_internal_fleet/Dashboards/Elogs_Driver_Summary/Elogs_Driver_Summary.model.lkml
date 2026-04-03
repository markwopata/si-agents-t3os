connection: "es_snowflake"

include: "/Dashboards/Elogs_Driver_Summary/Views/*.view.lkml"

explore: elogs_driver_summary {
  label: "ELogs Driver Summary"
  case_sensitive: no
}
