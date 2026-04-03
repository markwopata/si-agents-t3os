view: work_order_files {

  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_FILES"
    ;;
  drill_fields: [work_order_file_id]

  dimension: work_order_file_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_FILE_ID" ;;
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

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  measure: total_created_by {
    type: sum
    sql: ${created_by} ;;
  }

  measure: average_created_by {
    type: average
    sql: ${created_by} ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_deleted {
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
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: metadata_id {
    type: number
    sql: ${TABLE}."METADATA_ID" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  dimension: image_yn {
    type: yesno
    sql: ${url} ilike '%.jpeg%' ;;
  }

  dimension: url_link {
    type: string
    sql: ${TABLE}."URL" ;;
    html: <a href="{{rendered_value}}">Link to image</a> ;;
  }

  dimension: img_embed {
    type: string
    sql: ${TABLE}."URL" ;;
    html: <a href={{rendered_value}}><img src={{rendered_value}} width="60%" height="60%"></a> ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [work_order_file_id]
  }

  measure: count_images {
    type: count_distinct
    sql: ${work_order_file_id} ;;
    filters: [image_yn: "yes"]
    drill_fields: [img_embed]
  }
}

view: work_order_image_count {
  derived_table: {
    sql:
        select
          work_order_id,
          count(distinct work_order_file_id) as count_images
        from ${work_order_files.SQL_TABLE_NAME}
        where url ilike '%.jpeg%'
        group by work_order_id;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension: count_images {
    type: number
    sql: ${TABLE}."COUNT_IMAGES" ;;
  }
}
