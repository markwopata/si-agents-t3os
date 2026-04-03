view: ifta_report {
  derived_table: {
    sql: select
            fsm.*,
            a.asset_class as equipment_class
            FROM TABLE(sharing.f_state_mileage (1851::numeric,
                            'America/Chicago',
                            convert_timezone('America/Chicago', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz,
                            convert_timezone('America/Chicago', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz)) fsm
            left join public.assets a on a.asset_id = fsm.asset_id
            left join public.asset_settings ast on a.asset_settings_id = ast.asset_settings_id
            left join public.states s on lower(fsm.name) = lower(s.name)
            left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
            where a.asset_type_id in (1,2)
              AND {% condition dot_number_filter %} d.dot_number {% endcondition %}
              AND {% condition asset_filter %} a.custom_name {% endcondition %}
              AND {% condition class_filter %} a.asset_class {% endcondition %}
              and (lower(a.asset_class) like lower('%water truck%')
              or lower(a.asset_class) like lower('%single axle dump truck%')
              or lower(a.asset_class) like lower('%dual axle dump truck%')
              or lower(a.asset_class) like lower('%delivery%')
              or lower(a.asset_class) like lower('%3/4 Ton Non-Rental Pickup Truck%')
              or lower(a.asset_class) like lower('%3/4 Ton Rental Truck%')
              or lower(a.asset_class) like lower('%1 Ton Rental Truck%')
              or lower(a.asset_class) like lower('%1 Ton Non-Rental Pickup Truck%')
              or lower(a.asset_class) like lower('%Rental Stake bed-Class 6/7%'))
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

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: name {
    label: "State"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: state_entry {
    group_label: "Table Values"
    type: string
    sql: TO_TIMESTAMP_TZ(${TABLE}."STATE_ENTRY", 'mon-dd-yyyy HH12:mi:ss AM') ;;
  }

  dimension: state_exit {
    group_label: "Table Values"
    type: string
    sql: TO_TIMESTAMP_TZ(${TABLE}."STATE_EXIT", 'mon-dd-yyyy HH12:mi:ss AM') ;;
  }

  dimension: start_odometer {
    type: string
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: end_odometer {
    type: string
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
    value_format_name: decimal_2
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

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: start_lat_long {
    label: "Start Location"
    type: string
    sql:  concat_ws(', ', ${start_lat}, ${start_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ mileage_state_entry_exit.start_lat._value }},{{ mileage_state_entry_exit.start_lon._value }}" target="_blank">{{ mileage_state_entry_exit.start_lat._value }}, {{ mileage_state_entry_exit.start_lon._value }}</a></font></u> ;;
  }

  dimension: end_lat_long {
    label: "End Location"
    type: string
    sql:  concat_ws(', ', ${end_lat}, ${end_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ mileage_state_entry_exit.end_lat._value }},{{ mileage_state_entry_exit.end_lon._value }}" target="_blank">{{ mileage_state_entry_exit.end_lat._value }}, {{ mileage_state_entry_exit.end_lon._value }}</a></font></u> ;;
  }

  dimension: state_entry_formatted {
    type: date_time
    label: "State Entry"
    sql: ${state_entry};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} ;;
  }

  dimension: state_exit_formatted {
    type: date_time
    label: "State Exit"
    sql: ${state_exit};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} ;;
  }

  dimension: make_model {
    type:  string
    sql: concat_ws(' ', coalesce(${make},''),coalesce(${model},'')) ;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: class_filter {
    type: string
  }

  filter: dot_number_filter {
    type: string
  }

  filter: asset_filter {
    type: string
  }

  set: detail {
    fields: [
        asset_id,
  custom_name,
  make,
  model,
  name,
  state_entry,
  state_exit,
  start_odometer,
  end_odometer,
  miles_driven,
  start_lat,
  start_lon,
  end_lat,
  end_lon
    ]
  }
}
