view: date_holder {
  sql_table_name: "GREENHOUSE"."DATE_HOLDER"
    ;;

  dimension: date {
    primary_key: yes
    type: string
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_2 {
    type: date_raw
    sql: TO_DATE(${TABLE}."DATE", 'mm/dd/yy') ;;
  }

  dimension_group: date_3 {
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
    sql: CAST(TO_DATE(${TABLE}."DATE", 'mm/dd/yy') AS TIMESTAMP_NTZ) ;;
  }


  measure: count {
    type: count
    drill_fields: []
  }
}
