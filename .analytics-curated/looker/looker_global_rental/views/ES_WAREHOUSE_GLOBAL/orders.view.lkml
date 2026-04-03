view: orders {
  sql_table_name: "PUBLIC"."ORDERS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
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

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: deleted {
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
    sql: CAST(${TABLE}."DELETED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: external_id {
    type: number
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: metadata {
    type: string
    sql: ${TABLE}."METADATA" ;;
  }

  dimension: branch_id {
    type:  number
    sql:  CAST(${metadata}:branch.id as NUMERIC) ;;
  }

  dimension: branch {
    type:  string
    sql:  CAST(${metadata}:branch.name as VARCHAR) ;;
  }

  dimension: purchase_order_reference {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_REFERENCE" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}."UUID" ;;
  }

  dimension: customer {
    type: string
    sql: CAST(${TABLE}."metadata:customer.name" AS VARCHAR) ;;
  }

  measure: count {
    type: count
    drill_fields: [id, invoices.count, line_items.count]
  }
}
