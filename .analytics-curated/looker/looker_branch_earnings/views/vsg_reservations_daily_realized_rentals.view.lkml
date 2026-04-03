view: vsg_reservations_daily_realized_rentals {
  sql_table_name: "VEHICLE_SOLUTIONS"."VSG_RESERVATIONS_DAILY_REALIZED_RENTALS" ;;

  dimension_group: dbt_snapshot {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DBT_SNAPSHOT_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: list_of_statuses {
    type: string
    sql: ${TABLE}."LIST_OF_STATUSES" ;;
  }
  dimension_group: pick_up {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PICK_UP_DATE" ;;
    html:{{ rendered_value | date: "%b %d, %Y" }};;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: platform_id {
    type: string
    sql: ${TABLE}."PLATFORM_ID" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: rental_occurred {
    type: number
    sql: ${TABLE}."RENTAL_OCCURRED" ;;
  }
  dimension: reservation_id {
    type: number
    sql: ${TABLE}."RESERVATION_ID" ;;
  }

  dimension: total_daily_realized_rentals
  {
    type: number
    sql: ${TABLE}."TOTAL_DAILY_REALIZED_RENTALS" ;;

  }
  measure: count {
    type: count
    drill_fields: [region_name]
  }
}
