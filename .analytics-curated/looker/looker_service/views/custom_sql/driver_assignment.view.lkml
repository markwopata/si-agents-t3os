view: driver_assignment {
  derived_table: {
    sql: select
    a.asset_id,
    da.operator_name as dashcam_driver,
    concat(uda.first_name,' ',uda.last_name) as elogs_driver,
    concat(u.first_name,' ',u.last_name) as asset_status_key_values_driver,
    concat(ut.first_name,' ',ut.last_name) as driver_portal_driver
from es_warehouse.public.assets a
left join analytics.fleetcam.driver_assignments da
    on a.asset_id = da.asset_id
    and current_assignment
left join es_warehouse.elogs.driver_asset_pairing_history daph
    on a.asset_id = daph.asset_id
    and daph.end_date is null
-- left join es_warehouse.public.asset_statuses aas
--     on a.asset_id = aas.asset_id
left join ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES as ASKV
    on a.ASSET_ID = askv.ASSET_ID
    and askv.NAME = 'driver_user_id'
left join es_warehouse.public.users u
    on askv.VALUE = u.user_id
left join sworks.vehicle_usage_tracker.user_asset_assignments uaa
    on uaa.asset_id = a.asset_id
    and uaa.end_date is null
left join es_warehouse.public.users ut
    on ut.user_id = uaa.user_id
left join es_warehouse.public.users uda
    on daph.driver_id = uda.user_id;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }
  dimension: dashcom_driver {
    type: string
    sql: ${TABLE}."DASHCAM_DRIVER" ;;
  }
  dimension: elogs_driver {
    type: string
    sql: ${TABLE}."ELOGS_DRIVER" ;;
  }
  dimension: asset_status_key_values_driver {
    type: string
    sql: ${TABLE}."ASSET_STATUS_KEY_VALUES_DRIVER" ;;
  }
  dimension: driver_portal_driver {
    type: string
    sql: ${TABLE}."DRIVER_PORTAL_DRIVER" ;;
  }
  dimension: driver_assignment {
    type: string
    sql: coalesce(${elogs_driver},${dashcom_driver},${asset_status_key_values_driver}) ;;
  }
  dimension: driver_assignment_sources {
    type: string
    sql: case
          when ${elogs_driver} is not null then 'Elogs'
          when ${dashcom_driver} is not null then 'Fleetcam'
          when ${asset_status_key_values_driver} is not null then 'Asset_Status_Key_Value'
          else null
          end;;
  }
}
