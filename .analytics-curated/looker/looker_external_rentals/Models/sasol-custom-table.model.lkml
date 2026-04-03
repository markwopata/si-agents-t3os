connection: "es_warehouse"

include: "/views/*.view.lkml"  # include all views in the views/ folder in this project

explore: sasol_custom_table {
  from: sasol_custom_table
  label: "Sasol Custom Dashboard"
  group_label: "Sasol Custom Dashboard"
  # description: "Purpose of this explore"
  # persist_for: "60 minutes"
  case_sensitive: no
}
