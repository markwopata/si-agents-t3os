view: profit_sharing_statements {
  sql_table_name: "ANALYTICS"."GS"."PROFIT_SHARING_STATEMENTS"
    ;;

  dimension: id {
    primary_key: yes
    label: "Employee ID"
    type: string
    sql: ${TABLE}."ID" ;;
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

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: greater_12_month_actual_profit_share {
    type: string
    sql: ${TABLE}."GREATER_12_MONTH_ACTUAL_PROFIT_SHARE" ;;
  }

  measure: greater_12_month_actual_profit_share_sum {
    label: ">12 Months Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${greater_12_month_actual_profit_share} ;;
  }

  dimension: greater_12_month_net_income {
    type: string
    sql: ${TABLE}."GREATER_12_MONTH_NET_INCOME" ;;
  }

  measure: greater_12_month_net_income_sum {
    label: ">12 Months Net Income"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${greater_12_month_net_income} ;;
  }

  dimension: greater_12_month_net_income_profit_share_percentage {
    type: string
    sql: ${TABLE}."GREATER_12_MONTH_NET_INCOME_PROFIT_SHARE_PERCENTAGE" ;;
  }

  measure: greater_12_month_net_income_profit_share_percentage_sum {
    label: ">12 Months Net Income Profit Share Percent"
    type: sum
    value_format: "#,##0.00%;(#,##0.00%);-"
    sql: case when ${TABLE}."MONTHS_OPEN" <= 12 then null else ${greater_12_month_net_income_profit_share_percentage} end ;;
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
      url: "@{db_profit_sharing_statement}?ID+Name={{ profit_sharing_statements.id_name | url_encode }}&Profit+Share+Period={{ profit_sharing_statements.quarter_timestamp | url_encode }}"
    }
    sql:  ${TABLE}."ID_NAME" ;;
  }

  dimension: less_12_month_rev_goal {
    type: string
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL" ;;
  }

  measure: less_12_month_rev_goal_sum {
    label: "<12 Month Revenue Goal"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${less_12_month_rev_goal} ;;
  }

  dimension: less_12_month_rev_goal_actual_profit_share {
    type: string
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL_ACTUAL_PROFIT_SHARE" ;;
  }

  measure: less_12_month_rev_goal_actual_profit_share_sum {
    label: "<12 Month Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${less_12_month_rev_goal_actual_profit_share} ;;
  }

  dimension: less_12_month_rev_goal_profit_share_percentage {
    type: string
    sql: ${TABLE}."LESS_12_MONTH_REV_GOAL_PROFIT_SHARE_PERCENTAGE" ;;
  }

  measure: less_12_month_rev_goal_profit_share_percentage_sum {
    label: "<12 Month Revenue Goal Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${greater_12_month_net_income_profit_share_percentage} ;;
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

  dimension: month_12_net_income_actual_profit_share {
    type: string
    sql: ${TABLE}."MONTH_12_NET_INCOME_ACTUAL_PROFIT_SHARE" ;;
  }

  measure: month_12_net_income_actual_profit_share_sum {
    label: "Month 12 Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${month_12_net_income_actual_profit_share} ;;
  }

  dimension: month_12_net_income_profit_share_percentage {
    type: string
    sql: ${TABLE}."MONTH_12_NET_INCOME_PROFIT_SHARE_PERCENTAGE" ;;
  }

  measure: month_12_net_income_profit_share_percentage_sum {
    label: "Month 12 Net Income Profit Share Percentage"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: case when ${TABLE}."MONTH_12_NET_INCOME" = 0 then null else ${month_12_net_income_profit_share_percentage} end ;;
  }

  dimension: months_open {
    label: "Months Open"
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: quarter_timestamp {
    label: "Quarter Timestamp"
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  dimension: quarterly_collected_rev {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV" ;;
  }

  measure: quarterly_collected_rev_sum {
    label: "Quarterly Collected Revenue At or Above Benchmark"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_rev} ;;
  }

  dimension: quarterly_collected_rev_actual_profit_share {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_ACTUAL_PROFIT_SHARE" ;;
  }

  measure: quarterly_collected_rev_actual_profit_share_sum {
    label: "Quarterly Collected Revenue At of Above Benchmark Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_rev_actual_profit_share} ;;
  }

  dimension: quarterly_collected_rev_profit_share_percentage {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_PROFIT_SHARE_PERCENTAGE" ;;
  }

  measure: quarterly_collected_rev_profit_share_percentage_sum {
    label: "Quarterly Collected Revenue At or Above Benchmark Profit Share Percentage"
    type: sum
    value_format: "#,##0.00%;(#,##0.00%);-"
    sql: ${quarterly_collected_rev_profit_share_percentage} ;;
  }

  dimension: quarterly_collected_revenue_between_floor_and_bench {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REVENUE_BETWEEN_FLOOR_AND_BENCH" ;;
  }

  measure: quarterly_collected_revenue_between_floor_and_bench_sum {
    label: "Quarterly Collected Revenue At or Above Floor and Below Benchmark"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_revenue_between_floor_and_bench} ;;
  }

  dimension: quarterly_collected_rev_between_floor_and_bench_actual_profit_share {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_BETWEEN_FLOOR_AND_BENCH_ACTUAL_PROFIT_SHARE" ;;
  }

  measure: quarterly_collected_rev_between_floor_and_bench_actual_profit_share_sum {
    label: "Quarterly Collected Revenue At or Above Floor and Below Benchmark Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${quarterly_collected_rev_between_floor_and_bench_actual_profit_share} ;;
  }

  dimension: quarterly_collected_rev_between_floor_and_bench_profit_share_percentage {
    type: string
    sql: ${TABLE}."QUARTERLY_COLLECTED_REV_BETWEEN_FLOOR_AND_BENCH_PROFIT_SHARE_PERCENTAGE" ;;
  }

  measure: quarterly_collected_rev_between_floor_and_bench_profit_share_percentage_sum {
    label: "Quarterly Collected Revenue At or Above Floor and Below Benchmark Profit Share Percentage"
    type: sum
    value_format: "#,##0.00%;(#,##0.00%);-"
    sql: ${quarterly_collected_rev_between_floor_and_bench_profit_share_percentage} ;;
  }

  dimension: region {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: total_quarterly_profit_share {
    type: string
    sql: ${TABLE}."TOTAL_QUARTERLY_PROFIT_SHARE" ;;
  }

  measure: total_quarterly_profit_share_sum {
    label: "Total Quarterly Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);$0"
    sql: ${total_quarterly_profit_share} ;;
  }

  measure: total_quarterly_profit_share_sum_extra {
    label: "Total Quarterly Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);$0"
    sql: ${total_quarterly_profit_share} + ${q4_2023_profit_sharing_24_pct_bench_diff.total_quarterly_profit_share} ;;
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

  dimension: unopened_mkt_equipment_charge_profit_share_amount {
    type: string
    sql: ${TABLE}.unopened_mkt_equipment_charge_profit_share_amount ;;
  }

  measure: unopened_mkt_equipment_charge_percent {
    label: "Unopened Market Equipment Charge Deduction Percent"
    type: sum
    value_format: "#,##0.00%;(#,##0.00%);-"
    sql: case when ${TABLE}."CLASSIFICATION" in ('Store Managers','Service Manager') then null else ${greater_12_month_net_income_profit_share_percentage} end ;;
  }

  measure: unopened_mkt_equipment_charge_profit_share_amount_sum {
    label: "Unopened Market Equipment Charge Profit Sharing Deduction"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);$0"
    sql: ${unopened_mkt_equipment_charge_profit_share_amount};;
  }

  measure: count {
    type: count
    drill_fields: [id, id_name]
  }

}
