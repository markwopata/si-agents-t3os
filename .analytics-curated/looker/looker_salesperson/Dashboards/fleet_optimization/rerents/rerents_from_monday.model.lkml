connection: "es_snowflake_analytics"

include: "./*.view.lkml"

explore: rerents_from_monday {
  group_label: "Re-Rents from Monday"
  label: "Re-Rents from Monday"
  case_sensitive: no
}

explore: rerents_status_snapshot {

  group_label: "Re-Rent Status PIT"
  label: "Re-Rent Status PIT"
  case_sensitive: no

}
