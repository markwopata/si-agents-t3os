view: asset_current_geofence {
  derived_table: {
    sql: with asset_list as (
        select asset_id
        from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
        union
        select asset_id
        from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
        '{{ _user_attributes['user_timezone'] }}'))
        )
        select
            al.asset_id,
            g.geofence_id,
            g.name as geofence_name
        from
            asset_list al
            left join asset_geofence_encounters agc on agc.asset_id = al.asset_id
            left join geofences g on g.geofence_id = agc.geofence_id AND agc.encounter_end_timestamp is null AND agc.encounter_start_timestamp is not null
        where
          g.deleted = false
          and g.company_id = {{ _user_attributes['company_id'] }}::numeric
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

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: geofence_name {
    type: string
    sql: ${TABLE}."GEOFENCE_NAME" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/geofences/{{ asset_current_geofence.geofence_id._value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: list_location {
    type: string
    sql: ${asset_last_location.last_location}  ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset//history?selectedDate=" target="_blank">{{value}}</a></font></u> ;;
  }

  measure: last_location {
    type: list
    list_field: list_location
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  set: detail {
    fields: [asset_id, geofence_name]
  }
}