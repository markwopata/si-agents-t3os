view: intacct_sandbox__departments {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__DEPARTMENTS" ;;

  dimension_group: date_no_longer_new_market {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_NO_LONGER_NEW_MARKET" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_deliver_to_contact_id {
    type: number
    sql: ${TABLE}."FK_DELIVER_TO_CONTACT_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_parent_department_id {
    type: number
    sql: ${TABLE}."FK_PARENT_DEPARTMENT_ID" ;;
  }
  dimension: fk_supervisor_user_id {
    type: number
    sql: ${TABLE}."FK_SUPERVISOR_USER_ID" ;;
  }
  dimension: fk_ultimate_parent_location_id {
    type: string
    sql: ${TABLE}."FK_ULTIMATE_PARENT_LOCATION_ID" ;;
  }
  dimension: id_department {
    type: number
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }
  dimension: is_block_costcapture_pos {
    type: yesno
    sql: ${TABLE}."IS_BLOCK_COSTCAPTURE_POS" ;;
  }
  dimension: is_block_new_purchasing_transactions {
    type: yesno
    sql: ${TABLE}."IS_BLOCK_NEW_PURCHASING_TRANSACTIONS" ;;
  }
  dimension: name_customer_title {
    type: string
    sql: ${TABLE}."NAME_CUSTOMER_TITLE" ;;
  }
  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_full {
    type: string
    sql: ${TABLE}."NAME_FULL" ;;
  }
  dimension: name_parent_department {
    type: string
    sql: ${TABLE}."NAME_PARENT_DEPARTMENT" ;;
  }
  dimension: name_sga_segment {
    type: string
    sql: ${TABLE}."NAME_SGA_SEGMENT" ;;
  }
  dimension: name_state {
    type: string
    sql: ${TABLE}."NAME_STATE" ;;
  }
  dimension: pk_department_id {
    type: number
    sql: ${TABLE}."PK_DEPARTMENT_ID" ;;
  }
  dimension: status_department {
    type: string
    sql: ${TABLE}."STATUS_DEPARTMENT" ;;
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
  dimension: type_build_to_suit {
    type: string
    sql: ${TABLE}."TYPE_BUILD_TO_SUIT" ;;
  }
  dimension: type_department {
    type: string
    sql: ${TABLE}."TYPE_DEPARTMENT" ;;
  }
  measure: count {
    type: count
  }
}
