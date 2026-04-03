view: cameras_last_contact_and_request {
  derived_table: {
    sql: select
        a.asset_id,
        c.camera_id,
        c.device_serial,
        ce.last_contact,
        amrl.last_request_date
    from
        assets a
        inner join cameras c on a.camera_id = c.camera_id
        left join (select max(date_created) as last_contact, asset_id, camera_id from camera_events group by asset_id, camera_id) ce on ce.camera_id = c.camera_id and a.asset_id = ce.asset_id
        left join (select max(date_created) as last_request_date, camera_id from api_media_request_logs group by camera_id) amrl on amrl.camera_id = c.camera_id
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

  dimension: camera_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CAMERA_ID" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension_group: last_contact {
    type: time
    sql: ${TABLE}."LAST_CONTACT" ;;
  }

  dimension_group: last_request_date {
    type: time
    sql: ${TABLE}."LAST_REQUEST_DATE" ;;
  }

  dimension: out_of_lock_over_72_hours {
    type: number
    sql: datediff(hours,${last_contact_raw},current_timestamp) ;;
  }

  dimension: out_of_lock_flag {
    type: yesno
    sql: datediff(hours, ${last_contact_raw}, current_timestamp) > 72 ;;
  }

  measure: out_of_lock_count {
    type: count_distinct
    sql: ${camera_id} ;;
    filters: [out_of_lock_flag: "Yes"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, camera_id, device_serial, last_contact_time, last_request_date_time]
  }
}
