view: intacct_sandbox__locations {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__LOCATIONS" ;;

  dimension: business_days {
    type: string
    sql: ${TABLE}."BUSINESS_DAYS" ;;
  }
  dimension: fk_contact_id {
    type: number
    sql: ${TABLE}."FK_CONTACT_ID" ;;
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
  dimension: fk_parent_location_id {
    type: number
    sql: ${TABLE}."FK_PARENT_LOCATION_ID" ;;
  }
  dimension: fk_ship_to_contact_id {
    type: number
    sql: ${TABLE}."FK_SHIP_TO_CONTACT_ID" ;;
  }
  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }
  dimension: id_location_type {
    type: string
    sql: ${TABLE}."ID_LOCATION_TYPE" ;;
  }
  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }
  dimension: id_tax_alt {
    type: string
    sql: ${TABLE}."ID_TAX_ALT" ;;
  }
  dimension: is_ie_relation {
    type: yesno
    sql: ${TABLE}."IS_IE_RELATION" ;;
  }
  dimension: is_root_location {
    type: yesno
    sql: ${TABLE}."IS_ROOT_LOCATION" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }
  dimension: name_parent_location {
    type: string
    sql: ${TABLE}."NAME_PARENT_LOCATION" ;;
  }
  dimension: name_print_as {
    type: string
    sql: ${TABLE}."NAME_PRINT_AS" ;;
  }
  dimension: num_first_month {
    type: number
    sql: ${TABLE}."NUM_FIRST_MONTH" ;;
  }
  dimension: num_first_month_tax {
    type: number
    sql: ${TABLE}."NUM_FIRST_MONTH_TAX" ;;
  }
  dimension: pk_location_id {
    type: number
    sql: ${TABLE}."PK_LOCATION_ID" ;;
  }
  dimension: status_location {
    type: string
    sql: ${TABLE}."STATUS_LOCATION" ;;
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
  measure: count {
    type: count
  }
}
