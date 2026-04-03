view: asset_engines {
  derived_table: {
    sql:
select aes.asset_id
    , aes.engine_make_id
    , em.engine_make_name
    , aes.engine_model_name
    , aes.engine_serial_number
from ES_WAREHOUSE.PUBLIC.ASSET_ENGINE_SPECIFICATION aes
join ES_WAREHOUSE.PUBLIC.ENGINE_MAKES em
    on em.engine_make_id = aes.engine_make_id ;;
  }

 dimension: asset_id {
   type: number
  value_format_name: id
  sql: ${TABLE}.asset_id ;;
 }

  dimension: engine_make_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.engine_make_id ;;
  }

  dimension: engine_make_name {
    type: string
    sql: ${TABLE}.engine_make_name ;;
  }

  dimension: engine_model_name {
    type: string
    sql: ${TABLE}.engine_model_name ;;
  }

  dimension: engine_model_name_cleaned {
    type: string
    sql: IFF(LOWER(TRIM(COALESCE(${engine_model_name},''))) IN ('no model found','no info found','no results','n/a','unknown'), null, TRIM(${engine_model_name})) ;;
  }

  dimension: engine_serial_number {
    type: string
    sql: ${TABLE}.engine_serial_number ;;
  }
}
