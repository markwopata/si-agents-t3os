view: dim_parts_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_PARTS_FLEET_OPT" ;;

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: part_archived {
    type: yesno
    sql: ${TABLE}."PART_ARCHIVED" ;;
  }
  dimension: part_category_id {
    type: number
    sql: ${TABLE}."PART_CATEGORY_ID" ;;
    value_format_name: id
  }
  dimension: part_category_name {
    type: string
    sql: ${TABLE}."PART_CATEGORY_NAME" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: part_internal_use {
    type: yesno
    sql: ${TABLE}."PART_INTERNAL_USE" ;;
  }
  dimension: part_is_global {
    type: yesno
    sql: ${TABLE}."PART_IS_GLOBAL" ;;
  }
  dimension: part_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."PART_KEY" ;;
  }
  dimension: part_level {
    type: number
    sql: ${TABLE}."PART_LEVEL" ;;
  }
  dimension: part_manufacturer_number {
    type: string
    sql: ${TABLE}."PART_MANUFACTURER_NUMBER" ;;
  }
  dimension: part_master_key {
    type: string
    sql: ${TABLE}."PART_MASTER_KEY" ;;
  }
  dimension: part_msrp {
    type: number
    sql: ${TABLE}."PART_MSRP" ;;
    value_format_name: usd
  }
  dimension: part_name {
    type: string
    sql: ${TABLE}."PART_NAME" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_provider_id {
    type: number
    sql: ${TABLE}."PART_PROVIDER_ID" ;;
    value_format_name: id
  }
  dimension: part_provider_name {
    type: string
    sql: ${TABLE}."PART_PROVIDER_NAME" ;;
  }
  dimension_group: part_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PART_RECORDTIMESTAMP" ;;
  }
  dimension: part_reporting_category {
    type: string
    sql: ${TABLE}."PART_REPORTING_CATEGORY" ;;
  }
  dimension: part_search {
    type: string
    sql: ${TABLE}."PART_SEARCH" ;;
  }
  dimension: part_sku_field {
    type: string
    sql: ${TABLE}."PART_SKU_FIELD" ;;
  }
  dimension: part_source {
    type: string
    sql: ${TABLE}."PART_SOURCE" ;;
  }
  dimension: part_type_description {
    type: string
    sql: ${TABLE}."PART_TYPE_DESCRIPTION" ;;
  }
  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: part_verified_for_company {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_FOR_COMPANY" ;;
  }
  dimension: part_verified_globally {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_GLOBALLY" ;;
  }
  measure: count {
    type: count
    drill_fields: [part_provider_name, part_name, part_category_name]
  }
}
