view: asset_current_geofence {
  derived_table: {
    sql: with asset_list as (
        select asset_id
        from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
        union
        select asset_id
        from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('UTC', '{{ _user_attributes['company_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['company_timezone'] }}',  current_date::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
        )
        select
            al.asset_id,
            g.geofence_id,
            g.name as geofence_name
        from
            asset_list al
            left join asset_geofence_encounters agc on agc.asset_id = al.asset_id
            left join geofences g on g.geofence_id = agc.geofence_id AND agc.encounter_time_range:end_range is null AND agc.encounter_time_range:start_range is not null
        where
          g.deleted = false
          and g.company_id = {{ _user_attributes['company_id'] }}::numeric
       ;;
  }

  measure: geofence_count {
    type: count
    drill_fields: [detail*]
    view_label: "Assets"
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
    hidden: yes
  }

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."GEOFENCE_NAME" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/geofences/{{ asset_current_geofence.geofence_id._value }}" target="_blank">{{value}}</a></font></u>;;
    view_label: "Assets"
    label: "Current Geofence"
  }

  dimension: list_location {
    type: string
    sql: ${asset_last_location.last_location}  ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset//history?selectedDate=" target="_blank">{{value}}</a></font></u> ;;
    hidden: yes
  }

  measure: last_location {
    type: list
    list_field: list_location
    hidden: yes
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    hidden: yes
  }

  set: detail {
    fields: [asset_id, geofence_name]
  }
}
