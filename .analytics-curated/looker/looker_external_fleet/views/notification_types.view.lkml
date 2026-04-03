view: notification_types {
  sql_table_name: "PUBLIC"."NOTIFICATION_TYPES"
    ;;
  drill_fields: [notification_type_id]

  dimension: notification_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."NOTIFICATION_TYPE_ID" ;;
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
    label: "Notification Type"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [notification_type_id, name, notification_delivery_logs.count]
  }
}
