connection: "es_snowflake_analytics"

include: "/customer_mimic/*.view.lkml"

explore: customer_mimic {
  group_label: "Customer Mimic"
  label: "Customer Mimic"
  description: "Allow users to mimic into customers T3 Accounts"
  case_sensitive: no
  persist_for: "8 hours"
}
