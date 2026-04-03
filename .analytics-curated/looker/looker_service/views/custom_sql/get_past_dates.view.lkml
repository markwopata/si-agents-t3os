view: get_past_dates {
  derived_table: {
    sql: select
        dateadd(day, '-' || row_number() over (order by null),
        dateadd(day, '+1', current_timestamp())) as generateddate
    from table (generator(rowcount => 10000)) ;;
  }

  dimension_group: generateddate {
    type: time
    timeframes: [raw,date,time,week,day_of_week,month,quarter,year]
    sql: ${TABLE}."GENERATEDDATE" ;;
  }

  }
