view: delivery_statuses {
  sql_table_name: "PUBLIC"."DELIVERY_STATUSES"
    ;;
  drill_fields: [delivery_status_id]

  dimension: delivery_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DELIVERY_STATUS_ID" ;;
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
    label: "Delivery Status"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [delivery_status_id, name]
  }
}
