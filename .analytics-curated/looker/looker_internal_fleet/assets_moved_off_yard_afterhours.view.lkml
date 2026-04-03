view: assets_moved_off_yard_afterhours {
  derived_table: {
    sql: with unplugs_cte as(
      select
      a.asset_id
      ,a.inventory_branch_id
      ,m.name as branch_location
      ,ti.tracking_incident_type_id
      --,convert_timezone('America/Chicago', ti.report_timestamp) as date_time_moved_from_area
      ,ti.report_timestamp::timestamp_ntz as date_time_moved_from_area
      ,sais.asset_inventory_status
      ,te.location_lat
      ,te.location_lon
      ,te.tracking_event_id
      from es_warehouse.public.assets a
      left join es_warehouse.public.markets m
        on a.inventory_branch_id = m.market_id
      left join es_warehouse.public.tracking_incidents ti
        on a.asset_id = ti.asset_id
      left join analytics.public.market_region_xwalk mrx
        on m.market_id = mrx.market_id
      left join es_warehouse.scd.scd_asset_inventory_status sais
        on a.asset_id = sais.asset_id
      left join es_warehouse.public.tracking_events te
        on ti.tracking_event_id = te.tracking_event_id
      where a.asset_type_id = 1
      and a.company_id = 1854
      and deleted = 'no'
      and sais.asset_inventory_status <> 'On Rent'
      and ti.tracking_incident_type_id = 1
      and te.report_timestamp >= current_date - interval '48 hours'
      and ti.report_timestamp >= current_date - interval '48 hours'
      group by
      a.asset_id
      ,a.inventory_branch_id
      ,ti.tracking_incident_type_id
      ,ti.report_timestamp
      ,m.name
      ,sais.asset_inventory_status
      ,te.location_lat
      ,te.location_lon
      ,te.tracking_event_id
      )
      select
      u.asset_id
      --,max(u.date_time_moved_from_area) as date_time_moved_from_area
      ,date_trunc('minute', max(u.date_time_moved_from_area)) as date_time_moved_from_area
      ,u.inventory_branch_id
      ,u.branch_location
      ,concat(u.location_lat, ',' , u.location_lon) as gps_location
      from unplugs_cte u
      where u.tracking_event_id in (select max(tracking_event_id) from unplugs_cte group by asset_id)
      and date_part('hour',u.date_time_moved_from_area) in (19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6)
      group by
      u.asset_id
      ,u.inventory_branch_id
      ,u.branch_location
      ,u.location_lat
      ,u.location_lon
      order by asset_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: track_link {
    label: "Track Link"
    type: string
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{asset_id}}/history?selectedDate={{"date"}}" target="_blank">Track Link</a></font></u> ;;
    sql: ${asset_id}  ;;
  }

  dimension_group: date_time_moved_from_area {
    type: time
    sql: ${TABLE}."DATE_TIME_MOVED_FROM_AREA" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: branch_location {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION" ;;
  }

  dimension: gps_location {
    type: string
    html: <a href="https://www.google.com/maps/search/?api=1&query={{ value | url_encode}}" target="_blank">Click to View in Maps<a/> ;;
    sql: ${TABLE}."GPS_LOCATION" ;;

  link: {
    label: "View Google Maps Location"
    url: "https://www.google.com/maps/search/?api=1&query={{ value | url_encode}}"
  }
}
  set: detail {
    fields: [asset_id, date_time_moved_from_area_time, inventory_branch_id, branch_location, gps_location]
  }
}
