view: get_past_dates_filter {
  derived_table: {
    sql:
    with dates as (
      select dateadd(day, '-' || row_number() over (order by null),
        dateadd(day, '+1', current_date())) as generateddate
      from table (generator(rowcount => 10000))
      )
  select * from dates where generateddate >= dateadd(month, -48, date_trunc(month, current_date()))
    ;;
  }

  dimension_group: generateddate {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}."GENERATEDDATE" ;;
  }

  measure: day_count {
    type: count_distinct
    sql: ${TABLE}."GENERATEDDATE" ;;
  }

  # parameter: start_date {
  #   type: date
  #   default_value: "2010-01-01"
  # }

  # parameter: end_date {
  #   type: date
  #   default_value: "2099-01-01"
  # }

}
