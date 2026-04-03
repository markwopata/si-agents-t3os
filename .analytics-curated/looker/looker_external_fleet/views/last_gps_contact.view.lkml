view: last_gps_contact {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      --from table(assetlist(14814::numeric))
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      select
          alo.asset_id,
          case
            when gpsf.start_stale_gps_fix_timestamp = '1970-01-01 00:00:00'::timestamp_ntz and llt.last_location_timestamp <> '1970-01-01 00:00:00'::timestamp_ntz
                  then coalesce(convert_timezone('{{ _user_attributes['user_timezone'] }}', llt.last_location_timestamp),convert_timezone('{{ _user_attributes['user_timezone'] }}', sc.latest_gps_fix_timestamp))
            when gpsf.start_stale_gps_fix_timestamp = '1970-01-01 00:00:00'::timestamp_ntz and llt.last_location_timestamp = '1970-01-01 00:00:00'::timestamp_ntz
                  then convert_timezone('{{ _user_attributes['user_timezone'] }}', sc.latest_gps_fix_timestamp)
            else
                 coalesce(convert_timezone('{{ _user_attributes['user_timezone'] }}', gpsf.start_stale_gps_fix_timestamp),
                          convert_timezone('{{ _user_attributes['user_timezone'] }}', llt.last_location_timestamp),
                          convert_timezone('{{ _user_attributes['user_timezone'] }}', sc.latest_gps_fix_timestamp))
          end as last_gps_contact
      from
          asset_list_own alo
          left join trackers_mapping tm on tm.asset_id = alo.asset_id
          left join tracker_state_cache sc on sc.tracker_id = tm.esdb_tracker_id
          left join (select alo.asset_id, akv.value as start_stale_gps_fix_timestamp from asset_list_own alo join asset_status_key_values akv on akv.asset_id = alo.asset_id where akv.name = 'start_stale_gps_fix_timestamp') gpsf on gpsf.asset_id = alo.asset_id
          left join (select alo.asset_id, akv.value as last_location_timestamp from asset_list_own alo join asset_status_key_values akv on akv.asset_id = alo.asset_id where akv.name = 'last_location_timestamp') llt on llt.asset_id = alo.asset_id
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

  dimension_group: last_gps_contact {
    type: time
    sql: ${TABLE}."LAST_GPS_CONTACT" ;;
  }

  dimension: last_gps_contact_formatted {
    group_label: "Created" label: "Last GPS Contact"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_gps_contact_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  set: detail {
    fields: [asset_id, last_gps_contact_time]
  }
}