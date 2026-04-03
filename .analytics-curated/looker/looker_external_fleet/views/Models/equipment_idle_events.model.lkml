connection: "es_warehouse"

include: "/views/*.view.lkml"

datagroup: by_day_util_update {
  sql_trigger: select max(data_refresh_timestamp) from business_intelligence.triage.stg_t3__by_day_utilization ;;
  max_cache_age: "4 hours"
}

explore: equipment_idle_report {
  sql_always_where: ${asset_id} in ${equipment_idle_report.asset_id};;
  group_label: "Fleet"
  label: "Equipment Idle Events"
  case_sensitive: no
  persist_with: by_day_util_update

}
