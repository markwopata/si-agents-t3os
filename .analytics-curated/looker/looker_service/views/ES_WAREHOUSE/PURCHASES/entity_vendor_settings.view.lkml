view: entity_vendor_settings {
  sql_table_name: "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" ;;
  #drill_fields: [entity_vendor_settings_id]

  dimension: entity_vendor_settings_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ENTITY_VENDOR_SETTINGS_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: ap_address_id {
    type: number
    sql: ${TABLE}."AP_ADDRESS_ID" ;;
  }
  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }
  dimension: entity_id {
    type: number
    sql: ${TABLE}."ENTITY_ID" ;;
  }
  dimension: entity_net_terms_id {
    type: number
    sql: ${TABLE}."ENTITY_NET_TERMS_ID" ;;
  }
  dimension: entity_tax_classification_id {
    type: number
    sql: ${TABLE}."ENTITY_TAX_CLASSIFICATION_ID" ;;
  }
  dimension: external_erp_vendor_ref {
    type: string
    sql: ${TABLE}."EXTERNAL_ERP_VENDOR_REF" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: w9_on_file {
    type: string
    sql: ${TABLE}."W9_ON_FILE" ;;
  }
  measure: count {
    type: count
    drill_fields: [entity_vendor_settings_id]
  }
}
