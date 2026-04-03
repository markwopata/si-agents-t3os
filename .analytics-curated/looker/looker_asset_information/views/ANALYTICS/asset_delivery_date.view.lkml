view: asset_delivery_date {
  sql_table_name: "PARTS_INVENTORY"."ASSET_DELIVERY_DATE" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: delivery {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELIVERY_DATE" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
