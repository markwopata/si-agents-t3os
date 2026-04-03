view: full_year_profit_share_store_level_distributions_2023 {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."FULL_YEAR_PROFIT_SHARE_STORE_LEVEL_DISTRIBUTIONS_2023" ;;

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
    label: "All Other Store Level Position Annual Profit Share Amount"
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${total_profit_share_amount} - ${agm_sm_profit_share} ;;
  }

  dimension: date_last_hired {
    type: string
    sql: ${TABLE}."DATE_LAST_HIRED" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: eligibly_for_mulitplier {
    type: string
    sql: ${TABLE}."ELIGIBLY_FOR_MULITPLIER" ;;
  }

  dimension: employee_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
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

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employment_pro_rate {
    type: string
    value_format: "#,##0%;(#,##0%);-"
    sql: ${TABLE}."EMPLOYMENT_PRO_RATE" ;;
  }

  measure: employment_pro_rate_sum {
    label: "Pro-Rated Employment Duration %"
    type: sum
    value_format: "#,##0%;(#,##0%);-"
    sql: ${employment_pro_rate} ;;
  }

  dimension: employment_pro_rate_deduction {
    type: string
    sql: ${TABLE}."EMPLOYMENT_PRO_RATE_DEDUCTION" ;;
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

  dimension: market_id1 {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID1" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: months_open {
    type: string
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }

  dimension: quarter_timestamp {
    type: string
    sql: ${TABLE}."QUARTER_TIMESTAMP" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: total_profit_share_amount {
    type: number
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
    drill_fields: [market_name, last_name, first_name]
  }
}
