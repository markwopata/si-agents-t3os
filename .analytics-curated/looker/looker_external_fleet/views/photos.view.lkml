view: photos {
  sql_table_name: "PUBLIC"."PHOTOS"
    ;;
  drill_fields: [photo_id]

  dimension: photo_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: file_problem {
    type: yesno
    sql: ${TABLE}."FILE_PROBLEM" ;;
  }

  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }

  dimension: large {
    type: yesno
    sql: ${TABLE}."LARGE" ;;
  }

  dimension: medium {
    type: yesno
    sql: ${TABLE}."MEDIUM" ;;
  }

  dimension: original_metadata {
    type: string
    sql: ${TABLE}."ORIGINAL_METADATA" ;;
  }

  dimension: small {
    type: yesno
    sql: ${TABLE}."SMALL" ;;
  }

  dimension: thumbnail {
    type: yesno
    sql: ${TABLE}."THUMBNAIL" ;;
  }

  dimension: uploading_user_id {
    type: number
    sql: ${TABLE}."UPLOADING_USER_ID" ;;
  }

  dimension: photo_link {
    type: string
    sql: concat('https://appcdn.equipmentshare.com/uploads/',${filename}) ;;
  }

  dimension: asset_photos {
    type: string
    sql: ${photo_link} ;;
    html: <img src={{photo_link._value}} height=50 width=50> ;;
  }

  measure: count {
    type: count
    drill_fields: [photo_id, filename]
  }
}
