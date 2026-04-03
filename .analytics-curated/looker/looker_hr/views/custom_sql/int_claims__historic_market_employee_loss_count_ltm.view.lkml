view: int_claims__historic_market_employee_loss_count_ltm {
  derived_table: {
    sql:
    select *
    from analytics.claims.int_claims__historic_market_employee_loss_count employees
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

  measure: employee_count {
    type: sum
    sql: ${TABLE}."EMPLOYEE_COUNT" ;;
  }
  measure: ltm_employee_count {
    type: sum
    sql: ${TABLE}."LTM_EMPLOYEE_COUNT" ;;
  }
  measure: ltm_loss_count {
    type: sum
    sql: ${TABLE}."LTM_LOSS_COUNT" ;;
  }

  measure: monthly_loss_count {
    type: sum
    sql: ${TABLE}."MONTHLY_LOSS_COUNT" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
