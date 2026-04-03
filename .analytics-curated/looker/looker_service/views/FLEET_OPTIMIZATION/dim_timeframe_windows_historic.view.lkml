view: dim_timeframe_windows_historic {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_TIMEFRAME_WINDOWS_HISTORIC";;

  dimension: days_in_period {
    type: number
    sql: ${TABLE}."DAYS_IN_PERIOD" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension_group: run {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RUN_DATE" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: tf_key {
    type: string
    primary_key: yes
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }
  measure: count {
    type: count
  }
}
