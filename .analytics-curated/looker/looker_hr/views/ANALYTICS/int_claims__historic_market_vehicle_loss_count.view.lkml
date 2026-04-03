view: int_claims__historic_market_vehicle_loss_count {
  sql_table_name: "CLAIMS"."INT_CLAIMS__HISTORIC_MARKET_VEHICLE_LOSS_COUNT" ;;

  dimension: date_month {
    type: date
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: ltm_loss_count {
    type: sum
    sql: ${TABLE}."LTM_LOSS_COUNT" ;;
  }
  measure: ltm_vehicle_count {
    type: sum
    sql: ${TABLE}."LTM_VEHICLE_COUNT" ;;
  }

  measure: monthly_loss_count {
    type: sum
    sql: ${TABLE}."MONTHLY_LOSS_COUNT" ;;
  }
  measure: monthly_vehicle_count {
    type: sum
    sql: ${TABLE}."MONTHLY_VEHICLE_COUNT" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
