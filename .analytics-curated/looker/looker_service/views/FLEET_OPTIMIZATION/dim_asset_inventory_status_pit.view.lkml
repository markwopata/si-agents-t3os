view: dim_asset_inventory_status_pit {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSET_INVENTORY_STATUS_PIT" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: asset_inventory_status_pit_key {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_PIT_KEY" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }
  dimension: dt_key {
    type: string
    sql: ${TABLE}."DT_KEY" ;;
  }
  dimension: hours_in_status_for_day {
    type: number
    sql: ${TABLE}."HOURS_IN_STATUS_FOR_DAY" ;;
  }
  dimension: inventory_status_breakdown {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS_BREAKDOWN" ;;
  }
  dimension: is_current_asset_inventory_status {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_ASSET_INVENTORY_STATUS" ;;
  }
  dimension: percent_of_time_in_status_for_day {
    type: number
    sql: ${TABLE}."PERCENT_OF_TIME_IN_STATUS_FOR_DAY" ;;
  }
  measure: count {
    type: count
  }
}
