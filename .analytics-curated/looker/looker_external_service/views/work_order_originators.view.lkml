view: work_order_originators {
  sql_table_name: "WORK_ORDERS"."WORK_ORDER_ORIGINATORS"
    ;;
  drill_fields: [work_order_originator_id]

  dimension: work_order_originator_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
    value_format_name: id
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

  dimension: originator_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ID" ;;
  }

  dimension: originator_item_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ITEM_ID" ;;
  }

  dimension: originator_type_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_TYPE_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [work_order_originator_id]
  }
}
