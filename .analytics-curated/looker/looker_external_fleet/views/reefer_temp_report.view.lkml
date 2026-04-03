view: reefer_temp_report {
  derived_table: {
    sql:
    select
        asset_id,
        --custom_name,
        date_updated,
        lat, long, street, city, state,
        speed, trip_odo_miles,
        return_temp, discharge_temp,
        hours, hours - first_value(hours) over (partition by asset_id order by asset_id, hours, date_updated) as cum_hours
    from (
        select asst.asset_id, --a.custom_name,
          date_trunc('minute', convert_timezone('{{ _user_attributes['user_timezone'] }}', asst.date_updated)) as date_updated,
          location_lon as long,
          location_lat as lat,
          te.street,
          te.city,
          s.abbreviation as state,
          te.speed,
          te.trip_odo_miles,
          max(case when label = 'Return Temp' then value end) as return_temp,
          max(case when label = 'Discharge Temp' then value end) as discharge_temp,
          h.hours
        from asset_sensor_statuses_audit asst
              left join tracking_events te on asst.tracking_event_id = te.tracking_event_id
              left join asset_sensors sens on asst.asset_sensor_id = sens.asset_sensor_id
              left join asset_sensor_types asty on sens.asset_sensor_type_id = asty.asset_sensor_type_id
              left join states s on s.state_id = te.state_id
              --join assets a on a.asset_id = asst.asset_id
              join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = asst.asset_id
              left join scd.scd_asset_hours h on h.asset_id=asst.asset_id and (asst.date_updated between h.date_start and coalesce(h.date_end, current_timestamp))
        where asst.date_updated >= {% date_start date_filter %}
          and asst.date_updated <= {% date_end date_filter %}
        group by asst.asset_id, --a.custom_name,
                report_timestamp, asst.date_updated,
                te.location_lon, te.location_lat,
                te.street,
                te.city,
                s.abbreviation,
                te.speed,
                te.trip_odo_miles,
                h.hours
      )
    order by --custom_name,
    cum_hours, date_updated ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id}, ${date_updated_time}, coalesce(${discharge_temp},0), coalesce(${return_temp},0)) ;;
  }

  filter: date_filter {
    type: date
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    #sql: ${TABLE}."CUSTOM_NAME" ;;
    sql: ${assets.custom_name} ;;
  }

  dimension_group: date_updated {
    label: "Date"
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: cum_hours {
    label: "Total Hours"
    type: number
    sql: ${TABLE}."CUM_HOURS" ;;
  }

  dimension: lat {
    type: number
    sql: ${TABLE}."LAT" ;;
  }

  dimension: long {
    type: number
    sql: ${TABLE}."LONG" ;;
  }

  dimension: lat_long {
    label: "Lat/Long"
    type: string
    sql: concat(${lat},', ',${long}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ reefer_temp_report.lat._value }},{{ reefer_temp_report.long._value }}" target="_blank">View Map</a></font></u> ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: speed {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: trip_odo_miles {
    type: number
    sql: ${TABLE}."TRIP_ODO_MILES" ;;
  }

  dimension: return_temp {
    type: number
    sql: ${TABLE}."RETURN_TEMP" ;;
  }

  dimension: discharge_temp {
    type: number
    sql: ${TABLE}."DISCHARGE_TEMP" ;;
  }

  measure: dummy {
    type: count
  }

}