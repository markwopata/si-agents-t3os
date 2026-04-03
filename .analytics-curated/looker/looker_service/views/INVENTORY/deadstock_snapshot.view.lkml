view: deadstock_snapshot {
  sql_table_name: "PARTS_INVENTORY"."DEADSTOCK_SNAPSHOT" ;;

  dimension: avg_cost {
    type: number
    sql: ${TABLE}."AVG_COST" ;;
  }
  dimension: bin_location {
    type: string
    sql: ${TABLE}."BIN_LOCATION" ;;
  }
  dimension: dead_stock {
    type: number
    sql: ${TABLE}."DEAD_STOCK" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: inv_dollars {
    type: number
    sql: ${TABLE}."INV_DOLLARS" ;;
  }
  dimension: inv_health {
    type: string
    sql: ${TABLE}."INV_HEALTH" ;;
  }
  dimension: inventory_location_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }
  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }
  dimension_group: og_last_consumed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OG_LAST_CONSUMED" ;;
  }
  dimension_group: overall_last_consumed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OVERALL_LAST_CONSUMED" ;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }
  dimension_group: snapdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SNAP_DATE" ;;
  }
  dimension: sub_part_ids {
    type: string
    value_format_name: id
    sql: ${TABLE}."SUB_PART_IDS" ;;
  }
  dimension: sub_part_numbers {
    type: string
    sql: ${TABLE}."SUB_PART_NUMBERS" ;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: total_in_inventory {
    type: number
    sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_region_xwalk.region_name, market_name, location_name, market_region_xwalk.district_name]
  }
  measure: count_markets {
    label: "Number of Markets with Dead Parts"
    type: count_distinct
    sql: ${market_id}  ;;
  }
  measure: count_parts {
    label: "Number of Dead Parts"
    type: count_distinct
    sql: ${part_id} ;;
  }
  measure: total_deadstock {
    type: number
    sql: ${dead_stock} ;;
  }
  measure: sum_total_in_inventory {
    type: sum
    sql: ${total_in_inventory} ;;
  }
  measure: sum_inv_dollars {
    type: sum
    sql: ${inv_dollars} ;;
  }

}





view: deadstock_status_aggregate {
  derived_table: {
    sql:
      select snap_date, part_id, min(overall_last_consumed) as last_consumed, sum(total_in_inventory) as total_in_inventory, sum(inv_dollars) as inv_dollars, count(market_id) as count_markets
      from ${deadstock_snapshot.SQL_TABLE_NAME}
      group by 1,2;;
  }
  dimension_group: snapdate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SNAP_DATE" ;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension_group: last_consumed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_CONSUMED" ;;
  }
  dimension: total_in_inventory {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
  }
  dimension: inv_dollars {
    type: number
    value_format_name: usd
    sql: ${TABLE}."INV_DOLLARS" ;;
  }
  dimension: count_markets {
    label: "Number of markets with this PN in deadstock"
    type: number
    sql: ${TABLE}."COUNT_MARKETS" ;;
  }
}
