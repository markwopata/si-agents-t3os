view: int_claims__work_comp_insurance_claims_rolling_12mo {
  derived_table: {
    sql: select *, date_trunc(month, date_of_injury::date) as month_of_claim,
    from analytics.claims.int_claims__work_comp_insurance_claims
    where month_of_claim between dateadd(month, -11, (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}))
      and (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}) ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: claim_number {
    type: string
    sql: ${TABLE}."CLAIM_NUMBER" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: date_of_injury {
    type: date
    sql: ${TABLE}."DATE_OF_INJURY" ;;
  }

  dimension: month_of_claim {
    type: date
    sql: ${TABLE}."MONTH_OF_CLAIM" ;;
  }

  dimension: wc_claim_type {
    type: string
    sql: ${TABLE}."WC_CLAIM_TYPE" ;;
  }
}
