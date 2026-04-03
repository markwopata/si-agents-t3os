connection: "es_snowflake_analytics"

include: "/voze_export/*.view.lkml"

explore: voze_company_export {
  group_label: "Export"
  label: "Voze Company Export"
  case_sensitive: no
}
