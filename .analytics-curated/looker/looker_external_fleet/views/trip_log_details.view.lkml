view: trip_log_details {
  derived_table: {
    sql:
    with owned_and_rental_assets as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
        ('{{ _user_attributes['user_timezone'] }}')))
    )
    , base as (
    SELECT t.trip_id, a.asset_id,
        to_char(trip_time_seconds::timestamp,'HH24:MI:SS') as trip_length,
        t.start_timestamp, start_street, start_city,
        coalesce(T.start_state_abb, st1.abbreviation, '') as start_state,
        start_lat, start_lon,
        end_timestamp, end_street, end_city,
        coalesce(T.end_state_abb, st2.abbreviation, '') as end_state,
        end_lat, end_lon,
        start_geofence_id, end_geofence_id,
        t.trip_distance_miles,
        case  when t.end_hours - t.start_hours < 0 then 0
              else ROUND((t.end_hours - t.start_hours)::numeric,2)
              end as asset_hours,
        TO_CHAR(coalesce(t.idle_duration,0)::timestamp, 'HH24:MI:SS') as idle_time,
        round(t.start_odometer::numeric,0) as start_odometer,
        case  when (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters) is null then 'N/A'
              when t.end_total_fuel_used_liters = t.start_total_fuel_used_liters  then '<1'
              else (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters)::text
              end as fuel_used,
        coalesce((t.end_total_fuel_used_liters - t.start_total_fuel_used_liters),0) as fuel_used_var,
        start_hours, end_hours,
        case when trip_type_id = 2 then TO_CHAR(t.trip_time_seconds::timestamp, 'HH24:MI:SS') else '00:00:00' end as hauling_time,
        case when trip_type_id = 2 then t.trip_distance_miles else 0 end as hauling_distance
    from trips T
        JOIN owned_and_rental_assets a on a.asset_id = t.asset_id
        left join tracking_incidents ti on t.trip_id=ti.trip_id
        left join states st1 on st1.state_id = T.start_state_id
        left join states st2 on st2.state_id = T.end_state_id
    where  t.trip_time_seconds > 12
        AND t.start_timestamp >= {% date_start date_filter %}
        AND t.start_timestamp <= {% date_end date_filter %}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY t.trip_id ORDER BY t.trip_id) = 1
    )
    , flatten_geofences as (
    SELECT DISTINCT b.trip_id,
        g_start.value::integer AS start_geofence_id,
        g_end.value::integer AS end_geofence_id
    FROM base b,
        LATERAL flatten(b.start_geofence_id ) g_start,
        LATERAL flatten(b.end_geofence_id ) g_end
    )
    ,geofence_aggregation AS (
    SELECT f.trip_id,
        array_agg(DISTINCT g_start.NAME) AS start_geofences,
        array_agg(DISTINCT g_end.NAME) AS end_geofences
    FROM flatten_geofences f
        LEFT JOIN geofences g_start ON g_start.geofence_id = f.start_geofence_id
        LEFT JOIN geofences g_end ON g_end.geofence_id = f.end_geofence_id
    WHERE g_start.company_id = {{ _user_attributes['company_id'] }}::numeric
        AND g_end.company_id = {{ _user_attributes['company_id'] }}::numeric
    GROUP BY f.trip_id
    )
    select asset_id,
        fuel_used,
        trip_length, start_timestamp,
        start_lat, start_lon,
        end_timestamp,
        end_lat, end_lon,
        trip_distance_miles, asset_hours, idle_time,  start_odometer, start_hours, end_hours,
        hauling_time, hauling_distance,
        sum(b.fuel_used_var) over (partition by asset_id order by start_timestamp) as cumulative_fuel_used,
        array_to_string(start_geofences, ', ') AS start_geofences,
        array_to_string(end_geofences, ', ') AS end_geofences,
        case when g.start_geofences IS not null then array_to_string(start_geofences, ', ')
             when start_street IS not NULL then concat(start_street, coalesce(concat(', ',start_city), ''), coalesce(concat(', ',start_state), ''))
             ELSE concat(start_lat, '/', start_lon)
             end AS start_location,
        case when g.end_geofences IS not null then array_to_string(end_geofences, ', ')
             when end_street IS not NULL then concat(end_street, coalesce(concat(', ',end_city), ''), coalesce(concat(', ',end_state), ''))
             ELSE concat(end_lat, '/', end_lon)
             end AS end_location
    from base b
        LEFT JOIN geofence_aggregation g ON g.trip_id = b.trip_id
    GROUP BY (fuel_used_var, asset_id, fuel_used,
        trip_length, start_timestamp, start_street, start_city, start_state, end_timestamp, end_street,
        end_city, end_state, trip_distance_miles, asset_hours, idle_time,  start_odometer, start_hours,
        end_hours, start_lat, start_lon, end_lat, end_lon, hauling_time, hauling_distance, g.start_geofences, g.end_geofences)
        ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${start_timestamp});;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: fuel_used {
    type: number
    sql: ${TABLE}."FUEL_USED" ;;
  }

  dimension: trip_length {
    type: string
    sql: ${TABLE}."TRIP_LENGTH" ;;
  }

  filter: date_filter {
    type: date
  }

  dimension: start_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip Start Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."START_TIMESTAMP") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: end_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip End Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."END_TIMESTAMP") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: start_street {
    type: string
    sql: ${TABLE}."START_STREET" ;;
  }

  dimension: start_city {
    type: string
    sql: ${TABLE}."START_CITY" ;;
  }

  dimension: start_state {
    type: string
    sql: ${TABLE}."START_STATE" ;;
  }

  dimension: start_lat {
    type: number
    sql: ${TABLE}."START_LAT" ;;
  }

  dimension: start_lon {
    type: number
    sql: ${TABLE}."START_LON" ;;
  }

  dimension: start_lat_long {
    label: "Start Lat/Long"
    type: string
    sql: concat(${start_lat},', ',${start_lon});;
  }

  dimension: end_street {
    type: string
    sql: ${TABLE}."END_STREET" ;;
  }

  dimension: end_city {
    type: string
    sql: ${TABLE}."END_CITY" ;;
  }

  dimension: end_state {
    type: string
    sql: ${TABLE}."END_STATE" ;;
  }

  dimension: end_lat {
    type: number
    sql: ${TABLE}."END_LAT" ;;
  }

  dimension: end_lon {
    type: number
    sql: ${TABLE}."END_LON" ;;
  }

  dimension: end_lat_long {
    label: "End Lat/Long"
    type: string
    sql: concat(${end_lat},', ',${end_lon});;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }

  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }

  dimension: idle_time {
    type: string
    sql: ${TABLE}."IDLE_TIME" ;;
    html:
      {% if value != '00:00:00' %}
      <p style="color: blue"><font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ trip_log_details.asset_id._value }}/history?selectedDate={{ trip_log_details.start_timestamp._value }}" target="_blank">{{ trip_log_details.idle_time._value }}</a></font></u></p>
      {% else %}
      <p style="color: dimgray">00:00:00</p>
      {% endif %};;
  }

  dimension: start_odometer {
    type: number
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: start_hours {
    type: number
    sql: ${TABLE}."START_HOURS" ;;
  }

  dimension: end_hours {
    type: number
    sql: ${TABLE}."END_HOURS" ;;
  }

  dimension: hauling_time {
    type: string
    sql: ${TABLE}."HAULING_TIME" ;;
  }

  dimension: hauling_distance {
    type: number
    sql: ${TABLE}."HAULING_DISTANCE" ;;
  }

  dimension: cumulative_fuel_used {
    type: number
    sql: ${TABLE}."CUMULATIVE_FUEL_USED" ;;
  }

  dimension: start_geofences {
    type: string
    sql: ${TABLE}."START_GEOFENCES" ;;
  }

  dimension: end_geofences {
    type: string
    sql: ${TABLE}."END_GEOFENCES" ;;
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/?q={{ trip_log_details.start_location._value }}" target="_blank">{{ trip_log_details.start_location._value }}</a></font></u> ;;

  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/?q={{ trip_log_details.end_location._value }}" target="_blank">{{ trip_log_details.end_location._value }}</a></font></u> ;;

  }

  set: detail {
    fields: [asset_id, organizations.groups, assets.custom_name, fuel_used, trip_length, start_timestamp, start_location, start_lat_long, end_timestamp, end_location, end_lat_long,
      hauling_time, hauling_distance, cumulative_fuel_used, start_geofences, end_geofences]
  }
}
