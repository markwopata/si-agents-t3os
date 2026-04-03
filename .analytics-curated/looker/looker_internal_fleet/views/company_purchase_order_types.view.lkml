view: company_purchase_order_types {
  sql_table_name: "PUBLIC"."COMPANY_PURCHASE_ORDER_TYPES"
    ;;
  drill_fields: [company_purchase_order_type_id]

  dimension: company_purchase_order_type_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_TYPE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: help_text {
    type: string
    sql: ${TABLE}."HELP_TEXT" ;;
  }

  dimension: logo_url {
    type: string
    sql: ${TABLE}."LOGO_URL" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: prefix {
    type: string
    sql: ${TABLE}."PREFIX" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_purchase_order_type_id, name, company_purchase_orders.count]
  }
}
