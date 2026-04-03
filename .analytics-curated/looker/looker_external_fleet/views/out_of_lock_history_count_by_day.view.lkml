view: out_of_lock_history_count_by_day {
  derived_table: {
    sql: with asset_list as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      , asset_list_rental as
      (
      select asset_id, start_date, end_date
      from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp::date::timestamp_ntz),
      convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp::date::timestamp_ntz),
      '{{ _user_attributes['user_timezone'] }}'))
      )
      select
        snapshot_date::date as snapshot_date,
        al.asset_id
      from
          out_of_lock_7_days_rolling ool
          join asset_list al on al.asset_id = ool.asset_id
      where
          over_72_hours_flag = TRUE
          AND ool.company_id = {{ _user_attributes['company_id'] }}
      UNION
      select
        snapshot_date::date as snapshot_date,
        al.asset_id
      from
          out_of_lock_7_days_rolling ool
          join asset_list_rental al on al.asset_id = ool.asset_id and al.start_date >= ool.snapshot_date and al.end_date <= ool.snapshot_date
      where
          over_72_hours_flag = TRUE
       ;;
  }

  measure: count {
    type: count
    drill_fields: [assets.custom_name, assets.asset_id, assets.make, assets.model, asset_types.asset_type, categories.name, trackers.tracker_information,out_of_lock_7_days_rolling.snapshot_date,out_of_lock_7_days_rolling.asset_id,out_of_lock_7_days_rolling.out_of_lock_reason,out_of_lock_7_days_rolling.out_of_lock_timestamp_date, asset_last_location.last_contact_time_formatted, asset_last_location.last_location_time_formatted, asset_last_location.address, out_of_lock_7_days_rolling.unplugged_flag]
  }

  dimension: snapshot_date {
    type: date
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  set: detail {
    fields: [snapshot_date, asset_id]
  }
}