view: profit_share_store_level_distributions {
  sql_table_name: "ANALYTICS"."GS"."PROFIT_SHARE_STORE_LEVEL_DISTRIBUTIONS"
    ;;

  dimension: agm_sm_profit_share {
    label: "Assisstant General Manager Profit Share"
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
    label: "All Other Profit Shares"
    type: number
    sql: ${TABLE}."ALL_OTHER_PROFIT_SHARES" ;;
  }

  measure: all_other_profit_shares_sum {
    label: "All Other Store Level Position Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${all_other_profit_shares} ;;
  }

  dimension: date_hired {
    label: "Date Hired"
    type: number
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: employee_id {
    primary_key: yes
    label: "Employee ID"
    type: string
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
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
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

  dimension: region {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: total_profit_share_amount {
    type: number
    sql: ${TABLE}."TOTAL_PROFIT_SHARE_AMOUNT" ;;
  }

  measure: total_profit_share_amount_sum {
    label: "Total Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${total_profit_share_amount} ;;
  }

  dimension: total_store_profit_share {
    type: number
    sql: ${TABLE}."TOTAL_STORE_PROFIT_SHARE" ;;
  }

  dimension: type {
    label: "Profit Share Eligibility Type"
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: work_email {
    label: "Work Email"
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: quarter_timestamp {
    label: "Quarter Timestamp"
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name, market_name]
  }
}
