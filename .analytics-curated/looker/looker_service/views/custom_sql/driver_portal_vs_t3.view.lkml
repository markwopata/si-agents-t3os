view: driver_portal_vs_t3 {
  derived_table: {
    sql: select
    coalesce(foa.asset_id,uaa.asset_id) as asset_id,
    foa.user_id as t3_user_id,
    foa.operator_name as t3,
    uaa.user_id as driver_portal_user_id,
    concat(ut.first_name,' ',ut.last_name) as driver_portal
from business_intelligence.gold.fact_operator_assignments foa
left join sworks.vehicle_usage_tracker.user_asset_assignments uaa
    on uaa.asset_id = foa.asset_id
    and uaa.end_date is null
left join es_warehouse.public.users ut
    on ut.user_id = uaa.user_id
where foa.current_assignment
and (foa.user_id != uaa.user_id or foa.user_id is null or uaa.user_id is null)
and coalesce(foa.user_id,uaa.user_id,0) != 0 ;;
  }

  dimension: asset_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: driver_portal_user_id{
    type: number
    sql: ${TABLE}."DRIVER_PORTAL_USER_ID" ;;
    value_format: "0"
  }

  dimension: driver_portal_driver {
    type: string
    sql: ${TABLE}."DRIVER_PORTAL" ;;
  }

  dimension: driver_portal_link {
    type: string
    sql: 'Driver Portal Assignment Link' ;;
    html: <font color="blue "><u><a href="https://tools.equipmentshare.com/assign-drivers" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: t3_user_id{
    type: number
    sql: ${TABLE}."T3_USER_ID" ;;
    value_format: "0"
  }

  dimension: t3_driver {
    type: string
    sql: ${TABLE}."T3" ;;
  }

  dimension: t3_driver_link {
    type: string
    sql: 'T3 Driver Assignment Link' ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/edit?returnTo=/assets/assets/" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  measure: count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id,assets.asset_class,assets.make,assets.model,market_region_xwalk.market_name,market_region_xwalk.market_id,driver_portal_link,driver_portal_driver,t3_driver,t3_driver_link]
  }
}
