view: int_claims__historic_market_vehicle_claim_count {
  sql_table_name: "CLAIMS"."INT_CLAIMS__HISTORIC_MARKET_VEHICLE_CLAIM_COUNT" ;;

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

  measure: monthly_vehicle_count {
    type: sum
    sql: ${TABLE}."MONTHLY_VEHICLE_COUNT" ;;
  }

  measure: avg_vehicle_count_rolling_12_mo {
    type: sum
    sql: ${TABLE}."AVG_VEHICLE_COUNT_ROLLING_12MO" ;;
  }

  measure: monthly_claims_count {
    type: sum
    sql: ${TABLE}."MONTHLY_CLAIMS_COUNT" ;;
  }

  measure: claims_count_rolling_12_mo {
    type: sum
    sql: ${TABLE}."CLAIMS_COUNT_ROLLING_12MO" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
