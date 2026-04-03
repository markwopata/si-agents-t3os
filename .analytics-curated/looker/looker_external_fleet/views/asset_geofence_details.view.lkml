view: asset_geofence_details {
  derived_table: {
    sql:
with owned_rented_assets as (
    select ORA.asset_id, -1 as purchase_order_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric)) ORA
    left join organization_asset_xref oax on ORA.asset_id = oax.asset_id
    left join organizations og on oax.organization_id = og.organization_id and og.company_id = {{ _user_attributes['company_id'] }}::numeric
    where
    {% condition groups_filter %} coalesce(og.name, 'Ungrouped Assets') {% endcondition %}
    union
    select RL.asset_id, o.purchase_order_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    --convert_timezone(('UTC','{{ _user_attributes['user_timezone'] }}'), {% date_start date_filter %}),
    --convert_timezone(('UTC','{{ _user_attributes['user_timezone'] }}'), {% date_end date_filter %}),
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
    ('{{ _user_attributes['user_timezone'] }}'))) RL
        join rentals R on R.rental_id = RL.rental_id
        join orders o on O.order_id = R.order_id
        join assets a on a.asset_id = rl.asset_id
        left join organization_asset_xref oax on RL.asset_id = oax.asset_id
        left join organizations og on oax.organization_id = og.organization_id and og.company_id = {{ _user_attributes['company_id'] }}::numeric
    where
    a.company_id <> {{ _user_attributes['company_id'] }}
    AND {% condition groups_filter %} coalesce(og.name, 'Ungrouped Assets') {% endcondition %}
   )
  , geo_duration as (
  select ge.asset_id,
    o.purchase_order_id,
    g.geofence_id,
    ge.encounter_start_timestamp as entry,
    ge.encounter_end_timestamp as exit,
    ge.start_odometer,
    ge.end_odometer,
    case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and (ge.encounter_end_timestamp is null or ge.encounter_end_timestamp > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
       when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and ge.encounter_end_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), ge.encounter_end_timestamp)
       when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and ge.encounter_end_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
       when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) then
          case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
             when ge.encounter_end_timestamp >  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp,  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           end
             else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
        end as geo_seconds
  from asset_geofence_encounters ge left join geofences g on ge.geofence_id = g.geofence_id
    join owned_rented_assets o on o.asset_id = ge.asset_id
  where g.company_id = '{{ _user_attributes['company_id'] }}'::numeric
      and ge.encounter_start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      and coalesce(ge.encounter_end_timestamp, current_timestamp()) >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
  )
  , geo_duration_with_hours as (
   select gd.*, min(ascd_entry.hours) as entry_hours, max(ascd_exit.hours) as exit_hours
   from geo_duration gd
    left join scd.scd_asset_hours ascd_entry on ascd_entry.asset_id = gd.asset_id and gd.entry between ascd_entry.date_start and ascd_entry.date_end
    left join scd.scd_asset_hours ascd_exit on ascd_exit.asset_id = gd.asset_id and  coalesce(gd.exit, {% date_end date_filter %}) between ascd_exit.date_start and coalesce(ascd_exit.date_end, {% date_end date_filter %})
   GROUP BY gd.asset_id, gd.purchase_order_id, geofence_id, entry, exit, start_odometer, end_odometer, geo_seconds
  )
  , trip_data as (
  select DISTINCT T.trip_id, t.asset_id, t.start_timestamp as trip_start, coalesce(t.end_timestamp, current_timestamp) as trip_end, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours, g.purchase_order_id
  from trips t join geo_duration_with_hours g on g.asset_id=t.asset_id
  where t.start_timestamp
        <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
  and coalesce(t.end_timestamp, current_timestamp)
        >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
  and TIMESTAMPDIFF(seconds, t.start_timestamp, coalesce(t.end_timestamp, current_timestamp)) <= 604800
  )
   , idle_data as (
  select distinct i.asset_id, start_timestamp as idle_start, end_timestamp as idle_end, duration_seconds as idle_seconds, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours, al.purchase_order_id
  from asset_idles i
    join geo_duration_with_hours g on g.asset_id=i.asset_id
    join owned_rented_assets al on al.asset_id = i.asset_id
    where i.start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    and coalesce(i.end_timestamp, current_timestamp) >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
  )
 , geo_trip_join as (
  select distinct gd.asset_id, gd.purchase_order_id, gd.geofence_id, gd.entry, gd.exit, gd.geo_seconds, td.trip_start, td.trip_end, gd.start_odometer, gd.end_odometer, gd.entry_hours, gd.exit_hours,
  case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) > coalesce(exit,current_timestamp) then
      case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
         when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) or trip_end >= coalesce(exit,current_timestamp))) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
         when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
         when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
         when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
      end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) > coalesce(exit,current_timestamp)) then
        case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}))
           when (trip_start <= entry and (trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',  {% date_end date_filter %}) or trip_end >= exit)) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), exit)
           when (trip_start < entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), trip_end)
           when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, coalesce(exit,current_timestamp))
           when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, trip_start, trip_end)
        end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) <= entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
        case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, trip_end)
           when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
           when (trip_start > entry and trip_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,trip_start, coalesce(exit, current_timestamp))
        end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
        case when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start <= entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start <= entry and trip_end < coalesce(exit,current_timestamp) and trip_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', {% date_start date_filter %}), trip_end)
           when (trip_start > entry and trip_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and trip_end > exit) then TIMESTAMPDIFF(seconds,trip_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_start >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and trip_end <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, trip_end)
           when (trip_start > entry and trip_end < coalesce(exit,current_timestamp) and trip_end > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,trip_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (trip_start > entry and trip_end < coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), trip_end)
        end
  end as geo_trip_seconds
  from geo_duration_with_hours gd left join trip_data td on gd.asset_id = td.asset_id
      and td.trip_start <= coalesce(gd.exit, current_timestamp()) and gd.entry <= td.trip_end
  )
  , geo_trip_sum as (
  select distinct asset_id, purchase_order_id, geofence_id, entry, exit, start_odometer, end_odometer, entry_hours, exit_hours,
          coalesce(round((geo_seconds::decimal/3600), 2),0) as geo_hrs,
          coalesce(round((sum(geo_trip_seconds::decimal)/3600), 2),0) as tot_geo_trip_hrs
  from geo_trip_join
  group by asset_id, purchase_order_id, geofence_id, entry, exit, geo_seconds, start_odometer, end_odometer, entry_hours, exit_hours
  )
  , geo_idles_join as (
  select distinct gt.asset_id, gt.purchase_order_id, gt.geofence_id, gt.entry, gt.exit, geo_hrs, gt.tot_geo_trip_hrs,
    id.idle_start, id.idle_end, id.idle_seconds,  gt.start_odometer, gt.end_odometer, gt.entry_hours, gt.exit_hours,
    case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) < entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) > coalesce(exit,current_timestamp) then
      case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
         when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, entry, coalesce(exit,current_timestamp))
         when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
         when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
         when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
         when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,idle_start, idle_end)
      end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) > entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) > coalesce(exit,current_timestamp) then
        case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) or idle_end >= coalesce(exit,current_timestamp) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), coalesce(exit,current_timestamp))
           when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), idle_end)
           when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, exit)
           when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
        end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) <= entry and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) <= coalesce(exit,current_timestamp) then
        case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, entry, idle_end)
           when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start > entry and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
        end
       when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) > entry and (convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) <= coalesce(exit,current_timestamp)) then
        case when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start <= entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) THEN TIMESTAMPDIFF(seconds, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start <= entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
           when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and exit is null) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start > entry and idle_end >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}) and idle_end > coalesce(exit,current_timestamp)) then TIMESTAMPDIFF(seconds, idle_start, convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}))
           when (idle_start > entry and idle_end < coalesce(exit,current_timestamp) and idle_end < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})) then TIMESTAMPDIFF(seconds, idle_start, idle_end)
        end
      end as geo_idle_seconds
  from geo_trip_sum gt left join idle_data id on gt.asset_id = id.asset_id
        and id.idle_start <= coalesce(gt.exit, current_timestamp)
        and gt.entry <= coalesce(id.idle_end, current_timestamp)
  )
  select distinct g.asset_id, g.purchase_order_id, g.geofence_id,
    convert_timezone('{{ _user_attributes['user_timezone'] }}', g.entry) AS entry,
    convert_timezone('{{ _user_attributes['user_timezone'] }}', g.exit) as exit,
    geo_hrs,
    tot_geo_trip_hrs,  g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours,
    coalesce(round(sum(geo_idle_seconds/3600)::decimal, 2),0.00) as tot_geo_idle_hrs
  from geo_idles_join g
  group by g.asset_id, g.purchase_order_id, g.geofence_id, entry, exit, geo_hrs, tot_geo_trip_hrs,  g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours
  ;;
}
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${geofence_id});;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  filter: date_filter {
    type: date_time
    default_value: "this day"
  }

  filter: groups_filter {
    type: string
  }

  dimension: entry {
    label: "Entry Time"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."ENTRY") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }


  dimension: exit {
    label: "Exit Time"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."EXIT") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: geo_hrs {
    label: "Hours in Geofence"
    type: number
    sql: ${TABLE}."GEO_HRS" ;;
  }

  dimension: tot_geo_trip_hrs {
    label: "Run Time (Hrs)"
    type: number
      sql: ${TABLE}."TOT_GEO_TRIP_HRS" ;;
  }

  dimension: tot_geo_idle_hrs {
    label: "Idle Hours"
    type: number
    sql: ${TABLE}."TOT_GEO_IDLE_HRS" ;;
  }

  dimension: start_odometer {
    type: number
      sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: end_odometer {
    type: number
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: entry_hours {
    label: "Entry Asset Hours"
    type: number
    sql: ${TABLE}."ENTRY_HOURS" ;;
  }

  dimension: exit_hours {
    label: "Exit Asset Hours"
    type: number
    sql: ${TABLE}."EXIT_HOURS" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  measure: hrs_in_geofence_fmt {
    sql: CONCAT(FLOOR(${hrs_in_geofence}), 'h ', ROUND(((${hrs_in_geofence} - FLOOR(${hrs_in_geofence})) * 60)), 'm') ;;
  }

  measure: hrs_in_geofence {
    label: "Hours in Geofence"
    type: sum
    sql: ${geo_hrs} ;;
    html:  {{hrs_in_geofence_fmt._rendered_value}} ;;
  }

  measure: run_time_fmt {
    sql: CONCAT(FLOOR(${run_time}), 'h ', ROUND(((${run_time} - FLOOR(${run_time})) * 60)), 'm') ;;
  }


  measure: run_time {
    label: "Run Hours"
    type: sum
    sql: ${tot_geo_trip_hrs} ;;
    html:  {{run_time_fmt._rendered_value}} ;;
  }

  measure: idle_time_fmt {
    sql: CONCAT(FLOOR(${idle_time}), 'h ', ROUND(((${idle_time} - FLOOR(${idle_time})) * 60)), 'm') ;;
  }


  measure: idle_time {
    label: "Idle Hours"
    type: sum
    sql: ${tot_geo_idle_hrs} ;;
    html:  {{idle_time_fmt._rendered_value}} ;;
  }


  set: detail {
    fields: [asset_id, entry, exit, geo_hrs, tot_geo_trip_hrs, tot_geo_idle_hrs, start_odometer, end_odometer, entry_hours, exit_hours, geofence_id]
  }

}
