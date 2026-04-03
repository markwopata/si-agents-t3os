view: map_reports {

  derived_table: {

    sql:
    SELECT
      te.trip_id                                AS trip_id,
      te.asset_id                               AS asset_id,
      convert_timezone('{{ _user_attributes['user_timezone'] }}',te.report_timestamp) as report_timestamp,
      te.location_lat                           AS latitude,
      te.location_lon                           AS longitude,
      te.speed                                  AS speed
    FROM
      public.tracking_events te
    WHERE
      te.asset_id IN (select asset_id from table(assetlist('{{ _user_attributes['user_id'] }}'::numeric)))
      AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',
                                                  {% date_start date_filter %})
      AND te.report_timestamp <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',
                                                  {% date_end   date_filter %})
      AND te.speed >= {{ speeding_threshold._parameter_value }}
      AND te.location_lat IS NOT NULL
      AND te.location_lon IS NOT NULL
    --ORDER BY te.report_timestamp DESC
    --LIMIT 5000
    ;;

  }

  parameter: speeding_threshold {
    label: "Speeding Threshold (MPH)"
    # For the rebuilt Speeding Threshold Map
    type: unquoted
    default_value: "70"
  }

  filter: date_filter {
    type: date_time
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${TABLE}."TRIP_ID"::text, ${TABLE}."REPORT_TIMESTAMP"::text, ${TABLE}."ASSET_ID"::text) ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: report_timestamp {
    label: "Date"
    type: date_time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: location {
    type: location
    sql_latitude:  ${TABLE}."LATITUDE" ;;
    sql_longitude: ${TABLE}."LONGITUDE" ;;
  }

  dimension: speed {
    label: "Speed (MPH)"
    type: number
    sql: ${TABLE}."SPEED" ;;
  }


}