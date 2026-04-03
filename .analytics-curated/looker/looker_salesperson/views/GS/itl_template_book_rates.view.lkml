view: itl_template_book_rates {
  sql_table_name: "GS"."ITL_TEMPLATE_BOOK_RATES"
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

  dimension: day_book {
    type: string
    sql: ${TABLE}."DAY_BOOK" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: include_on_rate_achievement_dashboard {
    type: string
    sql: ${TABLE}."INCLUDE_ON_RATE_ACHIEVEMENT_DASHBOARD" ;;
  }

  dimension: month_book {
    type: number
    sql: ${TABLE}."MONTH_BOOK" ;;
  }

  dimension: week_book {
    type: string
    sql: ${TABLE}."WEEK_BOOK" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
