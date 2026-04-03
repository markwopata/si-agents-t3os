view: be_account_targets_and_projections {
  sql_table_name: "BRANCH_EARNINGS"."BE_ACCOUNT_TARGETS_PROJECTIONS" ;;

  dimension: region_id {
    label: "RegionID"
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: gl_month_date {
    type: date
    sql: ${TABLE}."GL_MONTH" ;;
  }

  dimension_group: gl_month {
    label: "GL Month"
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}."GL_MONTH" ;;
  }

  dimension: month_status {
    type: string
    sql: ${TABLE}."MONTH_STATUS" ;;
  }

  dimension: account_no {
    type: string
    sql: ${TABLE}."ACCOUNT_NO" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: rev_exp {
    label: "Rev/Exp"
    type: string
    sql: ${TABLE}."REV_EXP" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  dimension: cost_type {
    type: string
    sql: ${TABLE}."COST_TYPE" ;;
  }

  measure: actual_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."ACTUAL_AMOUNT" ;;
  }

  dimension: comp_metric {
    type: string
    sql: ${TABLE}."COMP_METRIC" ;;
  }

  measure: comp_metric_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."COMP_METRIC_AMOUNT" ;;
  }

  measure: month_end_projected_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."MONTH_END_PROJECTED_AMOUNT" ;;
  }

  measure: month_end_projected_comp_metric_amount {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT" ;;
  }

  measure: account_target_pct {
    label: "Target % of Metric"
    type: max
    value_format_name: percent_2
    sql: ${TABLE}."ACCOUNT_TARGET_PCT" ;;
  }

  measure: actual_projected_amount {
    label: "Actual/Projected Amount"
    type: sum
    value_format_name: decimal_2
    sql: coalesce(${TABLE}."MONTH_END_PROJECTED_AMOUNT", ${TABLE}."ACTUAL_AMOUNT") ;;
  }

  measure: actual_pct_of_metric {
    label: "Actual/Projected % of Metric"
    type: number
    value_format_name: percent_2
    sql: sum(case
              when ${TABLE}."COMP_METRIC" = 'Annualized % of OEC'
               and ${TABLE}."REV_EXP" = 'EXP' and ${TABLE}."ACCOUNT_NO" not in('7806','BFEB')
                then coalesce(${TABLE}."MONTH_END_PROJECTED_AMOUNT", ${TABLE}."ACTUAL_AMOUNT") * -1 * 12
              when ${TABLE}."COMP_METRIC" = 'Annualized % of OEC'
                then coalesce(${TABLE}."MONTH_END_PROJECTED_AMOUNT", ${TABLE}."ACTUAL_AMOUNT") * 12
              when ${TABLE}."REV_EXP" = 'EXP' and ${TABLE}."ACCOUNT_NO" not in('7806','BFEB')
               then coalesce(${TABLE}."MONTH_END_PROJECTED_AMOUNT", ${TABLE}."ACTUAL_AMOUNT") * -1
              else coalesce(${TABLE}."MONTH_END_PROJECTED_AMOUNT", ${TABLE}."ACTUAL_AMOUNT")
             end)
         / sum(coalesce(${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT", ${TABLE}."COMP_METRIC_AMOUNT"));;
  }

  measure: target_amount {
    type: number
    value_format_name: decimal_2
    sql: sum(case
              when ${TABLE}."COMP_METRIC" = 'Annualized % of OEC'
               and ${TABLE}."REV_EXP" = 'EXP' and ${TABLE}."ACCOUNT_NO" not in('7806','BFEB')
                then (coalesce(${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT", ${TABLE}."COMP_METRIC_AMOUNT") * -1 * ${TABLE}."ACCOUNT_TARGET_PCT")/12
              when ${TABLE}."COMP_METRIC" = 'Annualized % of OEC'
               then (coalesce(${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT", ${TABLE}."COMP_METRIC_AMOUNT") * ${TABLE}."ACCOUNT_TARGET_PCT")/12
              when ${TABLE}."REV_EXP" = 'EXP' and ${TABLE}."ACCOUNT_NO" not in('7806','BFEB')
               then coalesce(${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT", ${TABLE}."COMP_METRIC_AMOUNT") * ${TABLE}."ACCOUNT_TARGET_PCT" * -1
              else coalesce(${TABLE}."MONTH_END_PROJECTED_COMP_METRIC_AMOUNT", ${TABLE}."COMP_METRIC_AMOUNT") * ${TABLE}."ACCOUNT_TARGET_PCT"
            end);;
  }

  measure: expense_delta {
    type: number
    value_format_name: decimal_2
    sql: ${target_amount} - ${actual_projected_amount};;
  }

  measure: revenue_delta {
    type: number
    value_format_name: decimal_2
    sql: ${actual_projected_amount} - ${target_amount};;
  }

}
