view: na_contract_scoring_quotes_audit_summary {
  sql_table_name: "RATE_ACHIEVEMENT"."NA_CONTRACT_SCORING_QUOTES_AUDIT_SUMMARY" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  # dimension: _row {
  #   type: number
  #   sql: ${TABLE}."_ROW" ;;
  # }
  dimension: annual_projected_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ANNUAL_PROJECTED_REVENUE" ;;
  }
  dimension: as_average_gross_profit_margin_percent {
    type: number
    label: "AS Total Gross Profit Margin (%)"
    value_format_name: percent_2
    sql: ${TABLE}."AS_AVERAGE_GROSS_PROFIT_MARGIN_PERCENT" ;;
  }
  dimension: as_total_gross_profit_margin_dollars {
    type: number
    label: "AS Total Gross Profit Margin ($)"
    value_format_name: usd_0
    sql: ${TABLE}."AS_TOTAL_GROSS_PROFIT_MARGIN_DOLLARS" ;;
  }
  dimension: bid_status {
    type: string
    sql: ${TABLE}."BID_STATUS" ;;
  }
  dimension: billing_period {
    type: string
    sql: ${TABLE}."BILLING_PERIOD" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: core_average_gross_profit_margin_percent {
    type: number
    label: "Core Total Gross Profit Margin (%)"
    value_format_name: percent_2
    sql: ${TABLE}."CORE_AVERAGE_GROSS_PROFIT_MARGIN_PERCENT" ;;
  }
  dimension: core_total_gross_profit_margin_dollars {
    type: number
    label: "Core Total Gross Profit Margin ($)"
    value_format_name: usd_0
    sql: ${TABLE}."CORE_TOTAL_GROSS_PROFIT_MARGIN_DOLLARS" ;;
  }
  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension: created_by_name {
    label: "Created By Name"
    sql: ${dim_users_fleet_opt.user_full_name} ;;
  }
  dimension: customer_rebate {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}."CUSTOMER_REBATE" ;;
  }
  # dimension_group: date_created {
  #   type: time
  #   timeframes: [raw, time, date, week, month, quarter, year]
  #   sql: ${TABLE}."DATE_CREATED" ;;
  # }

  dimension: formatting_change_reasoning {
    type: string
    sql: ${TABLE}."FORMATTING_CHANGE_REASONING" ;;
  }
  dimension: formatting_changed_from_template {
    type: string
    sql: ${TABLE}."FORMATTING_CHANGED_FROM_TEMPLATE" ;;
  }

  dimension: itl_average_gross_profit_margin_percent {
    type: number
    label: "ITL Total Gross Profit Margin (%)"
    value_format_name: percent_2
    sql: ${TABLE}."ITL_AVERAGE_GROSS_PROFIT_MARGIN_PERCENT" ;;
  }
  dimension: itl_total_gross_profit_margin_dollars {
    type: number
    label: "ITL Total Gross Profit Margin ($)"
    value_format_name: usd_0
    sql: ${TABLE}."ITL_TOTAL_GROSS_PROFIT_MARGIN_DOLLARS" ;;
  }
  dimension: national_account {
    # suggest_persist_for: "1 minute"
    type: string
    sql: ${TABLE}."NATIONAL_ACCOUNT" ;;
  }
  dimension: national_account_manager {
    type: string
    # suggest_persist_for: "1 minute"
    sql: ${TABLE}."NATIONAL_ACCOUNT_MANAGER" ;;
  }
  dimension: overall_average_gross_profit_margin_percent {
    type: number
    label: "Overall Total Gross Profit Margin (%)"
    value_format_name: percent_2
    sql: ${TABLE}."OVERALL_AVERAGE_GROSS_PROFIT_MARGIN_PERCENT" ;;
  }
  dimension: overall_total_gross_profit_margin_dollars {
    type: number
    label: "Overall Total Gross Profit Margin ($)"
    value_format_name: usd_0
    sql: ${TABLE}."OVERALL_TOTAL_GROSS_PROFIT_MARGIN_DOLLARS" ;;
  }
  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: quote_file_url {
    # primary_key: yes
    type: string
    sql: ${TABLE}."QUOTE_FILE_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color:blue; text-decoration:underline;">
    {{value}}
    </a>;;
  }
  dimension: quote_file_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."QUOTE_FILE_ID" ;;
  }

  dimension_group: rate_active {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RATE_ACTIVE_DATE" ;;
  }
  dimension_group: rate_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RATE_CREATED_DATE" ;;
  }
  dimension_group: rate_expiration {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RATE_EXPIRATION_DATE" ;;
  }

  dimension: rpp_included {
    type: string
    sql: ${TABLE}."RPP_INCLUDED" ;;
  }
  dimension: transportation_included {
    type: string
    sql: ${TABLE}."TRANSPORTATION_INCLUDED" ;;
  }
  dimension: environmental_fees_included {
    type: string
    sql: ${TABLE}."ENVIRONMENTAL_FEES_INCLUDED" ;;
  }

  dimension: average_diff_in_floor_vs_quoted_rate {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."AVERAGE_DIFF_IN_FLOOR_VS_QUOTED_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name]
  }

  measure: count_of_quotes {
    type: count_distinct
    sql: ${quote_file_id} ;;
    drill_fields: [company_name, quote_file_url]
  }
  measure: count_of_nams {
    type: count_distinct
    sql: ${national_account_manager} ;;
  }

  measure: sum_core_profit_margin_dollars {
    type: sum
    label: "Sum Core Profit Margin ($)"
    value_format_name: usd_0
    sql: ${core_total_gross_profit_margin_dollars} ;;
  }
  measure: average_core_profit_margin_dollars {
    type: average
    label: "Average Core Profit Margin ($)"
    value_format_name: usd_0
    sql: ${core_total_gross_profit_margin_dollars} ;;
  }
  measure: average_core_average_profit_margin_percent {
    type: average
    label: "Average Core Profit Margin (%)"
    value_format_name: percent_2
    sql: ${core_average_gross_profit_margin_percent} ;;
  }

  measure: sum_as_profit_margin_dollars {
    type: sum
    label: "Sum AS Profit Margin ($)"
    value_format_name: usd_0
    sql: ${as_total_gross_profit_margin_dollars} ;;
  }
  measure: average_as_profit_margin_dollars {
    type: average
    label: "Average AS Profit Margin ($)"
    value_format_name: usd_0
    sql: ${as_total_gross_profit_margin_dollars} ;;
  }
  measure: average_as_average_profit_margin_percent {
    type: average
    label: "Average AS Profit Margin (%)"
    value_format_name: percent_2
    sql: ${as_average_gross_profit_margin_percent} ;;
  }

  measure: sum_itl_profit_margin_dollars {
    type: sum
    label: "Sum ITL Profit Margin ($)"
    value_format_name: usd_0
    sql: ${as_total_gross_profit_margin_dollars} ;;
  }
  measure: average_itl_profit_margin_dollars {
    type: average
    label: "Average ITL Profit Margin ($)"
    value_format_name: usd_0
    sql: ${as_total_gross_profit_margin_dollars} ;;
  }
  measure: average_itl_average_profit_margin_percent {
    type: average
    label: "Average ITL Profit Margin (%)"
    value_format_name: percent_2
    sql: ${itl_average_gross_profit_margin_percent} ;;
  }

  measure: sum_overall_profit_margin_dollars {
    type: sum
    label: "Sum Overall Profit Margin ($)"
    value_format_name: usd_0
    sql: ${overall_total_gross_profit_margin_dollars} ;;
  }
  measure: average_overall_profit_margin_dollars {
    type: average
    label: "Average Overall Profit Margin ($)"
    value_format_name: usd_0
    sql: ${overall_total_gross_profit_margin_dollars} ;;
  }
  measure: average_overall_average_profit_margin_percent {
    type: average
    label: "Average Overall Profit Margin (%)"
    value_format_name: percent_2
    sql: ${overall_average_gross_profit_margin_percent} ;;
  }

}
