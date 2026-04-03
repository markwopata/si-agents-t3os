view: src_intacct__vendor {
  sql_table_name: "INTACCT_MODELS"."SRC_INTACCT__VENDOR" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_legal_name {
    type: string
    sql: ${TABLE}."COMPANY_LEGAL_NAME" ;;
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
  dimension_group: dds_read_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDS_READ_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_terms_id {
    type: number
    sql: ${TABLE}."FK_TERMS_ID" ;;
  }
  dimension: fk_updated_by_user_id {
    type: number
    sql: ${TABLE}."FK_UPDATED_BY_USER_ID" ;;
  }
  dimension: pk_vendor_id {
    type: number
    sql: ${TABLE}."PK_VENDOR_ID" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: terms_name {
    type: string
    sql: ${TABLE}."TERMS_NAME" ;;
  }
  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }
  measure: count {
    type: count
    drill_fields: [terms_name, company_legal_name, vendor_name]
  }
}
