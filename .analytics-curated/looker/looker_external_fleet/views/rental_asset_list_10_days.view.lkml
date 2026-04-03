view: rental_asset_list_10_days {
  derived_table: {
    sql: select asset_id,
    start_date,
    end_date,
    case when current_date - interval '9 days' >= start_date then current_date - interval '9 days' else start_date end as modified_start_date
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',  current_date::timestamp_ntz - interval '9 days'),
    convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz),
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

  dimension_group: modified_start_date {
    type: time
    sql: ${TABLE}."MODIFIED_START_DATE" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  set: detail {
    fields: [asset_id, start_date_time, end_date_time]
  }
}