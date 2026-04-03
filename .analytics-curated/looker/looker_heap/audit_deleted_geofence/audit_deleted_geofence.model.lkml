connection: "es_snowflake_analytics"

include: "/audit_deleted_geofence/*.view.lkml"

explore: geofence_delete_audit {
  group_label: "Heap T3 Platform"
  label: "Audit of Geofence Deletion"
  case_sensitive: no
  persist_for: "8 hours"
}
