include: "/_base/analytics/gs/plexi_periods.view.lkml"

view: +plexi_periods {
  label: "Plexi Periods"

dimension_group: _fivetran_synced {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CAST(${_fivetran_synced} AS TIMESTAMP_NTZ) ;;
}

  dimension: _row {
    hidden:yes
  }
  dimension: row {
    type: number
    sql: 150-${_row} ;;
  }
  dimension: display {
    label: "Period"
    order_by_field: row
  }
  # dimension: month_num {
  #   type: number
  #   sql: ${TABLE}."MONTH_NUM" ;;
  # }
  dimension: months_open {
    type: number
    sql: datediff(months, ${trunc}, current_date) ;;
  }
  # dimension: period_published {
  #   type: string
  #   sql: ${TABLE}."PERIOD_PUBLISHED" ;;
  # }
  # dimension: quarter {
  #   type: string
  #   sql: ${TABLE}."QUARTER" ;;
  # }
  dimension: date {
    type: date
    sql: ${trunc}::date ;;
  }

  # dimension: year {
  #   type: number
  #   sql: ${TABLE}."YEAR" ;;
  # }
  # measure: count {
  #   type: count
  # }
}
