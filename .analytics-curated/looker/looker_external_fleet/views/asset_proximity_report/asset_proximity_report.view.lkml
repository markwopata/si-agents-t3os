view: asset_proximity_report {
  derived_table: {
    sql: with asset_list_own as (
      select
        alo.asset_id,
        a.custom_name as asset,
        concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
        ai.license_plate_number
      from
        table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
        join assets a on alo.asset_id = a.asset_id
        left join asset_types ast on ast.asset_type_id = a.asset_type_id
        left join business_intelligence.triage.stg_t3__asset_info ai on alo.asset_id = ai.asset_id
      where
        {% condition custom_name_filter %} a.custom_name {% endcondition %}
        AND {% condition asset_type_filter %} ast.name {% endcondition %}
        AND {% condition license_plate_filter %} ai.license_plate_number {% endcondition %}
      )
      , asset_list_rental as (
      select
        alo.asset_id,
        alo.start_date,
        alo.end_date,
        a.custom_name as asset,
        concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type,
        ai.license_plate_number
      from
        table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
        '{{ _user_attributes['user_timezone'] }}')) alo
        join assets a on alo.asset_id = a.asset_id
        left join asset_types ast on ast.asset_type_id = a.asset_type_id
        left join business_intelligence.triage.stg_t3__asset_info ai on alo.asset_id = ai.asset_id
      where
        {% condition custom_name_filter %} a.custom_name {% endcondition %}
        AND {% condition asset_type_filter %} ast.name {% endcondition %}
        AND {% condition license_plate_filter %} ai.license_plate_number {% endcondition %}
      )
      ,selected_address as (
      select
          {% parameter lat %} as selected_lat,
          {% parameter lon %} as selected_lon
      from
          tracking_events te
      limit 1
      )
      , address_selection as (
      select
        selected_lon as user_entered_location_lon,
        selected_lat as user_entered_location_lat
      from
        selected_address
      limit 1
      )
      , distance_from_address as (
      select
          a.asset_id,
          a.asset,
          a.asset_type,
          a.license_plate_number,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', te.report_timestamp) as report_timestamp,
          haversine(location_lat,location_lon, ads.user_entered_location_lat, ads.user_entered_location_lon) as distance
      from
          tracking_events te
          join asset_list_own a on a.asset_id = te.asset_id
          join address_selection ads on 1=1
      where
          location_lon is not null
          and location_lat is not null
          AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND te.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      UNION
          select
          a.asset_id,
          a.asset,
          a.asset_type,
          a.license_plate_number,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', te.report_timestamp) as report_timestamp,
          haversine(location_lat,location_lon, ads.user_entered_location_lat, ads.user_entered_location_lon) as distance
      from
          tracking_events te
          join asset_list_rental a on a.asset_id = te.asset_id
          join address_selection ads on 1=1
      where
          location_lon is not null
          and location_lat is not null
          AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND te.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      ),
      dfa_detail as (
      select
          dfa.asset_id,
          dfa.asset,
          dfa.asset_type,
          dfa.license_plate_number,
          min(dfa.report_timestamp) as earliest_entry_time,
          max(dfa.report_timestamp) as latest_exit_time,
          1 as flag
      from
          distance_from_address dfa
      group by
          dfa.asset_id,
          dfa.asset,
          dfa.asset_type,
          dfa.license_plate_number
      )
      select
      dfad.asset_id,
      dfad.asset,
      dfad.asset_type,
      dfad.license_plate_number,
      dfad.earliest_entry_time,
      dfad.latest_exit_time,
      dfad.flag
      from dfa_detail dfad
      left join distance_from_address dfa on dfa.asset_id = dfad.asset_id
      where
          round(dfa.distance,2) <=
          {% if measurement._parameter_value == "'Miles'" %}
          {% parameter distance_selection %} * 1.60934
          {% else %}
          {% parameter distance_selection %} * 0.0003048
          {% endif %}
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension_group: earliest_entry_time {
    type: time
    sql: ${TABLE}."EARLIEST_ENTRY_TIME" ;;
  }

  dimension_group: latest_exit_time {
    type: time
    sql: ${TABLE}."LATEST_EXIT_TIME" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: flag {
    type: number
    sql: ${TABLE}."FLAG" ;;
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: earliest_entrance_timestamp_formatted {
    group_label: "HTML Date Format"
    label: "Earliest Entrance Timestamp"
    type: date_time
    sql: ${earliest_entry_time_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: latest_exit_timestamp_formatted {
    group_label: "HTML Date Format"
    label: "Latest Exit Timestamp"
    type: date_time
    sql: ${latest_exit_time_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  # dimension: map_location {
  #   type: location
  #   sql_latitude: ${location_lat} ;;
  #   sql_longitude: ${location_lon} ;;
  # }

  filter: lat_filter {
    # default_value: "33.9427766"
  }

  filter: lon_filter {
    # default_value: "-91.8441228"
  }

  filter: license_plate_filter {
  }

  filter: address_filter {
    suggest_explore: unique_addresses_with_lat_lon
    suggest_dimension: unique_addresses_with_lat_lon.address
  }

  parameter: lat {
    type: string
    default_value: "40.21040745254945"
  }

  parameter: lon {
    type: string
    default_value: "-76.93913825595483"
  }

  parameter: distance_selection {
    type: unquoted
     default_value: "50000000"
  }

  parameter: measurement {
    type: string
    allowed_value: { value: "Miles"}
    allowed_value: { value: "Feet"}
  }

  filter: asset_type_filter {
  }

  filter: custom_name_filter {
  }


  set: detail {
    fields: [
      asset_id
    ]
  }
}
