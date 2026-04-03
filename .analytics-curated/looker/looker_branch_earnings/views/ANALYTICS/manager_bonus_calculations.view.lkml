view: manager_bonus_calculations {
  sql_table_name: "ANALYTICS"."GS"."MANAGER_BONUS_CALCULATIONS"
    ;;
  drill_fields: [employee_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: employee_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ID" ;;
  }

  dimension: aggregate_net_income_markets_greater_12_months {
    type: number
    sql: ${TABLE}."AGGREGATE_NET_INCOME_MARKETS_GREATER_12_MONTHS" ;;
  }

  measure: aggregate_net_income_markets_greater_12_months_sum {
    label: "Annual Net Income Market >12 Months"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${aggregate_net_income_markets_greater_12_months} ;;
  }

  dimension: annual_bonus_amount {
    type: number
    sql: ${TABLE}."ANNUAL_BONUS_AMOUNT" ;;
  }

  measure: annual_bonus_amount_sum {
    label: "Annual Bonus Amount * Employment Duration"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${annual_bonus_amount} ;;
  }

  measure: annual_multiplier {
    label: "Annual Multiplier"
    type: number
    value_format: "0\%"
    sql: 0 ;;
  }

  measure: annual_bonus_amount_with_multiplier {
    label: "Total Annual Bonus Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${annual_bonus_amount} * 1 ;;
  }

  measure: total_annual_bonus_amount {
    label: "Total Annual Bonus"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${annual_bonus_amount} ;;
  }

  dimension: annual_bonus_eligibility_percent {
    type: number
    value_format: "0\%"
    sql: ${TABLE}."ANNUAL_BONUS_ELIGIBILITY_PERCENT" ;;
  }

  measure: annual_bonus_eligibility_percent_sum {
    label: "% of Annual Bonus Eligible for Based on Employment Duration"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${annual_bonus_eligibility_percent} ;;
  }

  dimension: bonus_pool {
    type: number
    sql: ${TABLE}."BONUS_POOL" ;;
  }

  measure: bonus_pool_sum {
    label: "Bonus Pool"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${bonus_pool} ;;
  }

  dimension: bonus_pool_bonus_percentage {
    type: number
    sql: ${TABLE}."BONUS_POOL_BONUS_PERCENTAGE" ;;
  }

  measure: bonus_pool_bonus_percentage_sum {
    label: "Bonus Pool Bonus Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${bonus_pool_bonus_percentage} ;;
  }

  dimension: branch_bonus_pool_portion {
    type: string
    sql: ${TABLE}."BRANCH_BONUS_POOL_PORTION" ;;
  }

  measure: branch_bonus_pool_portion_sum {
    label: "Branch Portion of Bonus Pool"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${branch_bonus_pool_portion} ;;
  }

  dimension: branches_greater_12_months_prorated {
    type: number
    sql: ${TABLE}."BRANCHES_GREATER_12_MONTHS_PRORATED" ;;
  }

  measure: branches_greater_12_months_prorated_sum {
    label: "Annual Bonus Eligibility Percent - Pro-Rated Based on Branch Age >12 Months"
    type: sum
    #value_format: "0.00\%"
    value_format: "#,##0%;(#,##0%);-"
    sql: ${branches_greater_12_months_prorated} ;;
  }

  dimension: branches_greater_12_months_in_district {
    type: string
    sql: ${TABLE}."BRANCHES_GREATER_12_MONTHS_IN_DISTRICT" ;;
  }

  measure: branches_greater_12_months_in_district_sum {
    label: "Number of Branches in District >12 Months"
    type: sum
    sql: ${branches_greater_12_months_in_district} ;;
  }

  dimension: branch_greater_12_month_net_income {
    type: number
    sql: ${TABLE}."BRANCH_GREATER_12_MONTH_NET_INCOME" ;;
  }

  measure: branch_greater_12_month_net_income_sum {
    label: "Annual Branch >12 Months Net Income"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${branch_greater_12_month_net_income} ;;
  }

  dimension: eligible_for_annual_bonus {
    type: number
    sql: ${TABLE}."ELIGIBLE_FOR_ANNUAL_BONUS" ;;
  }

  measure: eligible_for_annual_bonus_measure {
    label: "Eligible for Annual  Bonus?"
    type: sum
    value_format: "#,##0%;(#,##0%)"
    sql: ${eligible_for_annual_bonus} ;;

  }

 # html: {% if value == 'No' %}
#  <p style="text-align:center">{{ rendered_value }}</p>
 # {% else %}
  #<p style="text-align:center">{{ rendered_value }}</p>
  #{% endif %};;

  dimension: classification {
    type: string
    sql: ${TABLE}."CLASSIFICATION" ;;
  }

  dimension: date_hired {
    type: string
    sql: to_varchar(${TABLE}."DATE_HIRED"::date, 'MMMM yyyy') ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: eligible_annual_collected_rev {
    type: number
    sql: ${TABLE}."ELIGIBLE_ANNUAL_COLLECTED_REV" ;;
  }

  measure: eligible_annual_collected_rev_sum {
    label: "Eligible Annual Collected Revenue"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${eligible_annual_collected_rev} ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: greater_12_month_actual_bonus {
    type: number
    sql: ${TABLE}."GREATER_12_MONTH_ACTUAL_BONUS" ;;
  }

  measure: greater_12_month_actual_bonus_sum {
    label: ">12 Months Bonus Subtotal"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${greater_12_month_actual_bonus} ;;
  }

  dimension: greater_12_month_net_income {
    type: number
    sql: ${TABLE}."GREATER_12_MONTH_NET_INCOME" ;;
  }

  measure: greater_12_month_net_income_sum {
    label: ">12 Months Net Income"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${greater_12_month_net_income} ;;
  }

  dimension: greater_12_month_net_income_bonus_percentage {
    type: number
    sql: ${TABLE}."GREATER_12_MONTH_NET_INCOME_BONUS_PERCENTAGE" ;;
  }

  measure: greater_12_month_net_income_bonus_percentage_sum {
    label: ">12 Months Net Income Bonus Percentage"
    type: sum
#    value_format: "0.00\%;-"
    value_format: "#,##0.00%;(#,##0.00%);-"
    #sql: ${greater_12_month_net_income_bonus_percentage} ;;
    sql: case when ${TABLE}."GREATER_12_MONTH_NET_INCOME" = 0 then null else ${greater_12_month_net_income_bonus_percentage} end ;;
  }

  dimension: id_name {
    type: string
    sql: ${TABLE}."ID_NAME" ;;
  }

  dimension: id_name_statement_link {
    label: "ID Name - Link to Individual Statement"
    type: string
    link: {
      label: "Statement"
      url: "@{db_manager_bonus_detail}?ID+Name={{ manager_bonus_calculations.id_name | url_encode }}"
      }
    sql:  ${TABLE}."ID_NAME" ;;
  }

  dimension: less_12_month_rev_goal {
    type: string
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL" ;;
  }

  dimension: less_12_month_rev_goal_actual_bonus {
    type: number
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL_ACTUAL_BONUS" ;;
  }

  measure: less_12_month_rev_goal_actual_bonus_sum {
    label: "<12 Month Revenue Goal Actual Bonus"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${less_12_month_rev_goal_actual_bonus} ;;
  }

  dimension: less_12_month_rev_goal_bonus_percentage {
    type: number
    value_format: "0.00\%;-"
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL_BONUS_PERCENTAGE" ;;
  }

  measure: less_12_month_rev_goal_bonus_percentage_sum {
    label: "<12 Months Revenue Goal Bonus Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${less_12_month_rev_goal_bonus_percentage} ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: month_12_net_income {
    type: string
    sql: ${TABLE}."MONTH_12_NET_INCOME" ;;
  }

  measure: month_12_net_income_sum {
    label: "Month 12 Net Income"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${month_12_net_income} ;;
  }

  dimension: month_12_net_income_actual_bonus {
    type: string
    sql: ${TABLE}."MONTH_12_NET_INCOME_ACTUAL_BONUS" ;;
  }

  measure: month_12_net_income_actual_bonus_sum {
    label: "Month 12 Net Income Bonus Subtotal"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${month_12_net_income_actual_bonus} ;;
  }

  dimension: month_12_net_income_bonus_percentage {
    type: string
    value_format: "#,##0%;(#,##0%);-"
    sql: ${TABLE}."MONTH_12_NET_INCOME_BONUS_PERCENTAGE" ;;
  }

  measure: month_12_net_income_bonus_percentage_sum {
    label: "Month 12 Net Income Bonus Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."MONTH_12_NET_INCOME" = 0 then null else ${month_12_net_income_bonus_percentage} end ;;
    #sql: ${month_12_net_income_bonus_percentage}*100 ;;
  }

  dimension: months_open {
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: quarterly_collected_rev {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV" ;;
  }

  measure: quarterly_collected_rev_sum {
    label: "Quarterly Collected Revenue"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_rev} ;;
  }

  dimension: quarterly_collected_rev_actual_bonus {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_ACTUAL_BONUS" ;;
  }

  measure: quarterly_collected_rev_actual_bonus_sum {
    label: "Quarterly Collected Revenue Bonus Subtotal"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_rev_actual_bonus} ;;
  }

  dimension: quarterly_collected_rev_bonus_percentage {
    type: string
    value_format: "0.00\%;-"
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_BONUS_PERCENTAGE" ;;
  }

  measure: quarterly_collected_rev_bonus_percentage_sum {
    label: "Quarterly Collected Revenue Bonus Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${quarterly_collected_rev_bonus_percentage}*100 ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: total_bonus_amount {
    type: number
    sql: ${TABLE}."TOTAL_BONUS_AMOUNT" ;;
  }

  measure: total_bonus_amount_sum {
    label: "Total Bonus Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${total_bonus_amount} ;;
  }

  dimension: total_quarterly_bonus {
    type: number
    sql: ${TABLE}."TOTAL_QUARTERLY_BONUS" ;;
  }

  measure: total_quarterly_bonus_sum {
    label: "Total Quarterly Bonus (Sum of all Subtotals)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${total_quarterly_bonus} ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_id, id_name]
  }
}
