view: asset_photos_url_path {
 derived_table: {
  sql:
  with photo_count_greater_then_one as (
   SELECT ap.asset_id, COUNT(*) AS photo_count
      FROM es_warehouse.public.asset_photos ap
      JOIN es_warehouse.public.assets a ON a.asset_id = ap.asset_id
      JOIN es_warehouse.public.companies c ON c.company_id = a.company_id
      WHERE a.company_id NOT IN (420, 16184)
      GROUP BY ap.asset_id
      HAVING COUNT(*) > 1
  )
  select ap.asset_id, p.*, pc.photo_count, 'https://appcdn.equipmentshare.com/uploads/large/' || filename as full_url_path
  from es_warehouse.public.asset_photos ap
    join es_warehouse.public.photos p on p.photo_id = ap.photo_id
    join photo_count_greater_then_one pc on pc.asset_id = ap.asset_id ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension_group: _es_update_timestamp {
  type: time
  sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
}

dimension: photo_id {
  type: number
  sql: ${TABLE}."PHOTO_ID" ;;
}

dimension: uploading_user_id {
  type: number
  sql: ${TABLE}."UPLOADING_USER_ID" ;;
}

dimension: photo_count {
  type: number
  sql: ${TABLE}."PHOTO_COUNT" ;;
}

dimension: filename {
  type: string
  sql: ${TABLE}."FILENAME" ;;
}

dimension: thumbnail {
  type: yesno
  sql: ${TABLE}."THUMBNAIL" ;;
}

dimension: small {
  type: yesno
  sql: ${TABLE}."SMALL" ;;
}

dimension: medium {
  type: yesno
  sql: ${TABLE}."MEDIUM" ;;
}

dimension: large {
  type: yesno
  sql: ${TABLE}."LARGE" ;;
}

dimension: file_problem {
  type: yesno
  sql: ${TABLE}."FILE_PROBLEM" ;;
}

dimension: original_metadata {
  type: string
  sql: ${TABLE}."ORIGINAL_METADATA" ;;
}

dimension: full_url_path {
  type: string
  sql: ${TABLE}."FULL_URL_PATH" ;;
}

  dimension: image {
    type: string
    sql: ${full_url_path} ;;
    html:  <img src={{rendered_value}} height="170" width="255">  ;;
  }


set: detail {
  fields: [
    asset_id,
    _es_update_timestamp_time,
    photo_id,
    uploading_user_id,
    filename,
    thumbnail,
    small,
    medium,
    large,
    file_problem,
    original_metadata,
    full_url_path
  ]
}
}
