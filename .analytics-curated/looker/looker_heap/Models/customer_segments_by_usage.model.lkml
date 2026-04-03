connection: "es_snowflake"

include: "/views/customer_segments_by_usage.view.lkml"
include: "/views/VIP_Customer_Initiative/heap_users.view.lkml"

explore: customer_segments_by_T3_usage {
  group_label: "Customer "
  label: "T3 Company Usage"
  case_sensitive: no
}
