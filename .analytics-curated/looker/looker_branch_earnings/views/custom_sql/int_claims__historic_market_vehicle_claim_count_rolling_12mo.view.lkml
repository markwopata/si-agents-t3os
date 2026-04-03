view: int_claims__historic_market_vehicle_claim_count_rolling_12mo {
  derived_table: {
    sql: select *
         from analytics.claims.int_claims__historic_market_vehicle_claim_count ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: pk {
    type: string
    sql: concat(${market_id},'-',${date_month_date}) ;;
    hidden: yes
    primary_key: yes
  }

  dimension_group: date_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
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
    label: "Number of Auto Claims"
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
