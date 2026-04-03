view: asset_moved_off_yard_past_48hours {
  derived_table: {
    sql: with unplugs_cte as(
select
a.asset_id
,a.inventory_branch_id
,m.name as branch_location
,ti.tracking_incident_type_id
,convert_timezone('America/Chicago', ti.report_timestamp)::timestamp_tz as date_time_moved_from_area
--,convert_timezone('America/Chicago', age.encounter_time_range:end_range)::timestamp_tz as time_left_area
,age.encounter_time_range:end_range::timestamp_tz as time_left_area
,age.asset_geofence_encounter_id
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
left join es_warehouse.public.asset_geofence_encounters age
on age.asset_id = a.asset_id
left join es_warehouse.public.geofences g
on age.geofence_id = g.geofence_id
where a.asset_type_id = 1
and a.company_id = 1854
and a.deleted = 'no'
and sais.asset_inventory_status <> 'On Rent'
and ti.tracking_incident_type_id = 1
and te.report_timestamp >= current_date - interval '48 hours'
and ti.report_timestamp >= current_date - interval '48 hours'
and g.company_id = 1854
and age.encounter_time_range:end_range is not null
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
,age.encounter_time_range:end_range
,age.asset_geofence_encounter_id
)
,on_delivery_check as(
select
o.ORDER_ID
,r.RENTAL_ID
,a.ASSET_ID
,r.DROP_OFF_DELIVERY_ID
,r.RETURN_DELIVERY_ID
,d.DATE_CREATED
,d.COMPLETED_DATE
,case when current_timestamp::date between d.DATE_CREATED::date and d.COMPLETED_DATE::date
  then 'Yes'
  else 'No'
  end as possible_delivery
from ES_WAREHOUSE.PUBLIC.DELIVERIES as d
left join ES_WAREHOUSE.PUBLIC.orders as o
on d.order_id = o.ORDER_ID
left join ES_WAREHOUSE.PUBLIC.rentals as r
on o.ORDER_ID = r.ORDER_ID
left join ES_WAREHOUSE.PUBLIC.assets as a
on r.ASSET_ID = a.ASSET_ID
where current_timestamp::date between d.DATE_CREATED::date and d.COMPLETED_DATE::date
)
select
u.asset_id
,odc.possible_delivery
,date_trunc('minute', max(u.time_left_area)) as time_left_area
,u.inventory_branch_id
,u.branch_location
,concat(u.location_lat, ',' , u.location_lon) as gps_location
from unplugs_cte u
left join on_delivery_check odc
on u.asset_id = odc.asset_id
where u.tracking_event_id in (select max(tracking_event_id) from unplugs_cte group by asset_id)
and u.asset_geofence_encounter_id in (select max(asset_geofence_encounter_id) from unplugs_cte group by asset_id)
and date_part('hour',u.date_time_moved_from_area) in (19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6)
group by
u.asset_id
,odc.possible_delivery
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

  dimension: delivery_check {
    type: string
    sql: ${TABLE}."DELIVERY_CHECK" ;;
  }

  dimension_group: time_left_area {
    type: time
    sql: ${TABLE}."TIME_LEFT_AREA" ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: branch_location {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION" ;;
  }

  dimension: possible_delivery {
    type: string
    sql: ${TABLE}."POSSIBLE_DELIVERY" ;;
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
      delivery_check,
      time_left_area_time,
      inventory_branch_id,
      branch_location,
      gps_location
    ]
  }
}
