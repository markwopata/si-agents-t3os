
view: parts {
  sql_table_name:es_warehouse.inventory.parts ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_type_id {
    type: string
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension: provider_part_number_id {
    type: string
    sql: ${TABLE}."PROVIDER_PART_NUMBER_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension: duplicate_of_id {
    type: string
    sql: ${TABLE}."DUPLICATE_OF_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: provider_id {
    type: string
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension: verified {
    type: yesno
    sql: ${TABLE}."VERIFIED" ;;
  }

  dimension: sku_field {
    type: string
    sql: ${TABLE}."SKU_FIELD" ;;
  }

  dimension: verified_for_company {
    type: yesno
    sql: ${TABLE}."VERIFIED_FOR_COMPANY" ;;
  }

  dimension: verified_globally {
    type: yesno
    sql: ${TABLE}."VERIFIED_GLOBALLY" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: upc {
    type: string
    sql: ${TABLE}."UPC" ;;
  }

  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
    value_format_name: usd_0
  }

  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: is_global {
    type: yesno
    sql: ${TABLE}."IS_GLOBAL" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: product_type_id {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: manufacturer_id {
    type: string
    sql: ${TABLE}."MANUFACTURER_ID" ;;
  }

  dimension: manufacturer_number {
    type: string
    sql: ${TABLE}."MANUFACTURER_NUMBER" ;;
  }

  dimension: manufacturer_family_id {
    type: string
    sql: ${TABLE}."MANUFACTURER_FAMILY_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: product_category_id {
    type: string
    sql: ${TABLE}."PRODUCT_CATEGORY_ID" ;;
  }

  dimension: product_class_id {
    type: string
    sql: ${TABLE}."PRODUCT_CLASS_ID" ;;
  }

  dimension: conversion_unit_id {
    type: string
    sql: ${TABLE}."CONVERSION_UNIT_ID" ;;
  }

  dimension:  part_number_pos {
    type: string
    sql:  CASE WHEN ${items.item_type} = 'INVENTORY' THEN ${part_number}
            ELSE 'Non-Inventory Item' END  ;;
  }

  set: detail {
    fields: [
        _es_update_timestamp_time,
  date_created_time,
  date_updated_time,
  part_id,
  part_type_id,
  provider_part_number_id,
  company_id,
  date_archived_time,
  duplicate_of_id,
  part_number,
  provider_id,
  verified,
  sku_field,
  verified_for_company,
  verified_globally,
  item_id,
  upc,
  msrp,
  search,
  is_global,
  year,
  product_type_id,
  name,
  manufacturer_id,
  manufacturer_number,
  manufacturer_family_id,
  model,
  product_category_id,
  product_class_id,
  conversion_unit_id
    ]
  }
}
