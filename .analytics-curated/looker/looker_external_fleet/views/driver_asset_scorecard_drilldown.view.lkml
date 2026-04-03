view: driver_asset_scorecard_drilldown {
  derived_table: {
    sql:
      ---- START OF CTEs ----
      with asset_list_own as (
      select distinct ai.asset_id, ai.asset as custom_name, o.name as groups from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
      left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
      left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
          where (ai.company_id in (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
          or o.company_id = {{ _user_attributes['company_id'] }}::numeric)
          and ai.asset_type = 'Vehicle'
      ),

      asset_list_rental as (
      select cv.asset_id, ai.asset as custom_name, o.name as groups, start_date,end_date from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
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
          and ai.asset_type = 'Vehicle'
      ),

      --Code to combine rental and owned asset ids together
      owned_and_rental_assets as (
      select
        asset_id,
        custom_name,
        groups,
        'Owned' as ownership
      from
        asset_list_own
      UNION
      select
        asset_id,
        custom_name,
        groups,
        'Rented' as ownership
      from
        asset_list_rental
      ),

      speed_events as (
      select sp.trip_id,
        sum(sp.speed_duration_secs) as speed_duration_secs,
        count(sp.speed_events) as speed_events
      from (
        select t.asset_id, t.trip_id,
          case
              when (t.tracking_incident_name = 'Over Speed Limit' and ait.asset_incident_threshold_field_id = 9) then aid.duration_seconds
              when asset_incident_threshold_field_id = 17 then aid.duration_seconds
              when t.tracking_incident_name = 'Over Speed' then t.duration
          end as speed_duration_secs,
          case
              when (t.tracking_incident_name = 'Over Speed Limit' and ait.asset_incident_threshold_field_id = 9) then start_incident_id
              when asset_incident_threshold_field_id = 17 then start_incident_id
              when t.tracking_incident_name = 'Over Speed' then tracking_incident_id
          end as speed_events
        from business_intelligence.triage.stg_t3__tracking_incidents_triage t
          left join asset_incident_thresholds ait on ait.asset_incident_threshold_id = t.asset_incident_threshold_id
          left join asset_incident_threshold_durations aid on aid.start_incident_id = t.tracking_incident_id
        where
        t.date_time >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
        and t.date_time < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
        OR
        (
          (t.tracking_incident_name = 'Over Speed Limit' and ait.asset_incident_threshold_field_id = 9) -- threshold alerts
          or asset_incident_threshold_field_id = 17
          and aid.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
          and aid.end_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
        )
        OR
        (
          tracking_incident_name = 'Over Speed' -- default alerts
        )
      ) sp
      group by trip_id
      )

    ---- START OF MAIN CODE ----
    select distinct
    ti.driver_name_new as name,
    a.custom_name,
    a.groups,
    t.trip_id,
    convert_timezone('{{ _user_attributes['user_timezone'] }}', ti.date_time) as report_timestamp,
    ti.tracking_incident_id,
    ti.tracking_incident_name as incident_type,
    t.trip_distance_miles,
    t.trip_time_seconds::decimal/3600 as on_time_hrs,
    t.idle_incidents,
    coalesce(sp.speed_events, 0) as speed_events,
    coalesce(t.aggressive_incidents, 0) as aggressive,
    coalesce(t.idle_duration::decimal/3600, 0) as idle_hours,
    coalesce(sp.speed_duration_secs::decimal/3600,0) as speed_hours,
    te.speed,
      case
      when direction >= 331 or direction <= 30 then 'North'
      when direction >= 31 and direction <= 60 then 'Northeast'
      when direction >= 61 and direction <= 120 then 'East'
      when direction >= 121 and direction <= 150 then 'Southeast'
      when direction >= 151 and direction <= 210 then 'South'
      when direction >= 211 and direction <= 240 then 'Southwest'
      when direction >= 241 and direction <= 300 then 'West'
      when direction >= 301 and direction <= 330 then 'Northwest'
      else 'Undetermined'
      end as direction,
      te.location_lon,
      te.location_lat,
      concat(te.location_lat, ', ',te.location_lon)  as location
    from owned_and_rental_assets a
    join trips t on a.asset_id = t.asset_id
    left join business_intelligence.triage.stg_t3__tracking_incidents_triage ti on t.trip_id = ti.trip_id
      left join users u on t.driver_user_id = u.user_id
      left join speed_events sp on sp.trip_id = t.trip_id
      left join tracking_events te on te.tracking_event_id = ti.tracking_event_id
    where t.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
      and t.start_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
      and t.end_timestamp is not null
      and t.trip_type_id in(1,2,5,7)
      and name is not null -- Remove null driver instances
      and {% condition groups_filter %} a.groups {% endcondition %}
      and {% condition driver_filter %}
        CASE
          WHEN {% parameter scorecard_by %} = 'Driver' THEN coalesce(ti.driver_name_new, 'Unassigned Driver')
          WHEN {% parameter scorecard_by %} = 'Asset'  THEN concat(a.custom_name, ' - ', coalesce(ti.driver_name_new, 'Unassigned Driver'))
        END
      {% endcondition %}
      ;;
    }

  filter: date_filter {
    type: date_time
    }

  dimension: compound_primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}."TRIP_ID", ' ', ${TABLE}."TRACKING_INCIDENT_ID") ;;
  }

  dimension: groups {
    type: string
    sql: ${TABLE}."GROUPS" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: tracking_incident_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql:  ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: name {
    label: "Asset/Driver"
    type: string
    suggest_persist_for: "0 seconds"
    sql: ${TABLE}."NAME"
    ;;
  }

  dimension: report_timestamp {
    type: date_time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}."INCIDENT_TYPE" ;;
  }

  measure: miles_driven {
    value_format_name: decimal_0
    type: sum_distinct
    sql_distinct_key: ${trip_id} ;;
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }

  measure: time_driven_hours {
    value_format_name: decimal_2
    type: sum_distinct
    sql_distinct_key: ${trip_id} ;;
    sql: ${TABLE}."ON_TIME_HRS" ;;
  }

  # measure: impact_count {
  #  value_format_name: decimal_0
  #  type: sum
  #  sql: ${TABLE}."IMPACT_INCIDENTS" ;;
  # }

  # measure: speed_count {
  #   value_format_name: decimal_0
  #   type: sum
  #   sql: ${TABLE}."SPEED_COUNT" ;;
  # }

  dimension: speed {
    label: "Speed (MPH)"
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: direction {
    type: string
    sql: ${TABLE}."DIRECTION" ;;
  }

  dimension: location_lon {
    type: string
    sql: ${TABLE}."LOCATION_LON" ;;
  }

  dimension: location_lat {
    type: string
    sql: ${TABLE}."LOCATION_LAT" ;;
  }

  dimension: aggressive {
    value_format_name: decimal_0
    type: number
    sql: ${TABLE}."AGGRESSIVE" ;;
  }

  dimension: location {
    label: "Location"
    type: string
    sql: ${TABLE}."LOCATION" ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ driver_asset_scorecard_drilldown.location_lat._value }},{{ driver_asset_scorecard_drilldown.location_lon._value }}" target="_blank">View Map</a></font></u> ;;
  }

  measure: aggressive_incidents {
    value_format_name: decimal_0
    type: count_distinct
    sql: NULLIF(${tracking_incident_id},0) ;;
    # filters: [incident_type: "Aggressive%"]
    filters: [incident_type: "Aggressive Deceleration,Aggressive Acceleration"]
    drill_fields: [user_details*]
    html: <a href="#drillmenu" target="_self">{{rendered_value}}
    <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></a> ;;
  }

  measure: total_aggressive_incidents {
    value_format_name: decimal_0
    type: count_distinct
    sql: NULLIF(${tracking_incident_id},0) ;;
    # filters: [incident_type: "Aggressive%"]
    filters: [incident_type: "Aggressive Deceleration,Aggressive Acceleration"]
    drill_fields: [user_details*]
  }

  set: user_details {
    fields: [name, incident_type, report_timestamp, speed, direction, location]
  }

  measure: idle_hours {
    value_format_name: decimal_2
    type: sum_distinct
    sql_distinct_key: ${trip_id} ;;
    sql: ${TABLE}."IDLE_HOURS" ;;
  }

  measure: speed_hours {
    value_format_name: decimal_2
    type: sum_distinct
    sql_distinct_key: ${trip_id} ;;
    sql: ${TABLE}."SPEED_HOURS" ;;
  }

  measure: aggressive_score {
    value_format_name: decimal_2
    type:  number
    sql: case when ${aggressive_incidents} > 0 then
              case when round(100 - (${aggressive_incidents} * 0.125),2) < 0 then 0 else round(100 - (${aggressive_incidents} * 0.125),2) end
                   else 100 end;;
  }

