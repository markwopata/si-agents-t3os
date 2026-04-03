view: full_year_profit_share_store_level_distributions {
  sql_table_name: "ANALYTICS"."GS"."FULL_YEAR_PROFIT_SHARE_STORE_LEVEL_DISTRIBUTIONS"
    ;;

  dimension: actual_profit_share_payments {
    type: number
    sql: ${TABLE}."ACTUAL_PROFIT_SHARE_PAYMENTS" ;;
  }

  dimension: agm_sm_profit_share {
    type: number
    sql: ${TABLE}."AGM_SM_PROFIT_SHARE" ;;
  }

  measure: agm_sm_profit_share_sum {
    label: "Assisstant General Manager Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${agm_sm_profit_share} ;;
  }

  dimension: all_other_profit_shares {
    type: number
    sql: ${TABLE}."ALL_OTHER_PROFIT_SHARES" ;;
  }

  measure: all_other_profit_shares_sum {
    label: "All Other Store Level Position Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${all_other_profit_shares} ;;
  }

  dimension: date_last_hired {
    label: "Date Hired"
    type: string
    sql: ${TABLE}."DATE_LAST_HIRED" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: eligibly_for_mulitplier {
    type: string
    sql: ${TABLE}."ELIGIBLY_FOR_MULITPLIER" ;;
  }

  dimension: historical_payments {
    type: string
    sql: ${TABLE}."ACTUAL_PROFIT_SHARE_PAYMENTS" ;;
  }

  measure: multiplier_amount {
    label: "Profit Share Multiplier Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${historical_payments} ;;
  }

  dimension: employee_id {
    primary_key: yes
    label: "Employee ID"
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gm_discretionary_adjustment {
    type: string
    sql: ${TABLE}."GM_DISCRETIONARY_ADJUSTMENT" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: full_name {
    label: "Full Name"
    type: string
    sql: ${first_name}||' '||${last_name} ;;
  }

  dimension: id_name {
    label: "ID Name"
    type: string
    sql: ${employee_id}||' - '||${full_name} ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID1" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: months_open {
    label: "Months Open"
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: quarter_timestamp {
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  dimension: region {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: total_profit_share_amount {
    type: string
    sql: ${TABLE}."TOTAL_PROFIT_SHARE_AMOUNT" ;;
  }

  measure: total_profit_share_amount_sum {
    label: "Total Annual Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${total_profit_share_amount} ;;
  }

  dimension: total_store_profit_share {
    type: number
    sql: ${TABLE}."TOTAL_STORE_PROFIT_SHARE" ;;
  }

  measure: total_store_profit_share_sum {
    label: "Total Test"
    type: sum
    sql: ${total_store_profit_share} ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  measure: count {
    type: count
    drill_fields: [last_name, first_name, market_name]
  }
}
