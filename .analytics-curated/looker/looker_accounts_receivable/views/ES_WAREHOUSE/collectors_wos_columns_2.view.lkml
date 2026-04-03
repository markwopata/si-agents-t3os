view: collectors_wos_columns_2 {
  sql_table_name: "GOOGLE_SHEETS"."COLLECTORS_WOS_COLUMNS"
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: paid {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PAID" ;;
  }


  dimension: write_off {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WRITE_OFF" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: total_outstanding {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_OUTSTANDING" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
