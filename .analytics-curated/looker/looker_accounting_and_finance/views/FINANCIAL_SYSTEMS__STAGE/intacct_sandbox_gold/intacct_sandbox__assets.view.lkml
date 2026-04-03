view: intacct_sandbox__assets {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__ASSETS" ;;

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: fk_asset_category_id {
    type: number
    sql: ${TABLE}."FK_ASSET_CATEGORY_ID" ;;
  }
  dimension: fk_asset_type_id {
    type: number
    sql: ${TABLE}."FK_ASSET_TYPE_ID" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: name_asset {
    type: string
    sql: ${TABLE}."NAME_ASSET" ;;
  }
  dimension: name_company {
    type: string
    sql: ${TABLE}."NAME_COMPANY" ;;
  }
  dimension: name_custom {
    type: string
    sql: ${TABLE}."NAME_CUSTOM" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_make {
    type: string
    sql: ${TABLE}."NAME_MAKE" ;;
  }
  dimension: name_model {
    type: string
    sql: ${TABLE}."NAME_MODEL" ;;
  }
  dimension: pk_asset_id {
    type: number
    sql: ${TABLE}."PK_ASSET_ID" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }
  dimension_group: timestamp_created_fleettrack {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED_FLEETTRACK" ;;
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
  dimension_group: timestamp_modified_fleettrack {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED_FLEETTRACK" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension: year_model {
    type: string
    sql: ${TABLE}."YEAR_MODEL" ;;
  }
  measure: count {
    type: count
  }
}
