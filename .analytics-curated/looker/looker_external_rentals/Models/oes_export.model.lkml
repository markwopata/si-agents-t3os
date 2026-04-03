connection: "es_warehouse"

include: "/views/custom_exports/*.view.lkml" # include all views in the views/ folder in this project

explore: oes_export {
  from: oes_export
  label: "OES Export"
  group_label: "OES Export"
  # description: "Purpose of this explore"
  # persist_for: "60 minutes"
  case_sensitive: no
}
