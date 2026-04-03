view: entities {
  sql_table_name: "ES_WAREHOUSE"."PURCHASES"."ENTITIES" ;;
  #drill_fields: [entity_id]

  dimension: entity_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ENTITY_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: business_address_id {
    type: number
    sql: ${TABLE}."BUSINESS_ADDRESS_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension: ein {
    type: number
    sql: ${TABLE}."EIN" ;;
  }
  dimension: entity_type_id {
    type: number
    sql: ${TABLE}."ENTITY_TYPE_ID" ;;
  }
  dimension: is_customer {
    type: yesno
    sql: ${TABLE}."IS_CUSTOMER" ;;
  }
  dimension: is_vendor {
    type: yesno
    sql: ${TABLE}."IS_VENDOR" ;;
  }
  dimension_group: modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MODIFIED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: t3_migration_company_id {
    type: number
    sql: ${TABLE}."T3_MIGRATION_COMPANY_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [entity_id, name]
  }
}
