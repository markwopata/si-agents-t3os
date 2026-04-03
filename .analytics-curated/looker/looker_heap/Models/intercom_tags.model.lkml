connection: "es_snowflake"

include: "/views/ANALYTICS/intercom_tags.view.lkml"

explore: intercom_tags {
  group_label: "Intercom Tags"
  case_sensitive: no
  }
