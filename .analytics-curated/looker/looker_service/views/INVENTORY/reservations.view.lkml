view: reservations {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."RESERVATIONS" ;;
  drill_fields: [reservation_id]

  dimension: reservation_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RESERVATION_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension_group: date_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CANCELLED" ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_COMPLETED" ;;
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
  dimension: inventory_location_id {
    type: number
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: target_id {
    type: number
    sql: ${TABLE}."TARGET_ID" ;;
  }
  dimension: target_type_id {
    type: number
    sql: ${TABLE}."TARGET_TYPE_ID" ;;
  }
  dimension: target_type {
    type: string
    sql: case
          when ${target_type_id} = 1 then 'Work Order'
          when ${target_type_id} = 2 then 'Invoice'
          else null end;;
  }
  dimension: value {
    type: number
    sql: ${quantity} * ${weighted_average_cost_snapshots.weighted_average_cost} ;;
    value_format: "0.00"
  }
  measure: count {
    type: count
    drill_fields: [reservation_id]
  }
  measure: sum_quantity {
    type: sum
    sql: ${quantity} ;;
  }
  measure: value_in_work_orders {
    type: sum
    sql: ${value} ;;
    filters: [target_type_id: "1"]
  }
  measure: value_in_invoices {
    type: sum
    sql: ${value} ;;
    filters: [target_type_id: "2"]
  }
}
