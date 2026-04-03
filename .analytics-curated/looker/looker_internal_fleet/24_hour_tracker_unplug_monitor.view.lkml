view: 24_hour_tracker_unplug_monitor {
  derived_table: {
    sql: with unplugs_cte as (
          select ti.TRACKING_EVENT_ID
                , a.asset_id
               , a.inventory_branch_id
               , sais.asset_inventory_status
               , ti.report_timestamp::timestamp as incident_timestamp
               --,convert_timezone('America/Chicago', ti.report_timestamp) as incident_timestamp
               , ti.tracking_incident_type_id       as install_or_unplug
               , mrx.market_name
               , sais.current_flag
               , te.location_lat
               , te.location_lon
          from es_warehouse.public.assets a
                   left join es_warehouse.scd.scd_asset_inventory_status sais
                             on a.asset_id = sais.asset_id
                   left join es_warehouse.public.tracking_incidents ti
                             on sais.asset_id = ti.asset_id
                   left join es_warehouse.public.markets m
                             on a.inventory_branch_id = m.market_id
                   left join analytics.public.market_region_xwalk mrx
                             on m.market_id = mrx.market_id
                   left join es_warehouse.public.tracking_events te
                             on ti.tracking_event_id = te.tracking_event_id
          where ti.report_timestamp >= current_date - interval '24 hours'
              and te.report_timestamp >= current_date - interval '24 hours'
              and a.asset_type_id = 1
              and deleted = 'no'
              and a.company_id = 1854
              and sais.current_flag = 1
              and ti.tracking_incident_type_id in (9, 10)
      )
      select
            u.asset_id
           , u.inventory_branch_id
           , u.market_name
           , u.asset_inventory_status
           --, u.incident_timestamp
           ,date_trunc('minute',u.incident_timestamp) as incident_timestamp
           ,concat( u.location_lat, ',' , u.location_lon) as gps_location
      from unplugs_cte u
      WHERE u.TRACKING_EVENT_ID in (SELECT max(TRACKING_EVENT_ID) FROM unplugs_cte GROUP BY ASSET_ID)
      and u.install_or_unplug = 10
      order by u.incident_timestamp desc
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

  dimension: current_date {
    type: date
    sql: CURRENT_DATE + 1 ;;
  }

  dimension: track_link {
    label: "Track Link"
    type: string
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{asset_id}}/history?selectedDate={{current_date}}" target="_blank">Track Link</a></font></u> ;;
    sql: ${asset_id}  ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension_group: incident_timestamp {
    type: time
    sql: ${TABLE}."INCIDENT_TIMESTAMP" ;;
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
    fields: [
      asset_id,
      inventory_branch_id,
      market_name,
      asset_inventory_status,
      incident_timestamp_time,
      gps_location
    ]
  }
}
