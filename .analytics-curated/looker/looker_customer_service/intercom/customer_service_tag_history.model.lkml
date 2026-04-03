connection: "es_snowflake_analytics"

include: "/intercom/*.view.lkml"

explore: intercom_tag_history {
  group_label: "Customer Service"
  case_sensitive: no
   }
