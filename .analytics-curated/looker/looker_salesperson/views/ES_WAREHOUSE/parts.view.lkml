view: parts {
  sql_table_name: "INVENTORY"."PARTS" ;;
  drill_fields: [part_id]

  dimension: part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: conversion_unit_id {
    type: number
    sql: ${TABLE}."CONVERSION_UNIT_ID" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: duplicate_of_id {
    type: number
    sql: ${TABLE}."DUPLICATE_OF_ID" ;;
  }
  dimension: is_global {
    type: yesno
    sql: ${TABLE}."IS_GLOBAL" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: manufacturer_family_id {
    type: number
    sql: ${TABLE}."MANUFACTURER_FAMILY_ID" ;;
  }
  dimension: manufacturer_id {
    type: number
    sql: ${TABLE}."MANUFACTURER_ID" ;;
  }
  dimension: manufacturer_number {
    type: string
    sql: ${TABLE}."MANUFACTURER_NUMBER" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }
  dimension: product_category_id {
    type: number
    sql: ${TABLE}."PRODUCT_CATEGORY_ID" ;;
  }
  dimension: product_class_id {
    type: number
    sql: ${TABLE}."PRODUCT_CLASS_ID" ;;
  }
  dimension: product_type_id {
    type: number
    sql: ${TABLE}."PRODUCT_TYPE_ID" ;;
  }
  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }
  dimension: provider_part_number_id {
    type: number
    sql: ${TABLE}."PROVIDER_PART_NUMBER_ID" ;;
  }
  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }
  dimension: sku_field {
    type: string
    sql: ${TABLE}."SKU_FIELD" ;;
  }
  dimension: upc {
    type: string
    sql: ${TABLE}."UPC" ;;
  }
  dimension: verified {
    type: yesno
    sql: ${TABLE}."VERIFIED" ;;
  }
  dimension: verified_for_company {
    type: yesno
    sql: ${TABLE}."VERIFIED_FOR_COMPANY" ;;
  }
  dimension: verified_globally {
    type: yesno
    sql: ${TABLE}."VERIFIED_GLOBALLY" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [part_id, name]
  }
}
