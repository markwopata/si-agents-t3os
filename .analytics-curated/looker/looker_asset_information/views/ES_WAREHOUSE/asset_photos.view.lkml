view: asset_photos {

    sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSET_PHOTOS"
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

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: photo_id {
      type: number
      sql: ${TABLE}."PHOTO_ID" ;;
    }

    set: detail {
      fields: [
        _es_update_timestamp_time,
        _es_load_timestamp_time,
        asset_id,
        photo_id
      ]
    }
  }
