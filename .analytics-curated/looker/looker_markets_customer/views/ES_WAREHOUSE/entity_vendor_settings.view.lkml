
view: entity_vendor_settings {
  sql_table_name: es_warehouse.purchases.entity_vendor_settings ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity_vendor_settings_id {
    type: string
    sql: ${TABLE}."ENTITY_VENDOR_SETTINGS_ID" ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }

  dimension: ap_address_id {
    type: string
    sql: ${TABLE}."AP_ADDRESS_ID" ;;
  }

  dimension: external_erp_vendor_ref {
    type: string
    sql: ${TABLE}."EXTERNAL_ERP_VENDOR_REF" ;;
  }

  dimension: entity_net_terms_id {
    type: string
    sql: ${TABLE}."ENTITY_NET_TERMS_ID" ;;
  }

  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: w9_on_file {
    type: string
    sql: ${TABLE}."W9_ON_FILE" ;;
  }

  dimension: entity_tax_classification_id {
    type: string
    sql: ${TABLE}."ENTITY_TAX_CLASSIFICATION_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        entity_vendor_settings_id,
  entity_id,
  ap_address_id,
  external_erp_vendor_ref,
  entity_net_terms_id,
  credit_limit,
  notes,
  w9_on_file,
  entity_tax_classification_id,
  _es_update_timestamp_time
    ]
  }
}
