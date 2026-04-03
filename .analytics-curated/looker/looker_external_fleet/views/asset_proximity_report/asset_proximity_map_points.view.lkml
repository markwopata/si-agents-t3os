view: asset_proximity_map_points {
  derived_table: {
    sql: with asset_list_own as (
      select
        alo.asset_id,
        a.custom_name as asset,
        concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
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
        concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
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
      , tracking_events_location as (
      select
          a.asset_id,
          a.asset,
          a.asset_type,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', te.report_timestamp) as report_timestamp,
          te.location_lat,
          te.location_lon,
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
          convert_timezone('{{ _user_attributes['user_timezone'] }}', te.report_timestamp) as report_timestamp,
          te.location_lat,
          te.location_lon,
          haversine(location_lat,location_lon, ads.user_entered_location_lat, ads.user_entered_location_lon) as distance
      from
          tracking_events te
          join asset_list_rental a on a.asset_id = te.asset_id
          join address_selection ads on 1=1
      where
          location_lon is not null
          and location_lat is not null
          AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
          AND te.report_timestamp <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      )
      select
          tel.report_timestamp,
          tel.asset_id,
          tel.asset,
          tel.asset_type,
          tel.location_lat,
          tel.location_lon,
          tel.distance
      from
          tracking_events_location tel
      where
          round(distance,2) <=
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

  dimension_group: report_timestamp {
    type: time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: location_lat {
    type: number
    sql: ${TABLE}."LOCATION_LAT" ;;
  }

  dimension: location_lon {
    type: number
    sql: ${TABLE}."LOCATION_LON" ;;
  }

  dimension: distance {
    type: number
    sql: ${TABLE}."DISTANCE" ;;
  }

  dimension: map_location {
    type: location
    sql_latitude: ${location_lat} ;;
    sql_longitude: ${location_lon} ;;
  }

  dimension: report_timestamp_formatted {
    group_label: "HTML Date Format"
    label: "Report Timestamp"
    type: date_time
    sql: ${report_timestamp_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  filter: date_filter {
    type: date_time
  }

  parameter: lat {
    type: string
  }

  parameter: lon {
    type: string
  }

  parameter: distance_selection {
    type: unquoted
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

  filter: license_plate_filter {
  }

  set: detail {
    fields: [asset_id, asset, location_lat, location_lon, distance]
  }
}
