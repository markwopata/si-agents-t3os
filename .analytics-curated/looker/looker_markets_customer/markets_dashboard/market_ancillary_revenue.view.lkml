
view: market_ancillary_revenue {
  sql_table_name:  analytics.bi_ops.market_ancillary_revenue -- table no longer updating!! use new dbt model;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: billing_approved_date {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: date_refresh_timestamp {
    type: time
    sql: ${TABLE}."DATE_REFRESH_TIMESTAMP" ;;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: date
    sql: concat(${billing_approved_date_month}, '-01');;
    html: {{value | date: "%b %Y" }} ;;

  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."MONTHS_OPEN_OVER_12" ;;
  }

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }

  dimension: prior_month {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH" ;;
  }

  dimension: revenue_type {
    type: string
    sql: ${TABLE}."REVENUE_TYPE" ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: total_retail_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Retail"]
  }

  measure: total_parts_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Parts"]
  }

  measure: total_service_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Service"]
  }

  measure: total_bulk_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Bulk"]
  }

  measure: total_delivery_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Delivery"]
  }

  measure: total_other_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [revenue_type: "Other"]
  }

  measure: current_month_total_retail_revenue {
    group_label: "Current Month Metrics"
    label: "Retail Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Retail"]
  }

  measure: current_month_total_parts_revenue {
    group_label: "Current Month Metrics"
    label: "Parts Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Parts"]
  }

  measure: current_month_total_service_revenue {
    group_label: "Current Month Metrics"
    label: "Service Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Service"]
  }

  measure: current_month_total_bulk_revenue {
    group_label: "Current Month Metrics"
    label: "Bulk Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Bulk"]
  }

  measure: current_month_total_delivery_revenue {
    group_label: "Current Month Metrics"
    label: "Delivery Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Delivery"]
  }

  measure: current_month_total_other_revenue {
    group_label: "Current Month Metrics"
    label: "Other Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [current_month: "TRUE", revenue_type: "Other"]
  }

  measure: prior_month_total_retail_revenue {
    group_label: "Prior Month Metrics"
    label: "Retail Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Retail"]
  }

  measure: prior_month_total_parts_revenue {
    group_label: "Prior Month Metrics"
    label: "Parts Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Parts"]
  }

  measure: prior_month_total_service_revenue {
    group_label: "Prior Month Metrics"
    label: "Service Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Service"]
  }

  measure: prior_month_total_bulk_revenue {
    group_label: "Prior Month Metrics"
    label: "Bulk Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Bulk"]
  }

  measure: prior_month_total_delivery_revenue {
    group_label: "Prior Month Metrics"
    label: "Delivery Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Delivery"]
  }

  measure: prior_month_total_other_revenue {
    group_label: "Prior Month Metrics"
    label: "Other Revenue"
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
    filters: [prior_month: "TRUE", revenue_type: "Other"]
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd_0
  }

  measure: total_revenue_formatted {
    type: sum
    label: "Total Revenue"
    sql: ${revenue} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [formatted_month, region, revenue_type, total_revenue_formatted]
  }

  measure: total_revenue_pie_chart_format {
    label: "Total Revenue"
    description: "The label is needed for the visual on the markets dashboard"
    type: sum
    sql: ${revenue} ;;
    html: {{rendered_value}} || {{percent_of_total_pie_chart._rendered_value}} of total;;
    value_format_name: usd_0
    drill_fields: [customer, salesperson, total_revenue, revenue_type]
  }

  measure: percent_of_total_pie_chart {
    type: percent_of_total
    sql: ${total_revenue} ;;
  }

  measure: total_revenue_column_chart_format {
    type: sum
    sql: ${revenue} ;;
    html: {{rendered_value}} || {{percent_of_total_column_chart._rendered_value}} of total;;
    value_format_name: usd_0
    drill_fields: [customer, salesperson, total_revenue, revenue_type]
  }

  measure: percent_of_total_column_chart{
    type: percent_of_total
    sql: ${total_revenue} ;;
    direction: "column"
  }

  set: detail {
    fields: [
        billing_approved_date_time,
  region,
  district,
  market,
  market_type,
  months_open_over_12,
  current_month,
  revenue_type,
  revenue
    ]
  }
}
