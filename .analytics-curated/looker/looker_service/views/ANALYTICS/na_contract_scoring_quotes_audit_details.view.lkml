view: na_contract_scoring_quotes_audit_details {
  sql_table_name: "RATE_ACHIEVEMENT"."NA_CONTRACT_SCORING_QUOTES_AUDIT_DETAILS" ;;

  # dimension_group: _fivetran_synced {
  #   type: time
  #   timeframes: [raw, time, date, week, month, quarter, year]
  #   sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  # }
  # dimension: _row {
  #   type: number
  #   sql: ${TABLE}."_ROW" ;;
  # }
  dimension: diff_in_floor_vs_quoted_rate {
    label: "Diff in Floor vs Quoted Rate"
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."DIFF_IN_FLOOR_VS_QUOTED_RATE" ;;
  }
  dimension: breakeven_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."BREAKEVEN_RATE" ;;
  }
  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }
  dimension: class_ranking {
    type: number
    sql: ${TABLE}."CLASS_RANKING" ;;
  }
  dimension: class_revenue_share {
    type: number
    label: "Class Revenue Share (%)"
    value_format_name: percent_2
    sql: ${TABLE}."CLASS_REVENUE_SHARE" ;;
  }
  dimension: equipment_class_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: estimated_annual_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ESTIMATED_ANNUAL_REVENUE" ;;
  }
  dimension: gross_profit_margin_dollars {
    type: number
    label: "Gross Profit Margin ($)"
    value_format_name: usd_0
    sql: ${TABLE}."GROSS_PROFIT_MARGIN_DOLLARS" ;;
  }
  dimension: gross_profit_margin_percent {
    type: number
    label: "Gross Profit Margin (%)"
    value_format_name: percent_2
    sql: ${TABLE}."GROSS_PROFIT_MARGIN_PERCENT" ;;
  }
  dimension: override_monthly_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."OVERRIDE_MONTHLY_RATE" ;;
  }
  dimension: percent_difference_in_suggested_vs_override_monthly_rates {
    type: number
    label: "Diff in Suggested vs Override Rate"
    # value_format: "0.00\%"
    value_format_name: percent_2
    sql: ${TABLE}."PERCENT_DIFFERENCE_IN_SUGGESTED_VS_OVERRIDE_MONTHLY_RATES" ;;
  }
  dimension: pricing_sensitivity {
    type: number
    sql: ${TABLE}."PRICING_SENSITIVITY" ;;
  }
  dimension: primary_key {
    type: string
    sql: ${TABLE}."PRIMARY_KEY" ;;
  }
  dimension: quote_file_id {
    type: string
    sql: ${TABLE}."QUOTE_FILE_ID" ;;
  }
  dimension: quote_file_url {
    type: string
    sql: ${TABLE}."QUOTE_FILE_URL" ;;
    description: "Opens link in a new tab."
    html: <a href="{{value}}" target="_blank" style="color:blue; text-decoration:underline;">
    {{value}}
    </a>;;
  }
  dimension: suggested_monthly_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."SUGGESTED_MONTHLY_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_class_name]
  }
  measure: average_pricing_sensitivity {
    type: average
    sql: ${pricing_sensitivity} ;;
  }
  # measure: average_override_difference_percentage {
  #   type: average
  #   label: "Average Diff in Suggested vs Override Rate"
  #   value_format_name: percent_2
  #   # order_by_field: average_override_percentage_sort
  #   sql: ${percent_difference_in_suggested_vs_override_monthly_rates};;
  # }
  # measure: weighted_average_rate_diff_pct_by_projected_revenue {
  #   type: number
  #   # label: "Average Difference in Suggested vs Override Rate (Revenue Weighted)"
  #   label: "Avg Diff in Floor vs Quoted Rate"
  #   # (avg monthyl rate diff * est annual revenue) for eahc row / total project rev
  #   sql:
  #   SUM(${percent_difference_in_suggested_vs_override_monthly_rates} / 100 * ${estimated_annual_revenue})
  #   / NULLIF(SUM(${estimated_annual_revenue}), 0) ;;
  #   value_format_name: percent_2
  # }

  measure: avg_diff_in_floor_vs_quoted_rate {
    type: average
    label: "Average Diff in Floor vs Quoted Rate"
    sql: ${diff_in_floor_vs_quoted_rate} ;;
  }

  measure: average_gross_profit_margin_dollars {
    type: average
    value_format_name: usd_0
    label: "Average Gross Profit Margin ($)"
    sql: ${gross_profit_margin_dollars} ;;
  }
  measure: sum_gross_profit_margin_dollars {
    type: sum
    value_format_name: usd_0
    label: "Sum Gross Profit Margin ($)"
    sql: ${gross_profit_margin_dollars} ;;
  }

  measure: average_gross_profit_margin_percent {
    type: average
    value_format_name: percent_2
    label: "Average Gross Profit Margin (%)"
    sql: ${gross_profit_margin_percent} ;;
  }

}
