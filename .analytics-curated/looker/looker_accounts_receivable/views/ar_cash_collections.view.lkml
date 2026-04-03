view: ar_cash_collections {
  sql_table_name: "AR"."AR_CASH_COLLECTIONS"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: ${TABLE}.CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: daily {
    type: number
    sql: ${TABLE}."DAILY" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: goal {
    type: number
    sql: ${TABLE}."GOAL" ;;
  }

  dimension: running_total {
    type: number
    sql: ${TABLE}."RUNNING_TOTAL" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
