connection: "es_warehouse"

include: "/views/trapac_oakland_fuel_level/*.view.lkml"

explore: trapac_oakland_fuel_level {
  group_label: "Custom Report"
  label: "Trapac Oakland Fuel Level"
  case_sensitive: no
}
