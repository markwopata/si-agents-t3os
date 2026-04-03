view: fact_store_part_inventory_levels {
  sql_table_name: "PLATFORM"."GOLD"."V_STORE_PART_INVENTORY_LEVELS" ;;

  dimension: store_part_inventory_levels_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_KEY" ;;
    hidden: yes
  }

  dimension: store_part_inventory_levels_source {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_SOURCE" ;;
  }

  dimension: store_part_inventory_levels_id {
    type: number
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_ID" ;;
    value_format_name: id
  }

  dimension: store_part_inventory_levels_part_key {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_PART_KEY" ;;
    description: "FK to dim_parts"
  }

  dimension: store_part_inventory_levels_inventory_location_key {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_INVENTORY_LOCATION_KEY" ;;
    hidden: yes
  }

  dimension: store_part_inventory_levels_created_date_key {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_CREATED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: store_part_inventory_levels_archive_status {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_ARCHIVE_STATUS" ;;
  }

  measure: store_part_inventory_levels_available_quantity {
    type: number
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_AVAILABLE_QUANTITY" ;;
    value_format_name: decimal_2
  }

  measure: store_part_inventory_levels_quantity {
    type: number
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_QUANTITY" ;;
    value_format_name: decimal_2
  }

  dimension: store_part_inventory_levels_recordtimestamp {
    type: string
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
