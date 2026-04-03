view: current_residual_values_by_class {
  sql_table_name: "DATA_SCIENCE"."FLEET_OPT"."CURRENT_RESIDUAL_VALUES_BY_CLASS" ;;

  dimension: date_created {
    type: string
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: equipment_class_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: months_old {
    type: number
    sql: ${TABLE}."MONTHS_OLD" ;;
  }

  dimension: retail_pct_depreciation {
    type: number
    sql: ${TABLE}."RETAIL_PCT_DEPRECIATION" ;;
  }
  dimension: wholesale_pct_depreciation {
    type: number
    sql: ${TABLE}."WHOLESALE_PCT_DEPRECIATION" ;;
  }
  dimension: auction_pct_depreciation {
    type: number
    sql: ${TABLE}."AUCTION_PCT_DEPRECIATION" ;;
  }

  measure: count {
    type: count
  }

  # User inputs an end date for forecasting
  parameter: period_end_date {
    type: date
    default_value: "2030-01-01"
    label: "Period End Date"
    description: "End date used to project residual values"
  }
  dimension: period_end_date_row_display {
    type: date
    sql: {% parameter period_end_date._parameter_value %} ;;
  }
  dimension: months_to_period_end {
    type: number
    hidden: yes
    sql:
    DATEDIFF(
      MONTH,
      CURRENT_DATE(),
      {% parameter period_end_date._parameter_value %}
    )
  ;;
  }
  dimension: years_to_period_end {
    type: number
    hidden: yes
    sql: ${months_to_period_end} / 12 ;;
  }

  parameter: inflation_rate {
    type: number
    label: "Inflation Rate (%)"
    default_value: "2.5"
    }

  # NOTE: These will only work if end_period, today, and all_equipment_rouse_estimates_new joined together
  dimension: residual_value_retail_row {
    label: "Forecasted Retail Residual Value"
    description: "ONLY to be used in 'TODAY' due to calculations"
    type: number
    value_format_name: usd
    sql:
    POWER(1 + {% parameter inflation_rate %} / 100, ${years_to_period_end})
    *
    ${all_equipment_rouse_estimates_new.predictions_retail}
    *
    (
      ${end_period.retail_pct_depreciation}
      / NULLIF(${today.retail_pct_depreciation}, 0)
    )
  ;;
  }
  dimension: forecasted_residual_value_wholesale {
    label: "Forecasted Wholesale Residual Value"
    description: "ONLY to be used in 'TODAY' due to calculations"
    type: number
    value_format_name: usd
    sql:
    POWER(1 + {% parameter inflation_rate %} / 100, ${years_to_period_end})
    *
    ${all_equipment_rouse_estimates_new.predictions_wholesale}
    *
    (
      ${end_period.wholesale_pct_depreciation}
      / NULLIF(${today.wholesale_pct_depreciation}, 0)
    )
  ;;
  }
  dimension: forecasted_residual_value_auction {
    label: "Forecasted Auction Residual Value"
    description: "ONLY to be used in 'TODAY' due to calculations"
    type: number
    value_format_name: usd
    sql:
    POWER(1 + {% parameter inflation_rate %} / 100, ${years_to_period_end})
    *
    ${all_equipment_rouse_estimates_new.predictions_auction}
    *
    (
      ${end_period.auction_pct_depreciation}
      / NULLIF(${today.auction_pct_depreciation}, 0)
    )
  ;;
  }
}
