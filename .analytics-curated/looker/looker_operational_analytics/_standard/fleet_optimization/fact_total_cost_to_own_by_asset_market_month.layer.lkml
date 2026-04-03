include: "/_base/fleet_optimization/fact_total_cost_to_own_by_asset_market_month.view.lkml"

view: +fact_total_cost_to_own_by_asset_market_month {
  label: "Total Cost to Own - Market level"

  dimension: asset_age_in_months {
    type: number
    sql: iff(${age_in_months_from_first_rental} < 0, 0, ${age_in_months_from_first_rental}) ;;
  }

  dimension: asset_age_in_years {
    type: number
    sql: ceil(${asset_age_in_months}/12) ;;
  }

  measure: market_accrued_hours {
    type: sum
    sql: ${asset_hours_consumed} ;;
  }

  measure: safe_market_accrued_hours {
    hidden: yes
    type: number
    sql: iff(${market_accrued_hours} = 0, 1, ${market_accrued_hours}) ;;
  }

  measure: market_actual_parts_cost {
    type: sum
    sql: ${parts_cost} ;;
  }

  measure: market_actual_labor_cost {
    type: sum
    sql: ${labor_cost} ;;
  }

  measure: market_actual_labor_hours {
    type: sum
    sql: ${work_order_labor_hours} ;;
  }

  measure: asset_count {
    type: sum
    sql: ${share_of_month} ;;
  }

  measure: market_estimated_part_cost {
    type: number
    sql: ${fact_total_cost_to_own.per_asset_average_part_cost} * ${asset_count} ;;
  }

  measure: market_estimated_labor_cost {
    type: number
    sql: ${fact_total_cost_to_own.per_asset_average_labor_cost} * ${asset_count} ;;
  }

  measure: market_actual_part_cost_per_hour {
    type: number
    sql: ${market_actual_parts_cost}/${safe_market_accrued_hours} ;;
  }

  measure: market_actual_labor_cost_per_hour {
    type: number
    sql: ${market_actual_labor_cost}/${safe_market_accrued_hours} ;;
  }

  measure: market_estimated_part_cost_per_hour {
    type: number
    sql: ${market_estimated_part_cost}/${safe_market_accrued_hours} ;;
  }

  measure: market_estimated_labor_cost_per_hour {
    type: number
    sql: ${market_estimated_labor_cost}/${safe_market_accrued_hours} ;;
  }

  measure: per_hour_impact_part_cost_dollar {
    type: number
    sql: ${market_actual_part_cost_per_hour} - ${market_estimated_part_cost_per_hour} ;;
  }

  measure: per_hour_impact_labor_cost_dollar {
    type: number
    sql: ${market_actual_labor_cost_per_hour} - ${market_estimated_labor_cost_per_hour} ;;
  }

  measure: per_hour_impact_part_cost_percent {
    type: number
    sql: ${per_hour_impact_part_cost_dollar} / zeroifnull(${market_actual_part_cost_per_hour}) ;;
  }

  measure: per_hour_impact_labor_cost_percent {
    type: number
    sql: ${per_hour_impact_labor_cost_dollar} / zeroifnull(${market_actual_labor_cost_per_hour}) ;;
  }

  measure: total_dollar_impact_parts {
    type: number
    sql: ${market_actual_parts_cost} - ${market_estimated_part_cost} ;;
  }

  measure: total_dollar_impact_labor_cost {
    type: number
    sql: ${market_actual_labor_cost} - ${market_estimated_labor_cost} ;;
  }

}
