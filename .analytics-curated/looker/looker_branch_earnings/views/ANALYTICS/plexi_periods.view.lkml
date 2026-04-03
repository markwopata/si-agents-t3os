view: plexi_periods {
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
    primary_key: yes
    sql: 250-${TABLE}."_ROW" ;;
  }

  dimension: display {
    type: string
    label: "Period"
    sql: ${TABLE}."DISPLAY";;
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

  dimension: inverse_date {
    description: "Inverse month count to order the period drop down desc"
    type: number
    hidden: yes
    sql: datediff(months, '1900-01-01'::date, ${TABLE}."TRUNC") * -1 ;;
  }

  dimension: period_for_suggest {
    description: "Period list to suggest. Don't suggest periods that are in the future"
    type: string
    hidden: yes
    sql: case when ${date} <= last_day(current_date()) then ${TABLE}."DISPLAY" else null end ;;
    order_by_field: inverse_date
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
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
