view: providers {
  sql_table_name: "INVENTORY"."PROVIDERS" ;;
  drill_fields: [provider_id]

  dimension: provider_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: name {
    label: "Proivder"
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: sku_field {
    type: string
    sql: ${TABLE}."SKU_FIELD" ;;
  }
  dimension: verified {
    type: yesno
    sql: ${TABLE}."VERIFIED" ;;
  }
  dimension: verified_for_company {
    type: yesno
    sql: ${TABLE}."VERIFIED_FOR_COMPANY" ;;
  }
  dimension: verified_globally {
    type: yesno
    sql: ${TABLE}."VERIFIED_GLOBALLY" ;;
  }
  measure: count {
    type: count
    drill_fields: [provider_id, name, parts.count]
  }
}
