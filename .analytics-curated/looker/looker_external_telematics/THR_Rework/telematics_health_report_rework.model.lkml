connection: "reportingc_warehouse"

include: "/THR_Rework/views/*.view.lkml"
include: "/views/*.view.lkml"

# datagroup: telematics_health_data_update {
#   sql_trigger: select max(DATA_REFRESH_TIMESTAMP) from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__TELEMATICS_HEALTH ;;
#   max_cache_age: "6 hours"
#   description: "Looking at triage.telematics_health for latest data update. Will update data when it detects a new update time."
# }


explore: telematics_health_report {
  group_label: "Telematics"
  label: "Telematics Health Report"
  case_sensitive: no

}


explore: stg_t3__asset_info {
  group_label: "Telematics"
  label: "New Telematics Health Report"
  case_sensitive: no
  sql_always_where: ${stg_t3__asset_info.company_id} = {{ _user_attributes['company_id'] }}::numeric OR ${stg_t3__on_rent.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;

  join: stg_t3__telematics_health {
    type: inner
    relationship: one_to_one
    sql_on: ${stg_t3__asset_info.asset_id} = ${stg_t3__telematics_health.asset_id} ;;
  }

  join: stg_t3__on_rent {
    type: left_outer
    relationship: one_to_one
    sql_on: ${stg_t3__telematics_health.asset_id} = ${stg_t3__on_rent.asset_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_t3__asset_info.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }

}
