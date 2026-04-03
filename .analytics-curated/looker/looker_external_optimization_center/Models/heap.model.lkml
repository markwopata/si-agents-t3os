connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: heap_activity {
  group_label: "HEAP"
  label: "Heap User Activity"
  case_sensitive: no
}

explore: heap_app_path {
  group_label: "HEAP"
  label: "Heap User Path Activity"
  case_sensitive: no
}
