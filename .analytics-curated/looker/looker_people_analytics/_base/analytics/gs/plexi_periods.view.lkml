view: plexi_periods {
  sql_table_name: "ANALYTICS"."GS"."PLEXI_PERIODS" ;;

  dimension: _fivetran_synced {
    type: date_raw
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: display {
    type: string
    sql: ${TABLE}."DISPLAY" ;;
  }
  dimension: month_num {
    type: number
    sql: ${TABLE}."MONTH_NUM" ;;
  }
  dimension: period_published {
    type: string
    sql: ${TABLE}."PERIOD_PUBLISHED" ;;
  }
  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }
  dimension: trunc {
    type: string
    sql: ${TABLE}."TRUNC" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
}
