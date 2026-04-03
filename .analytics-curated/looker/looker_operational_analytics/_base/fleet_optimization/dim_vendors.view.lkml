view: dim_vendors {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_VENDORS" ;;

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }
  dimension: vendor_company_key {
    type: string
    sql: ${TABLE}."VENDOR_COMPANY_KEY" ;;
  }
  dimension_group: vendor_created_date_in_sage {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VENDOR_CREATED_DATE_IN_SAGE" ;;
  }
  dimension: vendor_data_source {
    type: string
    sql: ${TABLE}."VENDOR_DATA_SOURCE" ;;
  }
  dimension: vendor_dba_names {
    type: string
    sql: ${TABLE}."VENDOR_DBA_NAMES" ;;
  }
  dimension: vendor_intacct_user_creating_record {
    type: string
    sql: ${TABLE}."VENDOR_INTACCT_USER_CREATING_RECORD" ;;
  }
  dimension: vendor_intacct_user_updating_record {
    type: string
    sql: ${TABLE}."VENDOR_INTACCT_USER_UPDATING_RECORD" ;;
  }
  dimension: vendor_is_active_in_intacct {
    type: yesno
    sql: ${TABLE}."VENDOR_IS_ACTIVE_IN_INTACCT" ;;
  }
  dimension: vendor_is_not_coded_as_vendor {
    type: yesno
    sql: ${TABLE}."VENDOR_IS_NOT_CODED_AS_VENDOR" ;;
  }
  dimension: vendor_is_related_party {
    type: yesno
    sql: ${TABLE}."VENDOR_IS_RELATED_PARTY" ;;
  }
  dimension: vendor_key {
    type: number
    sql: ${TABLE}."VENDOR_KEY" ;;
  }
  dimension: vendor_legal_name {
    type: string
    sql: ${TABLE}."VENDOR_LEGAL_NAME" ;;
  }
  dimension_group: vendor_most_recent_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VENDOR_MOST_RECENT_PAYMENT_DATE" ;;
  }
  dimension: vendor_non_dba_name {
    type: string
    sql: ${TABLE}."VENDOR_NON_DBA_NAME" ;;
  }
  dimension: vendor_original_name {
    type: string
    sql: ${TABLE}."VENDOR_ORIGINAL_NAME" ;;
  }
  dimension: vendor_parent_name {
    type: string
    sql: ${TABLE}."VENDOR_PARENT_NAME" ;;
  }
  dimension: vendor_payment_term {
    type: string
    sql: ${TABLE}."VENDOR_PAYMENT_TERM" ;;
  }
  dimension_group: vendor_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."VENDOR_RECORDTIMESTAMP" ;;
  }
  dimension: vendor_sage_id {
    type: string
    sql: ${TABLE}."VENDOR_SAGE_ID" ;;
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}."VENDOR_TYPE" ;;
  }
  dimension_group: vendor_updated_date_in_sage {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VENDOR_UPDATED_DATE_IN_SAGE" ;;
  }
  measure: count {
    type: count
    drill_fields: [vendor_legal_name, vendor_non_dba_name, vendor_original_name, vendor_parent_name]
  }
}
