view: trip_details {
  derived_table: {
    sql:
    with asset_list_own as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    ),
    asset_list_rental as (
    select asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), ('{{ _user_attributes['company_timezone'] }}')))
    ),
    all_trip_ids_for_range as (
    select f.value as trip_id
    from
    asset_list_own alo
    join hourly_asset_usage h on alo.asset_id = h.asset_id,
    lateral flatten(input => source_metadata:trip_ids) f
    where report_range:start_range >= to_varchar(convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)::timestamptz, 'yyyy-mm-dd hh:mm:ss TZH')
    union
    select f.value as trip_id
    from
    asset_list_rental alr
    join hourly_asset_usage h2 on alr.asset_id = h2.asset_id,
    lateral flatten(input => source_metadata:trip_ids) f
    where report_range:start_range >= to_varchar(convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)::timestamptz, 'yyyy-mm-dd hh:mm:ss TZH')
    )
    select
            t.asset_id,
            t.trip_id,
            case
                when t.start_timestamp < convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz) then convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)
                else t.start_timestamp
            end start_timestamp,
            case
                when t.end_timestamp > convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz) then convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)
                else t.end_timestamp
            end end_timestamp,
            concat(t.start_street,' ',t.start_city,', ',s.abbreviation) as start_location,
            concat(t.end_street,' ',t.end_city,', ',s2.abbreviation) as end_location,
            t.trip_distance_miles,
            case
                when t.start_timestamp < convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz) then round((t.trip_time_seconds - datediff(second, t.start_timestamp, convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)))/3600,2)
                when t.end_timestamp > convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz) then round((t.trip_time_seconds - datediff(second, convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), t.end_timestamp))/3600,2)
                else round(t.trip_time_seconds/3600,2)
            end as trip_hours,
            start_lat,
            end_lat,
            start_lon,
            end_lon,
            round(idle_duration/3600,1) as idle_hours
         from
            all_trip_ids_for_range alt
            join trips t on alt.trip_id = t.trip_id
            and
            t.end_timestamp >= convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)
                       and t.start_timestamp <= convert_timezone(('{{ _user_attributes['company_timezone'] }}'), 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz)
            left join states s on t.start_state_id = s.state_id
            left join states s2 on t.end_state_id = s2.state_id
           ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
    hidden: yes
  }

  dimension_group: start_timestamp {
    label: "Trip Start Date"
    type: time
    sql: ${TABLE}."START_TIMESTAMP" ;;
  }

  dimension_group: end_timestamp {
    label: "Trip End Date"
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/maps?q={{ trip_details.start_lat._value }},{{ trip_details.start_lon._value }}" target="_blank">{{ start_location._value }}</a></font></u> ;;
  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="http://maps.google.com/maps?q={{ trip_details.end_lat._value }},{{ trip_details.end_lon._value }}" target="_blank">{{ end_location._value }}</a></font></u> ;;
  }

  dimension: trip_start_time_formatted {
    group_label: "HTML Passed Date Format" label: "Trip Start Date"
    sql: convert_timezone(('{{ _user_attributes['company_timezone'] }}'),${start_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
  }

  dimension: trip_end_time_formatted {
    group_label: "HTML Passed Date Format" label: "Trip End Date"
    sql: convert_timezone(('{{ _user_attributes['company_timezone'] }}'),${end_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
    value_format_name: decimal_2
  }

  dimension: trip_hours {
    type: number
    sql: ${TABLE}."TRIP_HOURS" ;;
  }

  dimension: start_lat {
    type: number
    sql: ${TABLE}."START_LAT" ;;
    hidden: yes
  }

  dimension: end_lat {
    type: number
    sql: ${TABLE}."END_LAT" ;;
    hidden: yes
  }

  dimension: start_lon {
    type: number
    sql: ${TABLE}."START_LON" ;;
    hidden: yes
  }

  dimension: end_lon {
    type: number
    sql: ${TABLE}."END_LON" ;;
    hidden: yes
  }

  dimension: idle_hours {
    type: number
    sql: ${TABLE}."IDLE_HOURS" ;;
    value_format_name: decimal_2
    hidden: yes
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${start_timestamp_raw});;
    hidden: yes
  }

  filter: date_filter {
    type: date
  }

  measure: total_trip_hours {
    label: "Trip Length (hours)"
    type: sum
    sql: ${trip_hours} ;;
    value_format_name: decimal_2
    # html: <font color="blue"><u><a href="https://www.google.com/maps/dir/{{ trip_details.start_lat._value }},{{ trip_details.start_lon._value }}/{{ trip_details.end_lat._value }},+{{ trip_details.end_lon._value }}/@39.2284628,-92.7933467,11z/data=!3m1!4b1!4m7!4m6!1m0!1m3!2m2!1d{{ trip_details.end_lon._value }}!2d{{ trip_details.end_lat._value }}!3e0" target="_blank">{{ trip_hours._value }}</a></font></u> ;;
  }

  measure: total_idle_hours {
    label: "Idle Time (hours)"
    type: sum
    sql: ${idle_hours} ;;
    value_format_name: decimal_2
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ trip_details.asset_id._value }}/history?selectedDate={{ trip_details.start_timestamp_date._value }}" target="_blank">{{ value }}</a></font></u> ;;
  }

  measure: trip_miles {
    type: sum
    sql: ${trip_distance_miles} ;;
    value_format_name: decimal_2
  }

  dimension: link_to_idle_report {
    label: "View Idle Report"
    type: string
    sql: ${idle_hours} ;;
    value_format_name: decimal_1
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ trip_details.asset_id._value }}/history?selectedDate={{ trip_details.start_timestamp_date._value }}" target="_blank">{{ value }}</a></font></u> ;;
  }

  dimension: idle_minutes_show_link_or_zero {
    label: "Idle Time"
    type: number
    sql: case when ${idle_hours} > 0 then ${link_to_idle_report} else 0 end ;;
    value_format_name: decimal_1
    html:
    {% if value > 0 %}
    <p style="color: blue; font-weight: bold"><font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ trip_details.asset_id._value }}/history?selectedDate={{ trip_details.start_timestamp_date._value }}" target="_blank">{{ idle_minutes_show_link_or_zero._value }}</a></font></u></p>
    {% else %}
    <p style="color: dimgray">0</p>
    {% endif %};;
  }

  dimension: show_route_in_google_maps {
    label: "View Path"
    type: string
    sql: ${start_lat} ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/dir/{{ trip_details.start_lat._value }},{{ trip_details.start_lon._value }}/{{ trip_details.end_lat._value }},+{{ trip_details.end_lon._value }}/@39.2284628,-92.7933467,11z/data=!3m1!4b1!4m7!4m6!1m0!1m3!2m2!1d{{ trip_details.end_lon._value }}!2d{{ trip_details.end_lat._value }}!3e0" target="_blank">View Trip Path</a></font></u> ;;
  }

  set: detail {
    fields: [
      asset_id,
      trip_id,
      start_timestamp_time,
      end_timestamp_time,
      start_location,
      end_location,
      trip_distance_miles,
      trip_hours
    ]
  }
}
