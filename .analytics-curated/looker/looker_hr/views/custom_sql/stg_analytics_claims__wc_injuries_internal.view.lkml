view: stg_analytics_claims__wc_injuries_internal {
  derived_table: {
    sql: select
          wi.claim_number,
          wi.market_id,
          wi.employee_id,
          wi.employee_name,
          wi.date_of_injury::date as date_of_injury,
          date_trunc(month, wi.date_of_injury::date) as month_of_claim,
          wlr.wc_claim_type
    from analytics.claims.stg_analytics_claims__wc_injuries_internal wi
    left join analytics.claims.stg_analytics_claims__wc_loss_run wlr
        on upper(replace(replace(wlr.claim_number, ' ', ''), '-', ''))
            = upper(replace(replace(wi.claim_number, ' ', ''), '-', ''))
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
