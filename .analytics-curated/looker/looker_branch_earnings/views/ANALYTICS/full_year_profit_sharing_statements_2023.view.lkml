view: full_year_profit_sharing_statements_2023 {
  derived_table: {
    sql: with total_by_ee as (
    select ID,
           sum(PROFIT_SHARE_MULTIPLIER_AMOUNT) as ps_ttl_by_ee,
           sum(DISCRETIONARY_EQUITY_AWARD) as equity_by_ee
    from ANALYTICS.GS.FULL_YEAR_PROFIT_SHARING_STATEMENTS_2023
    group by ID
    )
    select fy.*, ttl.ps_ttl_by_ee, ttl.equity_by_ee
    from ANALYTICS.GS.FULL_YEAR_PROFIT_SHARING_STATEMENTS_2023 fy
    left join total_by_ee ttl
      on fy.ID = ttl.ID;;
  }
  # sql_table_name: "GS"."FULL_YEAR_PROFIT_SHARING_STATEMENTS_2023" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
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
    type: max
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
    type: average
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL" = 0 then null else ${branch_greater_12_months_prorated} end ;;
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

  dimension: discretionary_equity_award {
    type: string
    sql: ${TABLE}."DISCRETIONARY_EQUITY_AWARD" ;;
  }

  measure: discretionary_equity_award_sum {
    label: "Discretionary Equity Award"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else ${discretionary_equity_award} end ;;
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

  dimension: employment_duration_eligibility_percent {
    type: number
    value_format: "#,##0%;(#,##0%);-"
    sql: ${TABLE}."EMPLOYMENT_DURATION_ELIGIBILITY_PERCENT" ;;
  }

  measure: employment_duration_eligibility_percent_sum {
    label: "Pro-Rated Employment Duration %"
    type: average
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL_PORTION" = 0 then null else ${employment_duration_eligibility_percent} end ;;
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
      url: "@{db_full_year_profit_sharing_statement_2023}?ID+Name={{ full_year_profit_sharing_statements_2023.id_name | url_encode }}&Profit+Share+Period={{ full_year_profit_sharing_statements_2023.quarter_timestamp | url_encode }}"
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

  dimension: months_open {
    label: "Months Open"
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: number_of_branches_in_pool {
    type: string
    sql: ${TABLE}."NUMBER_OF_BRANCHES_IN_POOL" ;;
  }

  measure: number_of_branches_in_pool_sum {
    label: "Number of Branches in Bonus Pool"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${TABLE}."BONUS_POOL" = 0 then null else ${number_of_branches_in_pool} end ;;
  }

  dimension: pk {
    hidden: yes
    type: number
    sql: ${TABLE}."PK" ;;
  }

  dimension: position_prorated_eligibility_percent {
    type: number
    value_format: "#,##0.00%;(#,##0.00%);-"
    sql: ${TABLE}."POSITION_PRORATED_ELIGIBILITY_PERCENT" ;;
  }

  measure: position_prorated_eligibility_percent_avg {
    type: average
    sql: ${position_prorated_eligibility_percent} ;;
  }

  measure: position_prorated_eligibility_percent_sum {
    label: "Pro-Rated Position Duration %"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."BONUS_POOL_PORTION" = 0 then null else ${position_prorated_eligibility_percent} end ;;
  }

  dimension: pro_rated_bonus_pool {
    type: string
    sql: ${TABLE}."PRO_RATED_BONUS_POOL" ;;
  }

  measure: pro_rated_bonus_pool_sum {
    label: "Pro-Rated Bonus Pool"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${pro_rated_bonus_pool} ;;
  }

  dimension: profit_share_multiplier_amount {
    type: string
    sql: ${TABLE}."PROFIT_SHARE_MULTIPLIER_AMOUNT" ;;
  }

  measure: profit_share_multiplier_amount_sum {
    label: "Total Profit Share Amount x Annual Multiplier"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else  ${profit_share_multiplier_amount} end ;;
  }

  measure: ps_ttl_by_ee {
    label: "Total Amount by Employee"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${TABLE}."PS_TTL_BY_EE" ;;
  }

  measure: equity_by_ee {
    label: "Total Equity by Employee"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}."EQUITY_BY_EE" ;;
  }

  dimension: profit_share_multiplier_percent {
    type: number
    sql: ${TABLE}."PROFIT_SHARE_MULTIPLIER_PERCENT" ;;
  }

  measure: profit_share_multiplier_percent_sum {
    label: "Profit Share Multiplier %"
    type: max
    value_format: "#,##0%;(#,##0%);-"
    sql: ${profit_share_multiplier_percent} ;;
  }

  dimension: quarter_timestamp {
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  dimension: quarters_in_position {
    type: string
    sql: ${TABLE}."QUARTERS_IN_POSITION" ;;
  }

  measure: quarters_in_position_sum {
    label: "Quarters in Position"
    type: sum
    sql: ${quarters_in_position} ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: twenty_four_pct_profit_share {
    type: string
    sql: ${TABLE}."TWENTY_FOUR_PCT_PROFIT_SHARE" ;;
  }

  measure: twenty_four_pct_profit_share_sum {
    label: "24% Profit Share Amount"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${twenty_four_pct_profit_share} ;;
  }

  dimension: cost_center {
    label: "Cost Center"
    type: string
    sql: case when ${market} is null and ${district} is null then ${region}
              when ${market} is null and ${district} is not null then ${district}
              when ${market} is not null then ${market} else null end;;
  }

  dimension: unopened_mkt_equipment_charge {
    type: string
    sql: ${TABLE}.unopened_mkt_equipment_charge ;;
  }

  measure: unopened_mkt_equipment_charge_sum {
    label: "Unopened Market Equipment Charge Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);$0"
    sql:  ${unopened_mkt_equipment_charge} ;;
  }

  measure: count {
    type: count
    drill_fields: [id, id_name]
  }
}
