view: fact_hourly_asset_usage {
  sql_table_name: "PLATFORM"."GOLD"."V_HOURLY_ASSET_USAGE" ;;

  dimension: hourly_asset_usage_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_KEY" ;;
    hidden: yes
  }

  dimension: hourly_asset_usage_source {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_SOURCE" ;;
  }

  dimension: hourly_asset_usage_id {
    type: number
    sql: ${TABLE}."HOURLY_ASSET_USAGE_ID" ;;
    value_format_name: id
  }

  dimension: hourly_asset_usage_effective_start_timestamp {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_EFFECTIVE_START_TIMESTAMP" ;;
    value_format_name: id
    hidden: yes
  }

  dimension: hourly_asset_usage_asset_key {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: hourly_asset_usage_start_range_date_key {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_START_RANGE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: hourly_asset_usage_start_range_time_key {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_START_RANGE_TIME_KEY" ;;
    hidden: yes
  }

  dimension: hourly_asset_usage_end_range_date_key {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_END_RANGE_DATE_KEY" ;;
    hidden: yes
  }

  dimension: hourly_asset_usage_end_range_time_key {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_END_RANGE_TIME_KEY" ;;
    hidden: yes
  }

  measure: hourly_asset_usage_on_time {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_ON_TIME" ;;
    value_format_name: decimal_0
    description: "Total seconds 'On' (Run Time - Idle Time)."
  }

  measure: hourly_asset_usage_run_time {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_RUN_TIME" ;;
    value_format_name: decimal_0
    description: "Seconds the equipment was in use according to the tracker."
  }

  measure: hourly_asset_usage_idle_time {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_IDLE_TIME" ;;
    value_format_name: decimal_0
    description: "Seconds the equipment was idling according to the tracker."
  }

  measure: hourly_asset_usage_miles_driven {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_MILES_DRIVEN" ;;
    value_format_name: decimal_2
    description: "Miles driven according to the tracker."
  }

  measure: hourly_asset_usage_hauled_time {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_HAULED_TIME" ;;
    value_format_name: decimal_0
  }

  measure: hourly_asset_usage_hauling_time {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_HAULING_TIME" ;;
    value_format_name: decimal_0
  }

  measure: hourly_asset_usage_hauling_distance {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_HAULING_DISTANCE" ;;
    value_format_name: decimal_2
  }

  measure: hourly_asset_usage_hauled_distance {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_HAULED_DISTANCE" ;;
    value_format_name: decimal_2
  }

  measure: hourly_asset_usage_total_speeding_incidents {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_TOTAL_SPEEDING_INCIDENTS" ;;
    value_format_name: decimal_0
  }

  measure: hourly_asset_usage_total_impact_incidents {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_TOTAL_IMPACT_INCIDENTS" ;;
    value_format_name: decimal_0
  }

  measure: hourly_asset_usage_total_idle_incidents {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_TOTAL_IDLE_INCIDENTS" ;;
    value_format_name: decimal_0
  }

  measure: hourly_asset_usage_total_aggressive_incidents {
    type: sum
    sql: ${TABLE}."HOURLY_ASSET_USAGE_TOTAL_AGGRESSIVE_INCIDENTS" ;;
    value_format_name: decimal_0
  }

  dimension: hourly_asset_usage_recordtimestamp {
    type: string
    sql: ${TABLE}."HOURLY_ASSET_USAGE_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [hourly_asset_usage_id, hourly_asset_usage_source]
  }
}
