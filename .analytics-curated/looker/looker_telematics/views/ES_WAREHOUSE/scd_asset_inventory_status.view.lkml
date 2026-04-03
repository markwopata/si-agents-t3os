view: scd_asset_inventory_status {
  sql_table_name: (SELECT * FROM "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS" WHERE current_flag = 1)
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: current_flag {
    type: number
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }

  dimension_group: date_end {
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_start {
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
