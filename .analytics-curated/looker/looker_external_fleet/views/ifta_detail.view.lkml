view: ifta_detail {
  derived_table: {
    sql:
  select * FROM TABLE(sharing.f_ifta_detail ({{ _user_attributes['user_id'] }}::numeric,
                      '{{ _user_attributes['user_timezone'] }}',
                      convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz,
                      convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz));;

  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${name}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: end_lat {
    type: number
    sql: ${TABLE}."END_LAT" ;;
  }

  dimension: end_lon {
    type: number
    sql: ${TABLE}."END_LON" ;;
  }

  dimension: end_odometer {
    type: string
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: make_model {
    type:  string
    sql: concat_ws(' ', coalesce(${make},''),coalesce(${model},'')) ;;
  }


  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: name {
    label: "State"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: report_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
    label: "Start Location"
    type: string
    sql:  concat_ws(', ', ${start_lat}, ${start_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ ifta_detail.start_lat._value }},{{ ifta_detail.start_lon._value }}" target="_blank">{{ ifta_detail.start_lat._value }}, {{ ifta_detail.start_lon._value }}</a></font></u> ;;
  }

  dimension: end_lat_long {
    label: "End Location"
    type: string
    sql:  concat_ws(', ', ${end_lat}, ${end_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ ifta_detail.end_lat._value }},{{ ifta_detail.end_lon._value }}" target="_blank">{{ ifta_detail.end_lat._value }}, {{ ifta_detail.end_lon._value }}</a></font></u> ;;
  }

  dimension: start_odometer {
    type: string
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: state_entry {
    label: "State Entry Timestamp Format"
    sql:TO_TIMESTAMP_TZ(${TABLE}."STATE_ENTRY", 'mon-dd-yyyy HH12:mi:ss AM');;
  }

  dimension: state_entry_formatted {
    type: date_time
    label: "State Entry"
    sql: ${state_entry};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: state_exit {
    label: "State Exit Timestamp Format"
    sql: TO_TIMESTAMP_TZ(${TABLE}."STATE_EXIT", 'mon-dd-yyyy HH12:mi:ss AM') ;;
  }

  dimension: state_exit_formatted {
    type: date_time
    label: "State Exit"
    sql: ${state_exit};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  filter: date_filter {
    type: date_time
  }

  measure: total_miles_driven {
    type: sum
    sql: ${miles_driven} ;;
  }

  measure: count {
    type: count
    drill_fields: [name, custom_name]
  }
}
