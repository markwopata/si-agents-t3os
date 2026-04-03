view: store_parts {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."STORE_PARTS"
    ;;
  drill_fields: [store_part_id]

  dimension: store_part_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."STORE_PART_ID" ;;
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

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: max {
    type: number
    sql: ${TABLE}."MAX" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: available_quantity {
    type: number
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }

  dimension: on_rent_quantity {
    type: number
    sql: ${TABLE}."QUANTITY" - ${TABLE}."AVAILABLE_QUANTITY" ;;
  }

  dimension: search_vector {
    type: string
    sql: ${TABLE}."SEARCH_VECTOR" ;;
  }

  dimension: store_id {
    type: string
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: inventory_location_id {
    type: string
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension: threshold {
    type: number
    sql: ${TABLE}."THRESHOLD" ;;
  }

  measure: parts_quantity {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [store_part_id, providers.name, cost_by_provider.description, cost_by_provider.part_number, location, quantity, cost_by_provider.total_cost]
    # link: {
    #   label: "Explore Top 20 Results"
    #   url: "{{ link }}&limit=20"
    # }
  }

  measure: parts_quantity_no_drill {
    type: sum
    sql: ${quantity} ;;
  }

  measure: parts_available_quantity {
    type: sum
    sql: ${available_quantity} ;;
  }

  measure: parts_on_rent_quantity {
    type: sum
    sql: ${on_rent_quantity} ;;
  }

  measure: count {
    type: count
    drill_fields: [store_part_id]
  }

  dimension: below_threshold {
    type: number
    sql:  CASE WHEN (${quantity} <  ${threshold}) THEN 1 ELSE 0 END;;
  }
  measure: num_below_threshold {
    type: sum
    sql: ${below_threshold};;
    filters: [below_threshold: "1"]
    drill_fields: [stores.name, stores.store_id, stores.branch_id, parts.part_number, providers.name, cost_by_provider.description, quantity, threshold]
  }

  measure: max_sum {
    type: sum
    sql: ${max} ;;
  }

  measure: threshold_sum {
    type: sum
    sql: ${threshold} ;;
  }

  dimension: need_to_order {
    type: number
    sql: iff(coalesce(${max}, 0) < ${threshold}, ${threshold} - ${quantity}, ${max} - ${quantity}) ;;
  }

  measure: need_to_order_sum {
    type: sum
    sql: ${need_to_order} ;;
  }
}
