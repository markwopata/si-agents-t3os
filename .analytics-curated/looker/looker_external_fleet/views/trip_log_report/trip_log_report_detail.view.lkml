view: trip_log_report_detail {
  derived_table: {
    sql:
    with asset_list_own as (
    select distinct ai.asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
    where ai.company_id in (select company_id from users where user_id = {{ _user_attributes['user_id'] }}::numeric
    and {% condition custom_name_filter %} ai.custom_name {% endcondition %}
    and {% condition groups_filter %} o.name {% endcondition %}
    and {% condition asset_class_filter %} ai.asset_class {% endcondition %}
    and {% condition asset_type_filter %} ai.asset_type {% endcondition %}
    )
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
    and {% condition custom_name_filter %} ai.custom_name {% endcondition %}
    and {% condition groups_filter %} o.name {% endcondition %}
    and {% condition asset_class_filter %} ai.asset_class {% endcondition %}
    and {% condition asset_type_filter %} ai.asset_type {% endcondition %}
    and rental_company_id =  {{ _user_attributes['company_id'] }}::numeric
    )
    ,all_trip_ids_for_range as ( ---New code to pull all trip ids for rentals correctly and eliminate the need for mutiple ctes and unions further in the statement
    select
       f.value as trip_id
    from
      asset_list_own alo
      join hourly_asset_usage h on
           alo.asset_id = h.asset_id,
           lateral flatten(input => source_metadata:trip_ids) f
    where
        report_range:start_range >= to_varchar(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start trip_log_report.date_filter %}), 'yyyy-mm-dd hh:mm:ss TZH')
    union
    select
      f.value as trip_id
    from
      asset_list_rental alr
      join hourly_asset_usage h2 on
              alr.asset_id = h2.asset_id
              AND h2.report_range:start_range >= alr.start_date
              AND h2.report_range:end_range <= alr.end_date,
              lateral flatten(input => source_metadata:trip_ids) f
    where
        report_range:start_range >= to_varchar(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start trip_log_report.date_filter %}), 'yyyy-mm-dd hh:mm:ss TZH')
    )
    ,owned_and_rental_assets as (
    select
      asset_id
    from
      asset_list_own
    UNION
    select
      asset_id
    from
      asset_list_rental
    )
    , trip_details as (
    select
      t.trip_id,
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
      t.end_odometer,
      te.posted_speed_limit
      from
      all_trip_ids_for_range atl
      join trips t on t.trip_id = atl.trip_id
      join tracking_events te on t.trip_id = te.trip_id
      left join tracking_incidents ti on ti.tracking_event_id = te.tracking_event_id
      left join tracking_incident_types tiy on tiy.tracking_incident_type_id = ti.tracking_incident_type_id and ti.tracking_incident_type_id in (5,17,19,20,14,15,18,28,29)
      left join states st on st.state_id = te.state_id
      where
      t.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start trip_log_report.date_filter %})
      AND t.start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end trip_log_report.date_filter %})
    )
    select
            trip_id,
            asset_id,
            date_time::timestamp as date_time,
            status,
            lat,
            long,
            concat_ws(', ', street, city, abbreviation) as location,
            speed,
            trip_odo_miles,
            coalesce(end_odometer - lag(end_odometer,1) over (partition by asset_id order by asset_id, end_odometer, date_time),0) as odo_diff,
            posted_speed_limit
    from trip_details
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

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  filter: date_filter {
    type: date_time
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
    value_format_name: decimal_2
  }

  dimension: posted_speed_limit {
    type: number
    sql: ${TABLE}."POSTED_SPEED_LIMIT" ;;
  }

  # dimension: end_odometer {
  #   type: number
  #   sql: ${TABLE}."END_ODOMETER" ;;
  # }

  dimension: lat_long {
    label: "Lat/Long"
    type: string
    sql: concat(${lat},', ',${long});;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ trip_log_report_detail.lat._value }},{{ trip_log_report_detail.long._value }}" target="_blank">View Map</a></font></u> ;;
  }

  # dimension: does_trip_have_location {
  #   type: string
  #   sql: ${TABLE}."DOES_TRIP_HAVE_LOCATION" ;;
  # }

  # dimension: flag_trips_with_location {
  #   type: yesno
  #   sql: ${does_trip_have_location} = 'Location' ;;
  # }

  dimension: date_time_formatted {
    group_label: "HTML Passed Date Format" label: "Trip Date Time"
    sql: ${date_time} ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  filter: custom_name_filter {
    suggest_explore: trip_log_report
    suggest_dimension: assets.custom_name
  }

  filter: groups_filter {
    suggest_explore: trip_log_report
    suggest_dimension: organizations.groups
  }

  filter: ownership_filter {
    suggest_explore: trip_log_report
    suggest_dimension: assets.asset_class
  }

  filter: asset_class_filter {
  }

  filter: asset_type_filter {
  }

  set: detail {
    fields: [organizations.groups, assets.custom_name, asset_id, date_time, status, lat_long, location, speed, trip_odo_miles, odo_diff]
  }
}
