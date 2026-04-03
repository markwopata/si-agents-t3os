connection: "es_warehouse"

include: "/views/work_order_calendar.view.lkml"

explore: work_order_calendar {
  group_label: "Service"
  label: "Work Order Calendar"
  case_sensitive: no
}
