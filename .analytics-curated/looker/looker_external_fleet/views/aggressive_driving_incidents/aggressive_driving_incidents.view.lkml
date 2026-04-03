view: aggressive_driving_incidents {
  derived_table: {
    sql:
with
    asset_list_own as (
    select distinct ai.asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
        where ai.company_id in
        -- (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
        (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
    )
    ,asset_list_rental as (
    select cv.asset_id,start_date,end_date from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
    join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = cv.asset_id
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
        where time_overlaps(
         start_date,
         end_date,
         convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
         convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
         true
         )
        and rental_company_id =  {{ _user_attributes['company_id'] }}::numeric
    )
    ,asset_list as ( --Code to combine rental and owned asset ids together
    select
      asset_id
      , 'Owned' as ownership
    from
      asset_list_own
    UNION
    select
      asset_id
      , 'Rented' as ownership
    from
      asset_list_rental

    )
      select
          a.asset_id,
          a.company_id,
          a.custom_name as asset_name,
          COALESCE(ti.driver_name_new, 'Unassigned Driver') as driver_name,
          te.tracking_event_id,
          ti.trip_id,
          ti.tracking_incident_id,
          te.speed,
          te.trip_odo_miles,
          convert_timezone('America/Chicago',te.report_timestamp) as report_timestamp,
          te.location_lon as event_location_lon,
          te.location_lat as event_location_lat,
          t.end_street,
          t.end_county,
          t.end_city,
          t.start_street,
          t.start_county,
          t.start_city,
          o.name as group_name,

          case
            when tracking_incident_name = 'Aggressive Acceleration' then 'Aggressive Acceleration'
            when tracking_incident_name = 'Aggressive Deceleration' then 'Aggressive Deceleration'
          else null end as incident_type,

          {% if table_view_by._parameter_value == "'Asset'" %}
              concat(a.custom_name, ' - ', COALESCE(ti.driver_name_new, 'Unassigned Driver')) as asset_driver
          {% elsif table_view_by._parameter_value == "'Driver'" %}
              COALESCE(ti.driver_name_new, 'Unassigned Driver') as asset_driver
          {% endif %}

      from
          asset_list al
          join assets a on a.asset_id = al.asset_id and a.asset_type_id = 2
          join business_intelligence.triage.stg_t3__tracking_incidents_triage ti on al.asset_id = ti.Asset_id and ti.tracking_incident_name in ('Aggressive Acceleration','Aggressive Deceleration')
          join tracking_events te on te.tracking_event_id = ti.tracking_event_id
          join trips t on t.trip_id = ti.trip_id
          left join organization_asset_xref ox on a.asset_id = ox.asset_id
          left join organizations o on o.organization_id = ox.organization_id
      where
          {% condition asset_filter %} a.asset_name {% endcondition %}
          AND {% condition incident_type_filter %} incident_type {% endcondition %}
          AND {% condition group_filter %} o.name {% endcondition %}
          AND {% condition asset_driver_filter %} asset_driver {% endcondition %}
          AND te.report_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      ;;
  }

  measure: count {
    label: "Count"
    type: count
    #drill_fields: [detail*]
  }

  measure: map_count {
    label: "Total Map Incidents"
    type: count_distinct
    sql: ${tracking_incident_id};;
    html: {{rendered_value}}
          <br />
          <p>
          </p>
          <p>Asset/Driver:
          <br />{{ asset_driver._value }}
          </p>
          <p>Trip Start City:
          <br />{{ trip_start_city._value }}
          </p>
          <p>Trip End City:
          <br />{{ trip_end_city._value }}
          </p>
          ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: group_name {
    label: "Group"
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension:  tracking_event_id {
    type: string
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracking_incident_id {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Asset"
  }

  dimension: driver_name {
    label: "Driver"
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;

  }

  dimension: trip_odo_miles {
    type: number
    sql: ${TABLE}."TRIP_ODO_MILES" ;;
  }

  dimension: report_timestamp {
    type: date_time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
  #  html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: report_time_formatted {
    group_label: "HTML Passed Date Format"
    label: "Timestamp"
     #type: time
    sql: ${report_timestamp} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: speed {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}."INCIDENT_TYPE" ;;
    html:
    {% if incident_type._value == 'Aggressive Acceleration'  %}
    <font color="#00CB86">❯</font> {{rendered_value }}
    {% else %}
    <font color="#FFB14E">❯</font> {{rendered_value }}
    {% endif %}
    ;;
  }

  dimension_group: end_timestamp {
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
  }

  dimension: trip_id {
    type: string
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id_c {
    type: string
    sql: ${TABLE}."ASSET_ID_C" ;;
  }

  dimension: duration_seconds {
    type: number
    sql: ${TABLE}."DURATION_SECONDS" ;;
  }

  dimension: event_location_lon {
    type: number
    sql: ${TABLE}."EVENT_LOCATION_LON" ;;
  }

  dimension: event_location_lat {
    type: number
    sql: ${TABLE}."EVENT_LOCATION_LAT" ;;
  }

  dimension: trip_end_street {
    type: string
    sql: ${TABLE}."END_STREET" ;;
  }

  dimension: trip_end_county {
    type: string
    sql: ${TABLE}."END_COUNTY" ;;
  }

  dimension: trip_end_city {
    type: string
    sql: ${TABLE}."END_CITY" ;;
  }

  dimension: trip_start_street {
    type: string
    sql: ${TABLE}."START_STREET" ;;
  }

  dimension: trip_start_county {
    type: string
    sql: ${TABLE}."START_COUNTY" ;;
  }

  dimension: trip_start_city {
    type: string
    sql: ${TABLE}."START_CITY" ;;
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

  set: detail {
    fields: [
      asset_id,
      trip_id,
      duration_seconds,
      event_location_lon,
      event_location_lat
    ]
  }

  dimension: event_id_cross_filter {
    label: "View Event"
    group_label: "Cross Filter asset ID"
    type: number
    sql: ${tracking_event_id} ;;
    html:
    <font color="#000000">Click here</font>
    ;;
    description: "Click a row below to view a certain idle event on the map"
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: link_to_asset_t3 {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
    label: "Asset"
    group_label: "Link to T3 Status Page"
    html: <font color="blue"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{rendered_value}}</a></font?</u>;;
  }

  parameter: table_view_by {
    type: string
    allowed_value: { value: "Asset"}
    allowed_value: { value: "Driver"}
  }

  # parameter: driver_by {
  #   type: string
  #   allowed_value: { value: "Driver Assignment"}
  #   allowed_value: { value: "Legacy Assignment"}
  # }

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

  measure: total_incidents {
    label: " Total Incidents"
    type: count_distinct
    sql: ${tracking_incident_id};;
  }

  measure: total_acceleration_incidents {
    label: " Total Acceleration Incidents"
    type: count_distinct
    sql: CASE WHEN ${incident_type}='Aggressive Acceleration' then ${tracking_incident_id} else null end;;
  }

  measure: total_deceleration_incidents {
    label: " Total Deceleration Incidents"
    type: count_distinct
    sql: CASE WHEN ${incident_type}='Aggressive Deceleration' then ${tracking_incident_id} else null end;;
  }

  dimension: asset_driver {
    label: "Asset/Driver"
    type: string
    sql: ${TABLE}."ASSET_DRIVER" ;;
  }

  filter: asset_driver_filter {
    label: "Asset/Driver"
    suggest_explore: aggressive_driving_incidents
    suggest_dimension: aggressive_driving_incidents.asset_driver
    suggest_persist_for: "0 seconds"
  }

  filter: asset_filter {
    suggest_explore: aggressive_driving_incidents
    suggest_dimension: aggressive_driving_incidents.asset_name
  }


  filter: incident_type_filter {
    suggest_explore: aggressive_driving_incidents
    suggest_dimension: aggressive_driving_incidents.incident_type
  }

  filter: group_filter {
    label: "Groups"
    suggest_explore: aggressive_driving_incidents
    suggest_dimension: aggressive_driving_incidents.group_name
  }

  filter: driver_name_filter {
  }


}
