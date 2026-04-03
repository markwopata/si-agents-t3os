view: vsg_reservations_daily_utilization {
  sql_table_name: "VEHICLE_SOLUTIONS"."VSG_RESERVATIONS_DAILY_UTILIZATION" ;;

  dimension_group: as_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }
  dimension_group: collected {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COLLECTED_AT" ;;
  }
  dimension: on_rent_reservations {
    type: number
    sql: ${TABLE}."ON_RENT_RESERVATIONS" ;;
  }
  dimension: on_rent_utilization {
    type: number
    sql: ${TABLE}."ON_RENT_UTILIZATION";;
    value_format: "0\%"

  }
  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }
  dimension: day {
    type: number
    sql: ${TABLE}."DAY" ;;
  }
  dimension: region_name {
    type: string
      sql: ${TABLE}."REGION_NAME";;

  }

  dimension: is_month_to_date {
    type: yesno
    sql: ${TABLE}."IS_MONTH_TO_DATE" ;;
  }
  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }
  dimension: is_current_year {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_YEAR" ;;
  }
  dimension: region_on_rent_utilization {
    type: number
    sql: ${TABLE}."REGION_ON_RENT_UTILIZATION";;
    value_format: "0\%"

  }
  dimension: total_vins {
    type: number
    sql: ${TABLE}."TOTAL_VINS" ;;
  }
  measure: count {
    type: count
    drill_fields: [on_rent_reservations, on_rent_utilization, total_vins, region_name, region_on_rent_utilization]
  }
}
