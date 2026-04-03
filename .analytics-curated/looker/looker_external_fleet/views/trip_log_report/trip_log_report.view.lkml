view: trip_log_report {
  derived_table: {
    sql:
    with asset_list_own as (
    select distinct ai.asset_id from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai
    left join es_warehouse.public.organization_asset_xref ox on  ox.asset_id = ai.asset_id
    left join es_warehouse.public.organizations o on  o.organization_id = ox.organization_id
    where ai.company_id in (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric
    )
    and {% condition custom_name_filter %} ai.custom_name {% endcondition %}
    and {% condition groups_filter %} o.name {% endcondition %}
    and {% condition asset_class_filter %} ai.asset_class {% endcondition %}
    and {% condition asset_type_filter %} ai.asset_type {% endcondition %}
    and {% condition license_plate_number_filter %} ai.license_plate_number {% endcondition %}
    and {% condition license_plate_state_filter %} ai.license_plate_state {% endcondition %}
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
   and {% condition custom_name_filter %} ai.custom_name {% endcondition %}
    and {% condition groups_filter %} o.name {% endcondition %}
    and {% condition asset_class_filter %} ai.asset_class {% endcondition %}
    and {% condition asset_type_filter %} ai.asset_type {% endcondition %}
    and {% condition license_plate_number_filter %} ai.license_plate_number {% endcondition %}
    and {% condition license_plate_state_filter %} ai.license_plate_state {% endcondition %}
    )
    ,all_trip_ids_for_range as (
    select
       f.value as trip_id
    from
      asset_list_own alo
      join hourly_asset_usage h on
           alo.asset_id = h.asset_id,
           lateral flatten(input => source_metadata:trip_ids) f
    where
        report_range:start_range >= to_varchar(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), 'yyyy-mm-dd hh:mm:ss TZH')
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
        report_range:start_range >= to_varchar(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}), 'yyyy-mm-dd hh:mm:ss TZH')
    )
    ,owned_and_rental_assets as ( --Code to combine all asset ids together
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
    , base as (
    SELECT
      t.trip_id,
      a.asset_id,
      ai.license_plate_number,
      ai.license_plate_state,
      to_char(trip_time_seconds::timestamp,'HH24:MI:SS') as trip_length,
      t.start_timestamp,
      start_street,
      start_city,
      coalesce(st1.abbreviation, '') as start_state,
      start_lat,
      start_lon,
      end_timestamp,
      end_street,
      end_city,
      coalesce(st2.abbreviation, '') as end_state,
      end_lat,
      end_lon,
      start_geofence_id,
      end_geofence_id,
      t.trip_distance_miles,
      coalesce(t.end_hours,0) - coalesce(t.start_hours,0) as asset_hours,
      TO_CHAR(coalesce(t.idle_duration,0)::timestamp, 'HH24:MI:SS') as idle_time,
      t.start_odometer as start_odometer,
      case  when (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters) is null then 'N/A'
            when t.end_total_fuel_used_liters = t.start_total_fuel_used_liters  then '<1'
            else (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters)::text
            end as fuel_used,
      coalesce((t.end_total_fuel_used_liters - t.start_total_fuel_used_liters),0) as fuel_used_var,
      start_hours,
      t.end_odometer as end_odometer,
      end_hours,
      case when trip_type_id = 2 then TO_CHAR(t.trip_time_seconds::timestamp, 'HH24:MI:SS') else '00:00:00' end as hauling_time,
      case when trip_type_id = 2 then t.trip_distance_miles else 0 end as hauling_distance
    from all_trip_ids_for_range alt
        join trips T on t.trip_id = alt.trip_id
        JOIN owned_and_rental_assets a on a.asset_id = t.asset_id
        left join states st1 on st1.state_id = T.start_state_id
        left join states st2 on st2.state_id = T.end_state_id
        left join business_intelligence.triage.stg_t3__asset_info ai on a.asset_id = ai.asset_id
    where
        t.start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        AND t.start_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and t.trip_time_seconds > 12
        and {% condition ownership_filter %} a.ownership {% endcondition %}
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
    select
        b.trip_id,
        asset_id,
        license_plate_number,
        license_plate_state,
        fuel_used,
        trip_length,
        start_timestamp,
        start_lat,
        start_lon,
        end_timestamp,
        end_lat,
        end_lon,
        trip_distance_miles,
        asset_hours,
        idle_time,
        start_odometer,
        start_hours,
        end_odometer,
        end_hours,
        hauling_time,
        hauling_distance,
        case when start_street IS not NULL then concat(start_street, coalesce(concat(', ',start_city), ''), coalesce(concat(', ',start_state), ''))
             ELSE concat(start_lat, '/', start_lon)
             end AS start_location,

      case when end_street IS not NULL then concat(end_street, coalesce(concat(', ',end_city), ''), coalesce(concat(', ',end_state), ''))
      ELSE concat(end_lat, '/', end_lon)
      end AS end_location
      from
      base b
      LEFT JOIN geofence_aggregation g ON g.trip_id = b.trip_id
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

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: fuel_used {
    type: number
    sql: ${TABLE}."FUEL_USED" ;;
    skip_drill_filter: yes
  }

  dimension: trip_length {
    type: string
    sql: ${TABLE}."TRIP_LENGTH" ;;
    skip_drill_filter: yes
  }

  filter: date_filter {
    type: date_time
  }

  dimension: start_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip Start Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."START_TIMESTAMP") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: end_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip End Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${TABLE}."END_TIMESTAMP") ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
    skip_drill_filter: yes
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
    skip_drill_filter: yes
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
    skip_drill_filter: yes
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
    skip_drill_filter: yes
  }

  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
    value_format_name: decimal_2
    skip_drill_filter: yes
  }

  dimension: idle_time {
    type: string
    sql: ${TABLE}."IDLE_TIME" ;;
    html:
      {% if value != '00:00:00' %}
      <p style="color: blue"><font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ trip_log_report.asset_id._value }}/history?selectedDate={{ trip_log_report.start_timestamp._value }}" target="_blank">{{ trip_log_report.idle_time._value }}</a></font></u></p>
      {% else %}
      <p style="color: dimgray">00:00:00</p>
      {% endif %};;
    skip_drill_filter: yes
  }

  dimension: start_odometer {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: start_hours {
    type: number
    sql: ${TABLE}."START_HOURS" ;;
  }

  dimension: end_odometer {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: end_hours {
    type: number
    sql: ${TABLE}."END_HOURS" ;;
  }

  dimension: hauling_time {
    type: string
    sql: ${TABLE}."HAULING_TIME" ;;
    skip_drill_filter: yes
  }

  dimension: hauling_distance {
    type: number
    sql: ${TABLE}."HAULING_DISTANCE" ;;
    skip_drill_filter: yes
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/?q={{ trip_log_report.start_location._value }}" target="_blank">{{ trip_log_report.start_location._value }}</a></font></u> ;;
    skip_drill_filter: yes
  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/?q={{ trip_log_report.end_location._value }}" target="_blank">{{ trip_log_report.end_location._value }}</a></font></u> ;;
    skip_drill_filter: yes
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [trip_detail*]
  }

  dimension: view_trip_details {
    group_label: "View Trip Details"
    label: " "
    type: string
    sql: ${trip_id} ;;
    html: <a href="#drillmenu" target="_self"><font color="#0063f3">View Trip Detail <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    # drill_fields: [trip_detail*]
    link: {
      label: "Click Here to View Selected Trip Details"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis= '{\"show_view_names\":false,
      \"show_row_numbers\":true,
      \"transpose\":false,
      \"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"left\",
      \"header_font_size\":12,
      \"rows_font_size\":12,
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"type\":\"looker_grid\",
      \"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
      \"show_y_axis_labels\":true,
      \"show_y_axis_ticks\":true,
      \"y_axis_tick_density\":\"default\",
      \"y_axis_tick_density_custom\":5,
      \"show_x_axis_label\":true,
      \"show_x_axis_ticks\":true,
      \"y_axis_scale_mode\":\"linear\",
      \"x_axis_reversed\":false,
      \"y_axis_reversed\":false,
      \"plot_size_by_field\":false,
      \"trellis\":\"\",
      \"stacking\":\"\",
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"defaults_version\":1,
      \"series_types\":{}}' %}

      {% assign dynamic_fields= '[]' %}

      {{dummy._link}}&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=trip_log_report_detail.date_time_formatted+asc"
    }
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

  filter: license_plate_number_filter {
  }

  filter: license_plate_state_filter {
  }


  set: detail {
    fields: [asset_id, organizations.groups, assets.custom_name, fuel_used, trip_length, start_timestamp, start_location, start_lat_long, end_timestamp, end_location, end_lat_long,
      hauling_time, hauling_distance]

    # , cumulative_fuel_used, start_geofences, end_geofences]
  }

  set: trip_detail {
    fields: [assets.custom_name, trip_log_report_detail.date_time_formatted, trip_log_report_detail.status, trip_log_report_detail.location, trip_log_report_detail.lat_long, trip_log_report_detail.posted_speed_limit,
      trip_log_report_detail.speed, trip_log_report_detail.trip_odo_miles, trip_log_report_detail.odo_diff]
  }
}
