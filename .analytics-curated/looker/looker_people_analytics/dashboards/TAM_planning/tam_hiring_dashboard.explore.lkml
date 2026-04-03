include: "/_standard/custom_sql/tam_hiring_dashboard.view.lkml"
include: "/_standard/custom_sql/market_map.view.lkml"
include: "/_standard/analytics/branch_earnings/parent_market.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"

view: +tam_hiring_dashboard {

  ############### DATES ###############
  dimension_group: date_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${date_month} ;;
  }

  ############### DIMENSIONS ###############
  dimension: pct_under_90_days {
    type: number
    sql: ${total_headcount_under_90_days} / NULLIF(${headcount}, 0) ;;
    value_format_name: "percent_1"
    label: "% Employees First 90 Days"
  }

  dimension: average_tenure_years {
    type: number
    sql: ${total_tenure_years} / NULLIF(${headcount}, 0) ;;
    value_format_name: "decimal_2"
    label: "Avg Tenure (Years)"
  }

  dimension: optimized_headcount {
    type: number
    value_format_name: "decimal_0"
    sql:
    ROUND(
    CASE

      WHEN (COALESCE(${market_name}, '') ilike '%onsite%'
        OR COALESCE(${market_name}, '') ilike '%on-site%')
        then 1

      WHEN ${region} = '1' THEN
        CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
        ELSE 1.6697
        - 0.3305 * ${average_tenure_years}
        + 0.0121 * power(10,-5) * ${total_population}
        + 0.0172 * ${total_company_ids}
        + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '2' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      - 0.1205
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '3' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      - 0.5577
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '4' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      - 0.4645
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '5' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      - 0.1557
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '6' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      + 0.2584
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      WHEN ${region} = '7' THEN
      CASE WHEN ${headcount} = '0' OR ${headcount} = '1' then ROUND(${total_oec}/9000000)
      ELSE 1.6697
      - 0.3305 * ${average_tenure_years}
      - 0.2658
      + 0.0121 * power(10,-5) * ${total_population}
      + 0.0172 * ${total_company_ids}
      + 0.0063 * power(10,-6) * ${total_oec} END

      ELSE NULL
      END
      )
      ;;
  }

  dimension: tam_shortage {
    type: number
    value_format_name: decimal_0
    sql:
    CASE WHEN ${optimized_headcount} - ${headcount} < 0 THEN 0
    ELSE ${optimized_headcount} - ${headcount}
    END;;
  }

  dimension: tam_shortage_with_terms {
    type: number
    value_format_name: decimal_0
    sql:
    CASE WHEN ${optimized_headcount} - ${headcount} + ${terminations} < 0 THEN 0
    ELSE ${optimized_headcount} - ${headcount} + ${terminations}
    END;;
  }

  dimension: headcount_plus_tam_shortage {
    type: number
    value_format_name: decimal_0
    sql:${headcount} + ${tam_shortage};;
  }

  dimension: headcount_difference {
    type: number
    value_format_name: decimal_0
    sql:
    ${optimized_headcount} - ${headcount};;
  }

  ############### MEASURES ###############
  measure: sum_of_terminations {
    type: sum
    sql: ${terminations} ;;
    description: "Sum of every termination."
  }

  measure: sum_of_tenure_days {
    type: sum
    sql: ${total_tenure_days} ;;
    description: "Sum of every employees tenure in days."
  }

  measure: sum_of_tenure_years {
    type: sum
    sql: ${total_tenure_years} ;;
    description: "Sum of every employees tenure in years."
  }

  measure: sum_of_headcount_under_90_days {
    type: sum
    sql: ${total_headcount_under_90_days} ;;
    description: "Count of every employee that has tenure under 180 days."
  }

  measure: sum_of_total_invoices {
    type: sum
    sql: ${total_invoices} ;;
    description: "Sum of all invoices."
  }

  measure: sum_of_total_company_ids {
    type: sum
    sql: ${total_company_ids} ;;
    description: "Sum of all Company IDs."
  }

  measure: sum_of_total_population {
    type: sum
    sql: ${total_population} ;;
    description: "Sum of total population."
  }

  measure: sum_of_total_oec {
    type: sum
    sql: ${total_oec} ;;
    value_format_name: usd
    description: "Sum of total oec."
  }

  measure: sum_of_headcount {
    type: sum
    sql: ${headcount} ;;
    description: "Sum of headcount."
  }

  measure: sum_of_open_requisitions {
    type: sum
    sql: ${open_reqs} ;;
    description: "Sum of headcount."
  }

  measure: sum_of_tam_shortage {
    type: sum
    sql: ${tam_shortage} ;;
    description: "Sum of TAM shortage."
  }

  measure: distinct_market_count {
    type: count_distinct
    sql: ${market_id} ;;
    description: "Distinct count of Market IDs."
  }
}


explore: tam_hiring_dashboard {
  sql_always_where: 'yes' = {{ _user_attributes['people_analytics_access'] }} OR
   (${tam_hiring_dashboard.district} in ({{ _user_attributes['district'] }})) OR (${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }})) OR (${tam_hiring_dashboard.market_id} in ({{ _user_attributes['market_id'] }}))
  OR (LOWER('{{ _user_attributes['email'] }}') = 'mark.wallace@equipmentshare.com')
   OR (LOWER('{{ _user_attributes['email'] }}') = 'ryan.lowe@equipmentshare.com')
   OR (LOWER('{{ _user_attributes['email'] }}') = 'jacob.neusch@equipmentshare.com')
  ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tam_hiring_dashboard.market_id}::varchar= ${market_region_xwalk.market_id}::varchar ;;
  }


}
