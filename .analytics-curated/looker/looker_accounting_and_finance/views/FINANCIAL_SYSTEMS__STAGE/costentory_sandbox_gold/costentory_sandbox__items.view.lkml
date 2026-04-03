view: costentory_sandbox__items {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__ITEMS" ;;

  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }
  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_duplicate_of_item_id {
    type: string
    sql: ${TABLE}."FK_DUPLICATE_OF_ITEM_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_part_id {
    type: number
    sql: ${TABLE}."FK_PART_ID" ;;
  }
  dimension: fk_part_type_id {
    type: number
    sql: ${TABLE}."FK_PART_TYPE_ID" ;;
  }
  dimension: fk_preferred_vendor_id {
    type: number
    sql: ${TABLE}."FK_PREFERRED_VENDOR_ID" ;;
  }
  dimension: fk_provider_id {
    type: number
    sql: ${TABLE}."FK_PROVIDER_ID" ;;
  }
  dimension: is_buyable {
    type: yesno
    sql: ${TABLE}."IS_BUYABLE" ;;
  }
  dimension: is_duplicate {
    type: yesno
    sql: ${TABLE}."IS_DUPLICATE" ;;
  }
  dimension: is_sellable {
    type: yesno
    sql: ${TABLE}."IS_SELLABLE" ;;
  }
  dimension: manufacturer_number {
    type: string
    sql: ${TABLE}."MANUFACTURER_NUMBER" ;;
  }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
  }
  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }
  dimension: name_item_type {
    type: string
    sql: ${TABLE}."NAME_ITEM_TYPE" ;;
  }
  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }
  dimension: name_part {
    type: string
    sql: ${TABLE}."NAME_PART" ;;
  }
  dimension: name_part_type {
    type: string
    sql: ${TABLE}."NAME_PART_TYPE" ;;
  }
  dimension: name_provider {
    type: string
    sql: ${TABLE}."NAME_PROVIDER" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_number_current {
    type: string
    sql: ${TABLE}."PART_NUMBER_CURRENT" ;;
  }
  dimension: pk_item_id {
    type: string
    sql: ${TABLE}."PK_ITEM_ID" ;;
    primary_key: yes
  }
  dimension: sage_item_id {
    type: string
    sql: ${TABLE}."SAGE_ITEM_ID" ;;
  }
  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }
  dimension: sku_field {
    type: string
    sql: ${TABLE}."SKU_FIELD" ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
