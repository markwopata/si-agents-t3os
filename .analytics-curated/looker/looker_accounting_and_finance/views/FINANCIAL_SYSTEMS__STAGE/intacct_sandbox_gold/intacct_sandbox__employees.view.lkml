view: intacct_sandbox__employees {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__EMPLOYEES" ;;

  dimension_group: date_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_END" ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_START" ;;
  }
  dimension: fk_contact_id {
    type: number
    sql: ${TABLE}."FK_CONTACT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_department_id {
    type: number
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
  }
  dimension: fk_employee_id {
    type: number
    sql: ${TABLE}."FK_EMPLOYEE_ID" ;;
  }
  dimension: fk_entity_id {
    type: number
    sql: ${TABLE}."FK_ENTITY_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: string
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_parent_id {
    type: number
    sql: ${TABLE}."FK_PARENT_ID" ;;
  }
  dimension: fk_payment_method_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_METHOD_ID" ;;
  }
  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }
  dimension: is_ach_enabled {
    type: yesno
    sql: ${TABLE}."IS_ACH_ENABLED" ;;
  }
  dimension: is_generic {
    type: yesno
    sql: ${TABLE}."IS_GENERIC" ;;
  }
  dimension: is_merge_payment_request {
    type: yesno
    sql: ${TABLE}."IS_MERGE_PAYMENT_REQUEST" ;;
  }
  dimension: is_payment_notify {
    type: yesno
    sql: ${TABLE}."IS_PAYMENT_NOTIFY" ;;
  }
  dimension: is_post_actual_cost {
    type: yesno
    sql: ${TABLE}."IS_POST_ACTUAL_COST" ;;
  }
  dimension: name_contact {
    type: string
    sql: ${TABLE}."NAME_CONTACT" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_first {
    type: string
    sql: ${TABLE}."NAME_FIRST" ;;
  }
  dimension: name_last {
    type: string
    sql: ${TABLE}."NAME_LAST" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: name_title {
    type: string
    sql: ${TABLE}."NAME_TITLE" ;;
  }
  dimension: pk_employee_id {
    type: number
    sql: ${TABLE}."PK_EMPLOYEE_ID" ;;
  }
  dimension: status_employee {
    type: string
    sql: ${TABLE}."STATUS_EMPLOYEE" ;;
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
  dimension: type_ach_account {
    type: string
    sql: ${TABLE}."TYPE_ACH_ACCOUNT" ;;
  }
  dimension: type_ach_remittance {
    type: string
    sql: ${TABLE}."TYPE_ACH_REMITTANCE" ;;
  }
  dimension: type_employee {
    type: string
    sql: ${TABLE}."TYPE_EMPLOYEE" ;;
  }
  dimension: type_termination {
    type: string
    sql: ${TABLE}."TYPE_TERMINATION" ;;
  }
  measure: count {
    type: count
  }
}
