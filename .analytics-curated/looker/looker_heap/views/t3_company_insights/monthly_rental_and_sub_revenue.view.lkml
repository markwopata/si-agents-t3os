view: monthly_rental_and_sub_revenue {
    derived_table: {
      sql: SELECT * FROM ANALYTICS.T3_ANALYTICS.MONTHLY_RENT_AND_SUB_REV where INVOICE_MONTH::DATE >= '2023-01-01';;
    }

  ########################
  ## Primary Key
  ########################
  ##primary_key: uid

  dimension: uid {
    primary_key: yes
    type: string
    description: "Unique identifier for the company-month record (Company_ID + Invoice_Month)."
    label: "Unique Record ID"
    hidden: yes
  }

  set: revenue_details {
    fields: [
      invoice_month_date,
      company_name,
      company_tenure,
      t3_mrr,
      rental_revenue,
      t3_other_revenue,
      monthly_combined_revenue,
      t3_subscriptions
    ]
  }


  ########################
  ## Company Information
  ########################
  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    description: "Unique identifier for the company."
    label: "Company ID"
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    description: "Name of the company."
    label: "Company Name"
  }

  measure: company_tenure {
    type: number
    sql: ${TABLE}.company_tenure ;;
    description: "Number of months since the company was first seen until this invoice month."
    label: "Company Tenure (Months)"
  }


  ########################
  ## Time Dimensions
  ########################
  dimension_group: invoice_month {
    type: time
    sql: ${TABLE}.invoice_month ;;
    description: "Invoice month for the recorded revenue."
    label: "Invoice Month"
    drill_fields: [revenue_details*]
  }

  dimension: invoice_year {
    type: string
    sql: ${TABLE}.invoice_year ;;
    description: "Fiscal year derived from the invoice date."
    label: "Invoice Year"
    drill_fields: [revenue_details*]
  }

  ########################
  ## Monthly Revenue & Metrics
  ########################
  dimension: mrr {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.t3_mrr ;;
    description: "Monthly T3 subscription revenue (including credits)."
    label: "MRR"
  }

  measure: t3_mrr {
    type: sum
    value_format: "$#,##0.00"
    sql: ${mrr};;
    description: "Monthly T3 subscription revenue (including credits)."
    label: "T3 MRR"
    drill_fields: [revenue_details*]
  }

  dimension: t3_subcription_credit {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.t3_subcription_credit ;;
    description: "Credit amount applied to T3 subscriptions this month."
    label: "T3 Subscription Credit"
  }

  dimension: t3_subscriptions {
    type: number
    sql: ${TABLE}.t3_subscriptions ;;
    description: "Number of T3 subscription line items this month."
    label: "T3 Subscriptions"
  }

  measure: t3_subscription_count {
    type: max
    sql: ${t3_subscriptions};;
    description: "Number of T3 subscription line items this month."
    label: "T3 Subscription Count"
    drill_fields: [revenue_details*]
  }

  dimension: rental_rev {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.rental_revenue ;;
    description: "Monthly rental revenue from this company."
    label: "Rental Revenue"
  }

  measure: rental_revenue {
    type: sum
    value_format: "$#,##0.00"
    sql: ${rental_rev};;
    description: "Monthly rental revenue from this company."
    label: "Monthly Rental Revenue"
    drill_fields: [revenue_details*]
  }

  dimension: t3_other_revenue {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.t3_other_revenue ;;
    description: "Other T3-related revenue lines (not core subscription or rentals)."
    label: "T3 Revenue-Other"
  }

  measure: other_t3_revenue {
    type: sum
    value_format: "$#,##0.00"
    sql: ${t3_other_revenue};;
    description: "Other T3-related revenue lines (not core subscription or rentals)."
    label: "Other T3 Revenue"
    drill_fields: [revenue_details*]
  }

  dimension: monthly_combined_revenue {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.monthly_combined_revenue ;;
    description: "Monthly combined revenue (T3 + Rentals)."
    label: "Combined Revenue-Monthly"
  }

  measure: combined_revenue {
    type: sum
    value_format: "$#,##0.00"
    sql: ${monthly_combined_revenue};;
    description: "Monthly combined revenue (T3 + Rentals)."
    label: "Monthly Combined Revenue"
    drill_fields: [revenue_details*]
  }

  ########################
  ## Cumulative & Aggregate Metrics
  ########################
  dimension: t3_subscription_revenue_to_date {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.t3_subscription_revenue_to_date ;;
    description: "Cumulative T3 subscription revenue to date."
  }

  measure: t3_subscription_revenue_cummulative {
    type: sum
    value_format: "$#,##0.00"
    sql: ${t3_subscription_revenue_to_date};;
    description: "Cumulative T3 subscription revenue to date."
    drill_fields: [revenue_details*]
    label: "T3 Subscription Revenue to Date"
  }

  dimension: rental_revenue_to_date {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.rental_revenue_to_date ;;
    description: "Cumulative rental revenue to date."
  }

  measure: rental_revenue_cummulative {
    type: sum
    value_format: "$#,##0.00"
    sql: ${rental_revenue_to_date};;
    description: "Cumulative rental revenue to date."
    drill_fields: [revenue_details*]
    label: "Rental Revenue to Date"
  }

  dimension: other_t3_revenue_to_date {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.other_t3_revenue_to_date ;;
    description: "Cumulative other T3 revenue to date."
    label: "Other T3 Revenue to Date"
  }

  dimension: cumulative_combined_revenue {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.cumulative_combined_revenue ;;
    description: "Cumulative combined revenue (T3 + Rental) to date."
    label: "Cumulative Combined Revenue"
  }

  measure: ltv_revenue_to_date {
    type: sum
    value_format: "$#,##0.00"
    sql: ${cumulative_combined_revenue};;
    description: "LTV (T3 + Rental Revenue) to date."
    drill_fields: [revenue_details*]
    label: "Combined Revenue to Date"
  }

  dimension: median_annual_mrr {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.median_annual_mrr ;;
    description: "Median MRR for the given year per company."
    label: "Median Annual MRR"
  }

  dimension: arr {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.arr ;;
    description: "Annual Recurring Revenue (ARR) approximated from monthly values."
  }

  measure: arr_approx {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.arr ;;
    description: "Annual Recurring Revenue (ARR) approximated from monthly values."
    drill_fields: [revenue_details*]
    label: "ARR"
  }

  ########################
  ## Deltas & Rank
  ########################
  dimension: t3_mrr_delta {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.t3_mrr_delta ;;
    description: "Change in T3 MRR from the previous month."
  }

  measure: t3_mrr_diff {
    type: sum
    value_format: "$#,##0.00"
    sql: ${t3_mrr_delta};;
    description: "Change in T3 MRR from the previous month."
    label: "T3 MRR Delta"
  }

  dimension: t3_subscription_delta {
    type: number
    sql: ${TABLE}.t3_subscription_delta ;;
    description: "Change in the number of T3 subscriptions from the previous month."
  }

  measure: t3_subscription_diff {
    type: sum
    sql: ${t3_subscription_delta};;
    description: "Change in the number of T3 subscriptions from the previous month."
    label: "T3 Subscription Delta"
  }

  dimension: rental_revenue_delta {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.rental_revenue_delta ;;
    description: "Month-over-month change in rental revenue."
  }

  measure: rental_revenue_diff {
    type: sum
    value_format: "$#,##0.00"
    sql: ${rental_revenue_delta};;
    description: "Month-over-month change in rental revenue."
    label: "Rental Revenue Delta"
  }

  measure: rank {
    type: number
    sql: ${TABLE}.rank ;;
    description: "Sequential month index for the company starting at their first invoice month."
    label: "Month Rank"
  }

  ########################
  ## Churn & Tenure
  ########################
  dimension: t3_subscription_churn_month {
    type: date
    sql: ${TABLE}.t3_subscription_churn_month ;;
    description: "Month in which the company churned from T3 subscriptions."
    label: "T3 Churn Month"
  }

  dimension: tenure_months_at_churn {
    type: number
    sql: ${TABLE}.tenure_months_at_churn ;;
    description: "The number of months the company was active until churn."
    drill_fields: [revenue_details*]
    }

  measure: churn_tenure_months {
    type: number
    sql: ${tenure_months_at_churn};;
    description: "The number of months the company was active until churn."
    label: "Tenure at Churn (Months)"
    drill_fields: [revenue_details*]
  }

  dimension: arr_lost_hub_spot {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.arr_lost_hub_spot ;;
    description: "ARR lost at the time of churn as recorded in HubSpot."
  }


  measure: arr_lost_hubspot {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.arr_lost_hub_spot ;;
    description: "ARR lost at the time of churn as recorded in HubSpot."
    drill_fields: [revenue_details*]
    label: "ARR Lost at Churn"
  }

  ########################
  ## LTV Calculation (Proxy)
  ########################
  # Using cumulative combined revenue as a proxy for LTV.
  # For churned customers, this represents total value extracted.
  # For active customers, it's the value to date.
  measure: ltv {
    type: number
    value_format: "$#,##0.00"
    label: "LTV (Churn-Adjusted)"
    description: "Lifetime Value: For churned companies, total cumulative combined revenue at churn. For active companies, cumulative combined revenue plus one projected year of ARR."
    drill_fields: [revenue_details*]

    sql:
    CASE
      WHEN ${t3_subscription_churn_month} IS NOT NULL THEN
        -- Churned: LTV is just cumulative combined revenue
        ${cumulative_combined_revenue}
      ELSE
        -- Active: LTV is cumulative combined revenue + one year of ARR (which is median_annual_mrr * 12)
        (${cumulative_combined_revenue} + ${arr})
    END
  ;;
  }

  ########################
  ## Additional Measures
  ########################
  measure: total_t3_subscriptions {
    type: sum
    sql: ${t3_subscriptions} ;;
    description: "Total count of T3 subscriptions aggregated over the chosen time frame."
    label: "Total T3 Subscriptions"
    drill_fields: [revenue_details*]
  }

  measure: total_monthly_combined_revenue {
    type: sum
    sql: ${monthly_combined_revenue} ;;
    description: "Sum of monthly combined revenue for the chosen time frame."
    label: "Total Monthly Combined Revenue"
    value_format: "$#,##0.00"
    drill_fields: [revenue_details*]
  }

  measure: avg_monthly_combined_revenue {
    type: average
    sql: ${monthly_combined_revenue} ;;
    description: "Average monthly combined revenue."
    label: "Avg Monthly Combined Revenue"
    drill_fields: [revenue_details*]
  }

  measure: max_cumulative_revenue {
    type: max
    sql: ${cumulative_combined_revenue} ;;
    description: "Maximum cumulative combined revenue observed."
    label: "Max Cumulative Revenue"
    drill_fields: [revenue_details*]
  }

  measure: min_cumulative_revenue {
    type: min
    sql: ${cumulative_combined_revenue} ;;
    description: "Minimum cumulative combined revenue observed."
    label: "Min Cumulative Revenue"
    drill_fields: [revenue_details*]
  }

  dimension: is_vip_customer {
    type: yesno
    sql:
    CASE WHEN ${TABLE}.COMPANY_ID IN (50, 8935, 2968, 7978, 5437, 5658, 24008, 11674, 60574, 10924)
         THEN TRUE
         ELSE FALSE
    END
  ;;
  }



}
