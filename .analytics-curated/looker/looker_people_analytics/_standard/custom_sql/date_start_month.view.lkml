view: date_start_month {
  derived_table: {
    sql: select row_number() over (order by null)  ID,
          add_months('2023-12-01'::date, + id) AS DATE_RECORD
          from table(generator(rowcount => 60));;
  }
  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ID";;
  }

  dimension_group: date_record {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: cast(${TABLE}."DATE_RECORD" AS TIMESTAMP_NTZ) ;;

  }

}
