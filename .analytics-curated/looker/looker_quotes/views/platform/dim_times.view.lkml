view: dim_times {
  sql_table_name: "PLATFORM"."GOLD"."V_TIMES" ;;

  dimension: time_12_hh_mm_ss_am_pm {
    type: string
    sql: ${TABLE}."TIME_12_HH_MM_SS_AM_PM" ;;
  }

  dimension: time_24_hh_mm_ss {
    type: string
    sql: ${TABLE}."TIME_24_HH_MM_SS" ;;
  }

  dimension: time_am_pm {
    type: string
    sql: ${TABLE}."TIME_AM_PM" ;;
  }

  dimension: time_hour {
    type: string
    sql: ${TABLE}."TIME_HOUR" ;;
  }

  dimension: time_key {
    type: string
    primary_key: yes
    hidden:  yes
    sql: ${TABLE}."TIME_KEY" ;;
  }

  dimension: time_minute {
    type: string
    sql: ${TABLE}."TIME_MINUTE" ;;
  }

  dimension_group: time_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."TIME_RECORDTIMESTAMP" ;;
  }

  dimension: time_second {
    type: string
    sql: ${TABLE}."TIME_SECOND" ;;
  }

}
