view: work_order_originators {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_ORIGINATORS" ;;
  drill_fields: [work_order_originator_id]

  dimension: work_order_originator_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: originator_item_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_ITEM_UUID" ;;
  }
  dimension: originator_type_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_TYPE_ID" ;;
  }
  dimension: originator_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_UUID" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [work_order_originator_id]
  }
  dimension: service_interval_type {
    type:  string
    sql: Case when ${originator_type_id}=3 and upper(work_orders.description) like '%ANSI%' then 'ANSI'
    when ${originator_type_id}=3 and (upper(work_orders.description) like '%DOT %' or upper(work_orders.description) like '%90 DAY%') then 'DOT'
    when ${originator_type_id}=3 and upper(work_orders.description) like '%ANNUAL%' then 'Annual'
    when ${originator_type_id}=3 then 'PM'
    else null
    end;;
  }
}
