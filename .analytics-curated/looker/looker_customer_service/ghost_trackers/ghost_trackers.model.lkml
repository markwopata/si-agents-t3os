connection: "es_snowflake_analytics"

include: "/dbt_views/*.view.lkml"
include: "/ghost_trackers/*.view.lkml"

explore: ghosts_trackers_notes {
  label: "Ghost Tracker Records & Notes"
  always_filter: {filters: [date_filter: "this year"]}
  join: stg_t3__asset_info {
    relationship: many_to_one
    sql_on: ${ghosts_trackers_notes.asset} = ${stg_t3__asset_info.asset_id} ;;
  }
  join: stg_t3__telematics_health {
    relationship: one_to_one
    sql_on: ${ghosts_trackers_notes.tracker_sn} = ${stg_t3__telematics_health.ghost_tracker_serial} ;;
  }
}
