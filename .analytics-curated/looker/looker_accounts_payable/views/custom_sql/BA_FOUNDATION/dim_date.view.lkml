view: dim_date {
  sql_table_name: platform.gold.v_dates ;;

  dimension: pk_date {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."DATE_KEY" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}."DATE" ;;
    convert_tz: no
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }
}
