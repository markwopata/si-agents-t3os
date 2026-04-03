view: full_year_profit_sharing_statements {
  sql_table_name: "GS"."FULL_YEAR_PROFIT_SHARING_STATEMENTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: months_open {
    label: "Months Open"
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: actual_profit_share_payments {
    type: string
    sql: ${TABLE}."ACTUAL_PROFIT_SHARE_PAYMENTS" ;;
  }

  measure: actual_profit_share_payments_sum {
    label: "Historical Profit Share Payments"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: case when ${TABLE}."BONUS_POOL" = 0 then null else ${actual_profit_share_payments} end;;
  }

  dimension: agg_greater_12_month_net_income {
    type: string
    sql: ${TABLE}."AGG_GREATER_12_MONTH_NET_INCOME" ;;
  }

  measure: agg_greater_12_month_net_income_sum {
    label: "Annual >12 Month Net Income (District for GM/DM; Region for RM)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else ${agg_greater_12_month_net_income} end ;;
  }

  dimension: annual_profit_share_amount {
    type: string
    sql: ${TABLE}."ANNUAL_PROFIT_SHARE_AMOUNT" ;;
  }

  measure: annual_profit_share_amount_sum {
    label: "Annual Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${annual_profit_share_amount} ;;
  }

  dimension: bonus_pool {
    type: string
    sql: ${TABLE}."BONUS_POOL" ;;
  }

  measure: bonus_pool_sum {
    label: "Bonus Pool"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${bonus_pool} ;;
  }

  dimension: bonus_pool_portion {
    type: string
    sql: ${TABLE}."BONUS_POOL_PORTION" ;;
  }

  measure: bonus_pool_portion_sum {
    label: "Eligible Bonus Pool Portion"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${bonus_pool_portion} ;;
  }

  dimension: bonus_pool_portion_profit_share_percent {
    type: string
    sql: ${TABLE}."BONUS_POOL_PORTION_PROFIT_SHARE_PERCENT" ;;
  }

  measure: bonus_pool_portion_profit_share_percent_sum {
    label: "Bonus Pool Portion Profit Share Percent"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL_PORTION" <= 0 then null else ${bonus_pool_portion_profit_share_percent} end;;
  }

  dimension: branch_greater_12_month_net_income {
    type: string
    sql: ${TABLE}."BRANCH_GREATER_12_MONTH_NET_INCOME" ;;
  }

  measure: branch_greater_12_month_net_income_sum {
    label: "Branch >12 Month Net Income (GM Only)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else ${branch_greater_12_month_net_income} end ;;
  }

  dimension: branch_greater_12_months_prorated {
    type: string
    sql: ${TABLE}."BRANCH_GREATER_12_MONTHS_PRORATED" ;;
  }

  measure: branch_greater_12_months_prorated_percent {
    label: "Annual Branch Eligibility Percent - Pro-Rated Based on Branch Age >12 Months (GM Only)"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL" = 0 then null else ${branch_greater_12_months_prorated} end ;;
  }

  dimension: branch_net_income_profit_share {
    type: string
    sql: ${TABLE}."BRANCH_NET_INCOME_PROFIT_SHARE" ;;
  }

  measure: branch_net_income_profit_share_sum {
    label: "Branch Net Income Profit Share"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${branch_net_income_profit_share} ;;
  }

  dimension: branch_net_income_profit_share_percent {
    type: string
    sql: ${TABLE}."BRANCH_NET_INCOME_PROFIT_SHARE_PERCENT" ;;
  }

  measure: branch_net_income_profit_share_percent_sum {
    label: "Branch Net Income Profit Share %"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${branch_net_income_profit_share_percent} ;;
  }

  dimension: classification {
    label: "Classification"
    type: string
    sql: ${TABLE}."CLASSIFICATION" ;;
  }

  dimension: date_hired {
    label: "Date Hired"
    type: string
    sql: to_varchar(${TABLE}."DATE_HIRED"::date, 'MMMM yyyy') ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: eligible_annual_collected_rev {
    type: string
    sql: ${TABLE}."ELIGIBLE_ANNUAL_COLLECTED_REV" ;;
  }

  measure: eligible_annual_collected_rev_sum {
    label: "Eligible Annual Collected Revenue (District for GM/DM; Region for RM)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else  ${eligible_annual_collected_rev} end ;;
  }

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: id_name {
    label: "ID Name"
    type: string
    sql: ${TABLE}."ID_NAME" ;;
  }

  dimension: id_name_statement_link {
    label: "ID Name - Link to Individual Statement"
    type: string
    link: {
      label: "Statement"
      url: "@{db_full_year_profit_sharing_statement}?ID+Name={{ full_year_profit_sharing_statements.id_name | url_encode }}&Profit+Share+Period={{ full_year_profit_sharing_statements.quarter_timestamp | url_encode }}"
    }
    sql:  ${TABLE}."ID_NAME" ;;
  }

  dimension: market {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: number_of_branches_in_pool {
    label: "Number of Eligible Branches in Pool"
    type: string
    sql: ${TABLE}."NUMBER_OF_BRANCHES_IN_POOL" ;;
  }

  measure: number_of_branches_in_pool_sum {
    label: "Number of Branches in Bonus Pool"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${TABLE}."BONUS_POOL" = 0 then null else ${number_of_branches_in_pool} end ;;
  }

  measure: profit_share_multiplier_amount{
    label: "Profit Share Multiplier Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: (${TABLE}."ANNUAL_PROFIT_SHARE_AMOUNT" + ${TABLE}."ACTUAL_PROFIT_SHARE_PAYMENTS") * ${TABLE}."PROFIT_SHARE_MULTIPLIER_PERCENT" ;;
  }

  dimension: total_annual_profit_share_amount{
    type: string
    sql: ${TABLE}."PROFIT_SHARE_MULTIPLIER_AMOUNT" ;;
  }

  measure: total_annual_profit_share_amount_sum {
    label: "Total Annual Amount (Multiplier % x Historical Payments + Annual Payment) x Employment Duration %"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);$0"
    sql: ${total_annual_profit_share_amount} ;;
  }

  dimension: profit_share_multiplier_percent {
    type: number
    sql: ${TABLE}."PROFIT_SHARE_MULTIPLIER_PERCENT" ;;
  }

  measure: profit_share_multiplier_percent_sum {
    label: "Profit Share Multiplier %"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${profit_share_multiplier_percent} ;;
  }

  dimension: prorated_employment_duration_percent {
    type: string
    sql: ${TABLE}."PRORATED_EMPLOYMENT_DURATION_PERCENT" ;;
  }

  measure: prorated_employment_duration_percent_sum {
    label: "Pro-Rated Employment Duration %"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL_PORTION" = 0 then null else ${prorated_employment_duration_percent} end ;;
  }

  dimension: quarter_timestamp {
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  # dimension: timestamp_filter {
  #   type: string
  #   sql: (select distinct quarter_timestamp as timestamp from "ANALYTICS"."GS"."PROFIT_SHARING_STATEMENTS" as ps) union
  #       (select distinct quarter_timestamp as timestamp from "ANALYTICS"."GS"."FULL_YEAR_PROFIT_SHARING_STATEMENTS" as fps) ;;
  # }

  dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, id_name]
  }
}
