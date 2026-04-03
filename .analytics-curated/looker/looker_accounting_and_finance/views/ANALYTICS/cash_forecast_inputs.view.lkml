view: cash_forecast_inputs {
  sql_table_name: "ANALYTICS"."TREASURY"."CASH_FORECAST_INPUTS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }



  dimension: item {
    type: string
    sql: ${TABLE}."ITEM" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }


  measure: amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }


}
