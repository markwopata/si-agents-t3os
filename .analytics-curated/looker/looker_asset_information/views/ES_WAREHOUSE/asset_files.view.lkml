view: asset_files {

  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSET_FILES"
  ;;

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension_group: _es_update_timestamp {
  type: time
  sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
}

dimension_group: _es_load_timestamp {
  type: time
  sql: ${TABLE}."_ES_LOAD_TIMESTAMP" ;;
}

dimension: asset_file_id {
  type: number
  sql: ${TABLE}."ASSET_FILE_ID" ;;
}

dimension: original_filename {
  type: string
  sql: ${TABLE}."ORIGINAL_FILENAME" ;;
}

dimension: size_bytes {
  type: number
  sql: ${TABLE}."SIZE_BYTES" ;;
}

dimension: asset_id {
  type: number
  sql: ${TABLE}."ASSET_ID" ;;
}

dimension: url {
  type: string
  sql: ${TABLE}."URL" ;;
}

set: detail {
  fields: [
    _es_update_timestamp_time,
    _es_load_timestamp_time,
    asset_file_id,
    original_filename,
    size_bytes,
    asset_id,
    url
  ]
}
}
