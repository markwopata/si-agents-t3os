connection: "es_warehouse"

include: "/views/gearfax/gearfax.view.lkml"
include: "/views/gearfax/selection_of_all_assets.view.lkml"

explore: gearfax {
  group_label: "Service"
  label: "Gearfax"
  case_sensitive: no
}

explore: selection_of_all_assets {
  group_label: "Service"
  label: "All Asset List"
  case_sensitive: no
}
