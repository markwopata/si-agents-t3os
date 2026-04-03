view: rental_asset_list_current {
  derived_table: {
    sql: select asset_id,
    start_date,
    end_date
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    convert_timezone('{{ _user_attributes['user_timezone'] }}',current_timestamp)::date::timestamp_ntz,
    '{{ _user_attributes['user_timezone'] }}'))
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

  dimension_group: start_date {
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  set: detail {
    fields: [asset_id, start_date_time, end_date_time]
  }
}