view: tracking_incident_view {
 derived_table: {
  sql:
select t.asset_id
, t.company_id
, asset_name
, t.driver_name_new as driver_name
, t.trip_id
, convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', t.date_time::timestamp_ntz) as date_time
, t.tracking_incident_name
, t.speed
, t.posted_speed_limit
, t.duration
, t.tracking_incident_id
, t.tracking_event_id
, t.start_address
, t.end_address
, t.total_trip_miles
, t.total_trip_seconds
, t.start_lat
, t.start_lon
, t.end_lat
, t.end_lon
, t.equipment_class
, ai.license_plate_number
, ai.license_plate_state
, t.date_refresh_timestamp
from business_intelligence.triage.stg_t3__tracking_incidents_triage t
left join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = t.asset_id
where t.company_id = {{ _user_attributes['company_id'] }}::numeric
and t.date_time >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',{% date_start date_filter %})
and t.date_time <= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC',{% date_end date_filter %})
            ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: trip_id {
  type: number
  sql: ${TABLE}."TRIP_ID" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

dimension: asset_name {
   type: string
  group_label: "Asset Names"
  sql: ${TABLE}."ASSET_NAME" ;;
  label: "Asset"
  html: <font color="blue"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{date_time_date._filterable_value }}" target="_blank">{{value}}</a></font?</u>;;
 }

  dimension: asset_name_no_link {
    type: string
    group_label: "Asset Names"
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Asset"
  }

  dimension: driver_name {
   label: "Driver"
   type: string
   sql: ${TABLE}."DRIVER_NAME" ;;
 }

  parameter: table_view_by {
    type: string
    allowed_value: { value: "Asset"}
    allowed_value: { value: "Driver"}
  }

  dimension: dynamic_by_asset_or_driver_selection {
    label: "View By"
    label_from_parameter: table_view_by
    sql: {% if table_view_by._parameter_value == "'Asset'" %}
          concat(${asset_name},' - ',coalesce(${driver_name}, 'Unassigned Driver'))
        {% elsif table_view_by._parameter_value == "'Driver'" %}
          coalesce(${driver_name}, 'Unassigned Driver')
        {% else %}
          'No Driver Assigned'
        {% endif %} ;;
  }

dimension_group: date_time {
  type: time
  sql: ${TABLE}."DATE_TIME" ;;
  html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
}

dimension: tracking_incident_name {
  type: string
  sql: ${TABLE}."TRACKING_INCIDENT_NAME" ;;
}

dimension: speed {
  type: number
  sql: ${TABLE}."SPEED" ;;
}

dimension: posted_speed_limit {
  type: number
  sql: ${TABLE}."POSTED_SPEED_LIMIT" ;;
}

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

dimension: tracking_incident_id {
  type: number
  sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
}

dimension: tracking_event_id {
  type: number
  sql: ${TABLE}."TRACKING_EVENT_ID" ;;
}

dimension: start_address {
  type: string
  sql: ${TABLE}."START_ADDRESS" ;;
}

  dimension: event_address {
    type: string
    sql: ${start_address} ;;
  }

dimension: end_address {
  type: string
  sql: ${TABLE}."END_ADDRESS" ;;
}

dimension: total_trip_miles {
  type: number
  sql: ${TABLE}."TOTAL_TRIP_MILES" ;;
}

dimension: total_trip_seconds {
  type: number
  sql: ${TABLE}."TOTAL_TRIP_SECONDS" ;;
}

dimension: start_lat {
  type: number
  sql: ${TABLE}."START_LAT" ;;
}

dimension: start_lon {
  type: number
  sql: ${TABLE}."START_LON" ;;
}

dimension: end_lat {
  type: number
  sql: ${TABLE}."END_LAT" ;;
}

dimension: end_lon {
  type: number
  sql: ${TABLE}."END_LON" ;;
}

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }

  measure: map_count {
    label: "Total Map Incidents"
    type: count_distinct
    sql: ${tracking_incident_id};;
    html: {{rendered_value}}
          <br />
          <p>
          </p>
          <p>Asset:
          <br />{{ asset_name._value }}
          </p>
          <p>Trip Start City:
          <br />{{ start_address._value }}
          </p>
          <p>Trip End City:
          <br />{{ end_address._value }}
          </p>
          ;;
  }

  dimension: event_location_lon {
    type: number
    sql: ${TABLE}."START_LON" ;;
  }

  dimension: event_location_lat {
    type: number
    sql: ${TABLE}."START_LAT" ;;
  }

  dimension: mapping_event {
    label: "Incident Location"
    type: location
    sql_latitude:${event_location_lat} ;;
    sql_longitude:${event_location_lon} ;;
  }

filter: date_filter {
  type: date_time
}

  # parameter: driver_by {
  #   type: string
  #   allowed_value: { value: "Driver Assignment"}
  #   allowed_value: { value: "Legacy Assignment"}
  # }

  dimension: link_to_asset_t3 {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Daily Detail"
    group_label: "Link to T3 Status Page"
    html: <font color="blue"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{date_time_date._filterable_value }}" target="_blank">{{date_time_date._filterable_value | date: "%b %d, %Y"  }} Detail</a></font?</u>;;


  }

  dimension: key {
    type: number
    primary_key: yes
    sql: concat(${TABLE}."TRIP_ID",${TABLE}."DATE_TIME", ${TABLE}."COMPANY_ID") ;;
  }

  measure: total_acceleration_incidents {
    label: " Total Acceleration Incidents"
    type: count_distinct
    sql: CASE WHEN ${tracking_incident_name}='Aggressive Acceleration' then ${tracking_incident_id} else null end;;
  }

  measure: total_deceleration_incidents {
    label: " Total Deceleration Incidents"
    type: count_distinct
    sql: CASE WHEN ${tracking_incident_name}='Aggressive Deceleration' then ${tracking_incident_id} else null end;;
  }

  measure: total_over_speed_incidents {
    label: " Total Over Speed Incidents"
    type: count_distinct
    sql: CASE WHEN ${tracking_incident_name}='Over Speed' then ${tracking_incident_id} else null end;;
  }

  measure: total_ignition_incidents {
    label: " Total Ignition Incidents"
    type: count_distinct
    sql: CASE WHEN ${tracking_incident_name} in ('Ignition On','Ignition Off') then ${tracking_incident_id} else null end;;
  }

set: detail {
  fields: [
    trip_id,
    asset_id,
    company_id,
    equipment_class,
    asset_name,
    driver_name,
    date_time_time,
    tracking_incident_name,
    speed,
    posted_speed_limit,
    duration_seconds,
    tracking_incident_id,
    tracking_event_id,
    start_address,
    end_address,
    total_trip_miles,
    total_trip_seconds,
    start_lat,
    start_lon,
    end_lat,
    end_lon
  ]
}
}
