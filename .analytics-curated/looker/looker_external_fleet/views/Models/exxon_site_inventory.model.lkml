connection: "es_warehouse"

include: "/views/exxon_sites_inventory.view.lkml"

explore: exxon_sites_inventory {
  group_label: "Custom Report"
  label: "Exxon Sites Inventory"
  case_sensitive: no
  persist_for: "10 minutes"
}
