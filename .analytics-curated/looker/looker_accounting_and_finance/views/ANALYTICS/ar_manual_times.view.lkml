view: ar_manual_times {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_MANUAL_TIMES" ;;

  ########## DIMENSIONS ##########

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension:key {
    type: string
    primary_key: yes
    sql: ${user_id} || '-' || ${date}::date || '-' || ${activity} ;;
  }

dimension: join_key {
  type: string
  sql: ${user_id} || '-' || ${date}::date ;;
}

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: activity {
    type: string
    sql: ${TABLE}."ACTIVITY" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE"::date ;;
  }



  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: week_day {
    type: string
    sql: ${TABLE}."WEEK_DAY" ;;
  }

########## MEASURES ##########

  measure: hours {
    value_format_name: decimal_2
    type: sum
    sql: ${TABLE}."HOURS" ;;
  }






}
