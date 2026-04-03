#this version of plexi_periods references up to this month
view: plexi_periods_to_date {
  sql_table_name: "ANALYTICS"."GS"."PLEXI_PERIODS"
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
    sql: 150-${TABLE}."_ROW" ;;
  }

  dimension: display {
    type: string
    label: "Period"
    sql: CASE WHEN ${TABLE}."TRUNC" <= current_date()::DATE
      THEN ${TABLE}."DISPLAY" END;;
    order_by_field: _row
  }

  dimension: month_num {
    type: number
    sql: ${TABLE}."MONTH_NUM" ;;
  }

  dimension: date {
    type: date
    convert_tz: no
    sql: ${TABLE}."TRUNC" ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${TABLE}."TRUNC", current_date) ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: period_published {
    type: string
    sql: ${TABLE}."PERIOD_PUBLISHED" ;;
    primary_key: yes
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
