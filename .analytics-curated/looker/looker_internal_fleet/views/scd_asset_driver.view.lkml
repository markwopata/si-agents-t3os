view: scd_asset_driver {
  sql_table_name: "SCD"."SCD_ASSET_DRIVER"
    ;;
  drill_fields: [scd_asset_driver_id]

  dimension: scd_asset_driver_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SCD_ASSET_DRIVER_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
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
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_start {
    label: "Changed"
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
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [scd_asset_driver_id, driver_name]
  }
}
