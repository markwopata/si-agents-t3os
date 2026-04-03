
view: entities {
  sql_table_name:es_warehouse.purchases.entities;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: ein {
    type: string
    sql: ${TABLE}."EIN" ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: entity_type_id {
    type: string
    sql: ${TABLE}."ENTITY_TYPE_ID" ;;
  }

  dimension: is_vendor {
    type: yesno
    sql: ${TABLE}."IS_VENDOR" ;;
  }

  dimension: is_customer {
    type: yesno
    sql: ${TABLE}."IS_CUSTOMER" ;;
  }

  dimension: business_address_id {
    type: string
    sql: ${TABLE}."BUSINESS_ADDRESS_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: t3_migration_company_id {
    type: string
    sql: ${TABLE}."T3_MIGRATION_COMPANY_ID" ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: modified_at {
    type: time
    sql: ${TABLE}."MODIFIED_AT" ;;
  }

  dimension: modified_by_id {
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  set: detail {
    fields: [
        entity_id,
  name,
  company_id,
  ein,
  active,
  entity_type_id,
  is_vendor,
  is_customer,
  business_address_id,
  _es_update_timestamp_time,
  t3_migration_company_id,
  created_by_id,
  modified_at_time,
  modified_by_id,
  created_at_time
    ]
  }
}
