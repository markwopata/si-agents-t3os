view: trip_detail_history {
  derived_table: {
    sql:
    with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select rl.asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start trip_log_details.date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end trip_log_details.date_filter %}),
        ('{{ _user_attributes['user_timezone'] }}'))) rl
    join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
    )
    , trip_details as (
    select
            t.asset_id,
            coalesce(case when ti.tracking_incident_type_id = 17 then ti.report_timestamp - interval '5 minutes'
                                     else  ti.report_timestamp end,
                                     te.report_timestamp) as date_time,
            coalesce(case
                          when ti.tracking_incident_type_id = 5 then concat('Idle Stop', ' (',to_time(TO_TIMESTAMP_NTZ(duration)),')')
                          when ti.tracking_incident_type_id = 20 then concat(tiy.name, ' (',to_time(TO_TIMESTAMP_NTZ(duration)), ')')
                          else tiy.name end , ' ') as status,
            te.location_lon as long,
            te.location_lat as lat,
            te.street,
            te.city,
            st.abbreviation,
            te.speed,
            te.trip_odo_miles,
            t.end_odometer
        from
            asset_list a join trips t on a.asset_id = t.asset_id
            join tracking_events te on t.trip_id = te.trip_id
            left join tracking_incidents ti on ti.tracking_event_id = te.tracking_event_id
            left join tracking_incident_types tiy on tiy.tracking_incident_type_id = ti.tracking_incident_type_id and ti.tracking_incident_type_id in (5,17, 19, 20)
            left join states st on st.state_id = te.state_id
        where
            --t.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %})
            --AND t.start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %})
            --commented code needs to be swapped out with the first two lines in the where clause
            t.start_timestamp >= {% date_start trip_log_details.date_filter %}
            AND t.start_timestamp <= {% date_end trip_log_details.date_filter %}
            --AND te.location_lon is not null
    )
    select
            asset_id,
            date_time::timestamp as date_time,
            status,
            lat,
            long,
            concat_ws(', ', street, city, abbreviation) as location,
            speed,
            trip_odo_miles,
            end_odometer,
            coalesce(end_odometer - lag(end_odometer,1) over (partition by asset_id order by asset_id, end_odometer, date_time),0) as odo_diff,
            case when long is null then 'No Location' Else 'Location' end as does_trip_have_location
    from trip_details
    order by asset_id, end_odometer, date_time
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${date_time});;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  filter: date_filter {
    type: date
  }

  dimension: date_time {
    label: "Date Time"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."DATE_TIME") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: lat {
    type: number
    sql: ${TABLE}."LAT" ;;
  }

  dimension: long {
    type: number
    sql: ${TABLE}."LONG" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: speed {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: trip_odo_miles {
    type: number
    sql: ${TABLE}."TRIP_ODO_MILES" ;;
  }

  dimension: odo_diff {
    type: number
    sql: ${TABLE}."ODO_DIFF" ;;
  }

  dimension: end_odometer {
    type: number
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: lat_long {
    label: "Lat/Long"
    type: string
    sql: concat(${lat},', ',${long});;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ trip_detail_history.lat._value }},{{ trip_detail_history.long._value }}" target="_blank">View Map</a></font></u> ;;
  }

  dimension: does_trip_have_location {
    type: string
    sql: ${TABLE}."DOES_TRIP_HAVE_LOCATION" ;;
  }

  dimension: flag_trips_with_location {
    type: yesno
    sql: ${does_trip_have_location} = 'Location' ;;
  }

  dimension: date_time_formatted {
    group_label: "HTML Passed Date Format" label: "Trip Date Time"
    sql: ${date_time} ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  set: detail {
    fields: [organizations.groups, assets.custom_name, asset_id, date_time, status, lat_long, location, speed, trip_odo_miles, end_odometer, odo_diff]
  }
}
