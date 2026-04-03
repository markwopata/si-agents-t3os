view: order_salespersons {
  sql_table_name: "PUBLIC"."ORDER_SALESPERSONS"
    ;;
  drill_fields: [order_salesperson_id]

  dimension: order_salesperson_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORDER_SALESPERSON_ID" ;;
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

  dimension: commission {
    type: number
    sql: ${TABLE}."COMMISSION" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: salesperson_type_id {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [order_salesperson_id, orders.purchase_order_id]
  }
}
