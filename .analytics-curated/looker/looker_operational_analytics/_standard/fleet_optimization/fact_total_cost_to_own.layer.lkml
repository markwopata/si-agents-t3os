include: "/_base/fleet_optimization/fact_total_cost_to_own.view.lkml"

view: +fact_total_cost_to_own {
  label: "Total Cost to Own - Company wide"

  dimension: asset_age_in_months {
    type: number
    sql: iff(${age_in_months_from_first_rental} < 0, 0, ${age_in_months_from_first_rental}) ;;
  }

  dimension: asset_age_in_years {
    type: number
    sql: ceil(${asset_age_in_months}/12) ;;
  }

  measure: allocated_parts {
    type: sum_distinct
    sql: ${parts_cost} ;;
    sql_distinct_key: ${asset_month_key} ;;
  }

  measure: allocated_labor_cost {
    type: sum_distinct
    sql: ${labor_cost} ;;
    sql_distinct_key: ${asset_month_key} ;;
  }

  measure: allocated_labor_hours {
    type: sum_distinct
    sql: ${work_order_labor_hours} ;;
    sql_distinct_key: ${asset_month_key} ;;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_key} ;;
  }

  measure: per_asset_average_part_cost {
    type: number
    sql: ${allocated_parts}/${asset_count} ;;
  }

  measure: per_asset_average_labor_cost {
    type: number
    sql: ${allocated_labor_cost}/${asset_count} ;;
  }

  measure: per_asset_average_labor_hours {
    type: number
    sql: ${allocated_labor_hours}/${asset_count} ;;
  }

}
