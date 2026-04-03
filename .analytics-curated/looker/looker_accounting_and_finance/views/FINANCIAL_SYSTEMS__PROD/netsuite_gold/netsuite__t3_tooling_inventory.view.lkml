view: netsuite__t3_tooling_inventory {
  sql_table_name: "NETSUITE_GOLD"."NETSUITE__T3_TOOLING_INVENTORY" ;;

  dimension: ns_item_id {
    type: string
    sql: ${TABLE}."NS_ITEM_ID" ;;
  }
  dimension: ns_item_internal_id {
    type: number
    sql: ${TABLE}."NS_ITEM_INTERNAL_ID" ;;
  }
  dimension: ns_manufacturer_name {
    type: string
    sql: ${TABLE}."NS_MANUFACTURER_NAME" ;;
  }
  dimension: ns_manufacturer_number {
    type: string
    sql: ${TABLE}."NS_MANUFACTURER_NUMBER" ;;
  }
  dimension: ns_part_name {
    type: string
    sql: ${TABLE}."NS_PART_NAME" ;;
  }
  dimension: t3_available_qty {
    type: number
    sql: ${TABLE}."T3_AVAILABLE_QTY" ;;
  }
  dimension: t3_manufacturer_name {
    type: string
    sql: ${TABLE}."T3_MANUFACTURER_NAME" ;;
  }
  dimension: t3_manufacturer_number {
    type: string
    sql: ${TABLE}."T3_MANUFACTURER_NUMBER" ;;
  }
  dimension: t3_part_id {
    type: string
    sql: ${TABLE}."T3_PART_ID" ;;
  }
  dimension: t3_part_name {
    type: string
    sql: ${TABLE}."T3_PART_NAME" ;;
  }
  dimension: t3_store_id {
    type: string
    sql: ${TABLE}."T3_STORE_ID" ;;
  }
  dimension: t3_store_name {
    type: string
    sql: ${TABLE}."T3_STORE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [t3_manufacturer_name, ns_part_name, t3_store_name, ns_manufacturer_name, t3_part_name]
  }
}
