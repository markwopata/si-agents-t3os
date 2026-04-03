view: billing_types {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."BILLING_TYPES"
    ;;
  drill_fields: [billing_type_id]

  dimension: billing_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
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

  dimension: name {
    label: "Billing Type"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [billing_type_id, name, work_orders.count]
  }
}
