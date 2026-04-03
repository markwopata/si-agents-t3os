view: int_claims__historic_market_employee_claim_count_rolling_12mo {
  derived_table: {
    sql: select *
         from analytics.claims.int_claims__historic_market_employee_claim_count
        where date_month between dateadd(month, -11, (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}))
        and (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}) ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
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

  measure: monthly_employee_count {
    type: sum
    sql: ${TABLE}."MONTHLY_EMPLOYEE_COUNT" ;;
  }

  measure: avg_headcount_rolling_12_mo {
    type: sum
    sql: ${TABLE}."AVG_HEADCOUNT_ROLLING_12MO" ;;
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
