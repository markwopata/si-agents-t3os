connection: "es_warehouse"

include: "/views/assets_out_of_lock/assets_out_of_lock.view.lkml"

explore: aggressive_driving_incidents {
  view_name: assets_out_of_lock
  group_label: "Fleet"
  label: "Assets Out of Lock"
  case_sensitive: no
  persist_for: "20 minutes"
}
