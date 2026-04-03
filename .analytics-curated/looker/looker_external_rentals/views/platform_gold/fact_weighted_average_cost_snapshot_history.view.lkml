view: fact_weighted_average_cost_snapshot_history {
  sql_table_name: "PLATFORM"."GOLD"."V_WEIGHTED_AVERAGE_COST_SNAPSHOT_HISTORY" ;;

  dimension: wac_snapshot_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_KEY" ;;
    hidden: yes
  }

  dimension: wac_snapshot_source {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_SOURCE" ;;
  }

  dimension: wac_snapshot_calculation_type {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_CALCULATION_TYPE" ;;
  }

  dimension: wac_snapshot_id {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_ID" ;;
    value_format_name: id
  }

  dimension: wac_snapshot_transaction_id {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_TRANSACTION_ID" ;;
    value_format_name: id
  }

  dimension: wac_snapshot_inventory_location_key {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_INVENTORY_LOCATION_KEY" ;;
    hidden: yes
  }

  dimension: wac_snapshot_part_key {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_PART_KEY" ;;
    description: "FK to dim_parts"
  }

  dimension: wac_snapshot_start_date_key {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_START_DATE_KEY" ;;
    hidden: yes
  }

  dimension: wac_snapshot_end_date_key {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_END_DATE_KEY" ;;
    hidden: yes
  }

  measure: wac_snapshot_incoming_quantity {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_INCOMING_QUANTITY" ;;
    value_format_name: decimal_2
  }

  measure: wac_snapshot_new_quantity {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_NEW_QUANTITY" ;;
    value_format_name: decimal_2
  }

  measure: wac_snapshot_weighted_average_cost {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_WEIGHTED_AVERAGE_COST" ;;
    value_format_name: usd
  }

  dimension: wac_snapshot_recordtimestamp {
    type: string
    sql: ${TABLE}."WAC_SNAPSHOT_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