##  measure: impact_score {
##    value_format_name: decimal_2
##    type: number
##    sql: case when ${impact_count} = 0 then 100
##              when ${impact_count} = 1 then 80
##              else 50 end;;
##  }

  measure: idle_score {
    value_format_name: decimal_2
    type: number
    sql: case when ${idle_hours} > 0 then 100 - (${idle_hours} / ${time_driven_hours}) * 100
         else 100 end;;
  }

  measure: speed_score {
    value_format_name: decimal_2
    type: number
    sql: case when ${speed_hours} > 0 then 100 - (${speed_hours} / ${time_driven_hours}) * 100
              else 100 end;;
  }

  measure: total_score {
    value_format_name: decimal_2
    type:  number
    sql: case when (${aggressive_score} +  ${idle_score} + ${speed_score}) / 3 < 0 then 0
              else (${aggressive_score} + ${idle_score} + ${speed_score}) / 3
              end;; ## (${aggressive_score} +  ${idle_score} + ${speed_score} + ${impact_score}) / 4
  }

  measure: total_score_no_idle {
    value_format_name: decimal_2
    type:  number
    sql: case when (${aggressive_score} + ${speed_score}) / 2 < 0 then 0
              else (${aggressive_score} + ${speed_score}) / 2
              end;; ## (${aggressive_score} + ${speed_score} + ${impact_score}) / 3
  }

  parameter: scorecard_by {
    type: string
    allowed_value: { value: "Asset"}
    allowed_value: { value: "Driver"}
  }

  parameter: include_idle_time {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
  }

  dimension: dynamic_by_asset_or_driver_selection {
    label_from_parameter: scorecard_by
    sql: {% if scorecard_by._parameter_value == "'Asset'" %}
          concat(${custom_name},' - ',coalesce(${name}, 'Unassigned Driver'))
        {% elsif scorecard_by._parameter_value == "'Driver'" %}
          coalesce(${name}, 'Unassigned Driver')
        {% else %}
          'No Driver Assigned'
        {% endif %} ;;
  }

  dimension: driver_name {
    type: string
    sql:  ${TABLE}."DRIVER_NAME" ;;
  }

  # parameter: driver_by {
  #   type: string
  #   allowed_value: { value: "Driver Assignment"}
  #   allowed_value: { value: "Legacy Assignment"}
  # }

  measure: dynamic_total_score {
    type: number
    label_from_parameter: include_idle_time
    sql: {% if include_idle_time._parameter_value == "'Yes'" %}
          ${total_score}
        {% elsif include_idle_time._parameter_value == "'No'" %}
          ${total_score_no_idle}
        {% else %}
          NULL
        {% endif %} ;;
    value_format_name: decimal_2
  }

  filter: groups_filter {
  }

  filter: driver_filter {
  }

  filter: driver_name_filter {
  }

  }
