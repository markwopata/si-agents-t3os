view: asset_geofence_details {
  derived_table: {
    sql:
    with date_params as (
        select 
            convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz) as date_start_utc,
            convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz) as date_end_utc
    )
    , owned_rented_assets as (
        select a.asset_id
        from assets a
            join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
        union
        select a.asset_id
        from assets a
            join date_params dp on 1=1
            join table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, dp.date_start_utc, dp.date_end_utc, ('{{ _user_attributes['company_timezone'] }}'))) R on R.asset_id = a.asset_id
       )
      , geo_duration as (
      select ge.asset_id,
        g.geofence_id,
        ge.encounter_start_timestamp as entry,
        ge.encounter_end_timestamp as exit,
        ge.start_odometer,
        ge.end_odometer,
        dp.date_start_utc,
        dp.date_end_utc,
        case when ge.encounter_start_timestamp < dp.date_start_utc and (ge.encounter_end_timestamp is null or ge.encounter_end_timestamp > dp.date_end_utc) then TIMESTAMPDIFF(seconds, dp.date_start_utc, dp.date_end_utc)
           when ge.encounter_start_timestamp < dp.date_start_utc and ge.encounter_end_timestamp between dp.date_start_utc and dp.date_end_utc then TIMESTAMPDIFF(seconds, dp.date_start_utc, ge.encounter_end_timestamp)
           when ge.encounter_start_timestamp >= dp.date_start_utc and ge.encounter_end_timestamp <= dp.date_end_utc then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
           when ge.encounter_start_timestamp between dp.date_start_utc and dp.date_end_utc then
              case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, dp.date_end_utc)
                 when ge.encounter_end_timestamp > dp.date_end_utc then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, dp.date_end_utc)
               end
                 else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
            end as geo_seconds
      from date_params dp
      cross join asset_geofence_encounters ge 
      left join geofences g on ge.geofence_id = g.geofence_id
        join owned_rented_assets o on o.asset_id = ge.asset_id
      where g.company_id = '{{ _user_attributes['company_id'] }}'::numeric
          and overlaps(ge.encounter_start_timestamp, coalesce(ge.encounter_end_timestamp, current_timestamp), dp.date_start_utc, dp.date_end_utc)
      )
      , geo_duration_with_hours as (
       select gd.*, min(ascd_entry.hours) as entry_hours, max(ascd_exit.hours) as exit_hours
       from geo_duration gd
        left join scd.scd_asset_hours ascd_entry on ascd_entry.asset_id = gd.asset_id and gd.entry between ascd_entry.date_start and ascd_entry.date_end
        left join scd.scd_asset_hours ascd_exit on ascd_exit.asset_id = gd.asset_id and coalesce(gd.exit, gd.date_end_utc) between ascd_exit.date_start and coalesce(ascd_exit.date_end, gd.date_end_utc)
       GROUP BY gd.asset_id, gd.geofence_id, gd.entry, gd.exit, gd.start_odometer, gd.end_odometer, gd.geo_seconds, gd.date_start_utc, gd.date_end_utc
      )
      , trip_data as (
      select distinct T.trip_id, t.asset_id, t.start_timestamp as trip_start, coalesce(t.end_timestamp, current_timestamp) as trip_end, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours, g.date_start_utc, g.date_end_utc
      from geo_duration_with_hours g
      join trips t on g.asset_id = t.asset_id
      where overlaps(t.start_timestamp, coalesce(t.end_timestamp, current_timestamp), g.date_start_utc, g.date_end_utc)
        and t.start_timestamp < g.date_end_utc
        and TIMESTAMPDIFF(seconds, t.start_timestamp, coalesce(t.end_timestamp, current_timestamp)) <= 604800
      )
      , idle_data as (
      select distinct i.asset_id, i.start_timestamp as idle_start, i.end_timestamp as idle_end, i.duration_seconds as idle_seconds, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours, g.date_start_utc, g.date_end_utc
      from asset_idles i 
      join geo_duration_with_hours g on g.asset_id = i.asset_id
      where OVERLAPS(i.start_timestamp, coalesce(i.end_timestamp, current_timestamp), g.date_start_utc, g.date_end_utc)
      )
     , geo_trip_join as (
      select gd.asset_id, gd.geofence_id, gd.entry, gd.exit, gd.geo_seconds, td.trip_start, td.trip_end, gd.start_odometer, gd.end_odometer, gd.entry_hours, gd.exit_hours, gd.date_start_utc, gd.date_end_utc,
      case when gd.date_start_utc < gd.entry and gd.date_end_utc > coalesce(gd.exit,current_timestamp) then
          case when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, gd.entry, gd.date_end_utc)
             when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc) or (td.trip_end >= coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, gd.entry, coalesce(gd.exit,current_timestamp))
             when (td.trip_start <= gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp) and td.trip_end < gd.date_end_utc) then TIMESTAMPDIFF(seconds, gd.entry, td.trip_end)
             when (td.trip_start > gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, td.trip_start, gd.date_end_utc)
             when (td.trip_start > gd.entry and td.trip_end > coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, coalesce(gd.exit,current_timestamp))
          end
           when gd.date_start_utc > gd.entry and gd.date_end_utc > coalesce(gd.exit,current_timestamp) then
            case when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, gd.date_start_utc, gd.date_end_utc)
               when (td.trip_start <= gd.entry and (td.trip_end >= gd.date_end_utc or td.trip_end >= gd.exit)) then TIMESTAMPDIFF(seconds, gd.date_start_utc, gd.exit)
               when (td.trip_start < gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp) and td.trip_end < gd.date_end_utc) then TIMESTAMPDIFF(seconds, gd.date_start_utc, td.trip_end)
               when (td.trip_start > gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, td.trip_start, gd.date_end_utc)
               when (td.trip_start > gd.entry and td.trip_end > coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, coalesce(gd.exit,current_timestamp))
               when (td.trip_start > gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, td.trip_end)
            end
           when gd.date_start_utc <= gd.entry and gd.date_end_utc <= coalesce(gd.exit,current_timestamp) then
            case when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, gd.entry, gd.date_end_utc)
               when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc) then TIMESTAMPDIFF(seconds, gd.entry, gd.date_end_utc)
               when (td.trip_start <= gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp) and td.trip_end < gd.date_end_utc) then TIMESTAMPDIFF(seconds, gd.entry, td.trip_end)
               when (td.trip_start > gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, td.trip_start, gd.date_end_utc)
               when (td.trip_start > gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, td.trip_end)
               when (td.trip_start > gd.entry and td.trip_end > coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, coalesce(gd.exit, current_timestamp))
            end
           when gd.date_start_utc > gd.entry and gd.date_end_utc <= coalesce(gd.exit,current_timestamp) then
            case when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, gd.date_start_utc, gd.date_end_utc)
               when (td.trip_start <= gd.entry and td.trip_end >= gd.date_end_utc) then TIMESTAMPDIFF(seconds, gd.date_start_utc, gd.date_end_utc)
               when (td.trip_start <= gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp) and td.trip_end < gd.date_end_utc) then TIMESTAMPDIFF(seconds, td.trip_start, td.trip_end)
               when (td.trip_start > gd.entry and td.trip_end >= gd.date_end_utc and gd.exit is null) then TIMESTAMPDIFF(seconds, td.trip_start, gd.date_end_utc)
               when (td.trip_start > gd.entry and td.trip_end >= gd.date_end_utc and td.trip_end > gd.exit) then TIMESTAMPDIFF(seconds, td.trip_start, gd.date_end_utc)
               when (td.trip_start > gd.entry and td.trip_end < coalesce(gd.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, td.trip_start, td.trip_end)
            end
      end as geo_trip_seconds
      from geo_duration_with_hours gd 
      left join trip_data td on gd.asset_id = td.asset_id
          and overlaps(td.trip_start, td.trip_end, gd.entry, coalesce(gd.exit,current_timestamp))
      )
      , geo_trip_sum as (
      select asset_id, geofence_id, entry, exit, start_odometer, end_odometer, entry_hours, exit_hours,
              coalesce(round((geo_seconds::decimal/3600), 2),0) as geo_hrs,
              coalesce(round((sum(geo_trip_seconds::decimal)/3600), 2),0) as tot_geo_trip_hrs
      from geo_trip_join
      group by asset_id, geofence_id, entry, exit, geo_seconds, start_odometer, end_odometer, entry_hours, exit_hours
      )
      , geo_idles_join as (
      select gt.asset_id, gt.geofence_id, gt.entry, gt.exit, geo_hrs, gt.tot_geo_trip_hrs,
        id.idle_start, id.idle_end, id.idle_seconds, gt.start_odometer, gt.end_odometer, gt.entry_hours, gt.exit_hours, id.date_start_utc, id.date_end_utc,
        case when id.date_start_utc < gt.entry and id.date_end_utc > coalesce(gt.exit,current_timestamp) then
          case when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, gt.entry, id.date_end_utc)
             when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc) or id.idle_end >= coalesce(gt.exit,current_timestamp) then TIMESTAMPDIFF(seconds, gt.entry, coalesce(gt.exit,current_timestamp))
             when (id.idle_start <= gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, gt.entry, id.idle_end)
             when (id.idle_start > gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
             when (id.idle_start > gt.entry and id.idle_end > coalesce(gt.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, id.idle_start, gt.exit)
             when (id.idle_start > gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.idle_start, id.idle_end)
          end
           when id.date_start_utc > gt.entry and id.date_end_utc > coalesce(gt.exit,current_timestamp) then
            case when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.date_start_utc, id.date_end_utc)
               when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc) or id.idle_end >= coalesce(gt.exit,current_timestamp) then TIMESTAMPDIFF(seconds, id.date_start_utc, coalesce(gt.exit,current_timestamp))
               when (id.idle_start <= gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.date_start_utc, id.idle_end)
               when (id.idle_start > gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
               when (id.idle_start > gt.entry and id.idle_end > coalesce(gt.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, id.idle_start, gt.exit)
               when (id.idle_start > gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.idle_start, id.idle_end)
            end
           when id.date_start_utc <= gt.entry and id.date_end_utc <= coalesce(gt.exit,current_timestamp) then
            case when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, gt.entry, id.date_end_utc)
               when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc) then TIMESTAMPDIFF(seconds, gt.entry, id.date_end_utc)
               when (id.idle_start <= gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, gt.entry, id.idle_end)
               when (id.idle_start > gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
               when (id.idle_start > gt.entry and id.idle_end > coalesce(gt.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
               when (id.idle_start > gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.idle_start, id.idle_end)
            end
           when id.date_start_utc > gt.entry and id.date_end_utc <= coalesce(gt.exit,current_timestamp) then
            case when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.date_start_utc, id.date_end_utc)
               when (id.idle_start <= gt.entry and id.idle_end >= id.date_end_utc) then TIMESTAMPDIFF(seconds, id.date_start_utc, id.date_end_utc)
               when (id.idle_start <= gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.idle_start, id.idle_end)
               when (id.idle_start > gt.entry and id.idle_end >= id.date_end_utc and gt.exit is null) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
               when (id.idle_start > gt.entry and id.idle_end >= id.date_end_utc and id.idle_end > coalesce(gt.exit,current_timestamp)) then TIMESTAMPDIFF(seconds, id.idle_start, id.date_end_utc)
               when (id.idle_start > gt.entry and id.idle_end < coalesce(gt.exit,current_timestamp) and id.idle_end < id.date_end_utc) then TIMESTAMPDIFF(seconds, id.idle_start, id.idle_end)
            end
          end as geo_idle_seconds
      from geo_trip_sum gt 
      left join idle_data id on gt.asset_id = id.asset_id
            and overlaps(id.idle_start, id.idle_end, gt.entry, coalesce(gt.exit,current_timestamp))
      )
      select g.asset_id, g.geofence_id,
        convert_timezone('{{ _user_attributes['company_timezone'] }}', g.entry) AS entry,
        convert_timezone('{{ _user_attributes['company_timezone'] }}', g.exit) as exit,
        geo_hrs,
        tot_geo_trip_hrs, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours,
        coalesce(round(sum(geo_idle_seconds/3600)::decimal, 2),0.00) as tot_geo_idle_hrs
      from geo_idles_join g
      group by g.asset_id, g.geofence_id, entry, exit, geo_hrs, tot_geo_trip_hrs, g.start_odometer, g.end_odometer, g.entry_hours, g.exit_hours
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

  filter: date_filter {
    type: date
    default_value: "this day"
  }

  dimension: entry {
    label: "Entry Time"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['company_timezone'] }}',${TABLE}."ENTRY") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
  }


  dimension: exit {
    label: "Exit Time"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['company_timezone'] }}',${TABLE}."EXIT") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
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

  measure: hrs_in_geofence {
    label: "Hours in Geofence"
    type: sum
    sql: ${geo_hrs} ;;
  }

  measure: run_time {
    label: "Run Hours"
    type: sum
    sql: ${tot_geo_trip_hrs} ;;
  }

  measure: idle_time {
    label: "Idle Hours"
    type: sum
    sql: ${tot_geo_idle_hrs} ;;
  }


  set: detail {
    fields: [asset_id, entry, exit, geo_hrs, tot_geo_trip_hrs, tot_geo_idle_hrs, start_odometer, end_odometer, entry_hours, exit_hours, geofence_id]
  }

}
