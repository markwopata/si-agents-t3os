view: intacct_sandbox__items {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__ITEMS" ;;

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_gl_account_group_id {
    type: number
    sql: ${TABLE}."FK_GL_ACCOUNT_GROUP_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: string
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }
  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }
  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: pk_item_id {
    type: number
    sql: ${TABLE}."PK_ITEM_ID" ;;
  }
  dimension: status_item {
    type: string
    sql: ${TABLE}."STATUS_ITEM" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }
  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: type_item {
    type: string
    sql: ${TABLE}."TYPE_ITEM" ;;
  }
  measure: count {
    type: count
  }
}
