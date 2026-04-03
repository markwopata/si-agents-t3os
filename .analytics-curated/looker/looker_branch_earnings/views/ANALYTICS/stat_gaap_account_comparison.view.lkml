view: stat_gaap_account_comparison {
  sql_table_name:  "BRANCH_EARNINGS"."STAT_GAAP_ACCOUNT_COMPARISON"
    ;;

  dimension: gl_month {
    type: date
    sql: ${TABLE}."GL_MONTH" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: sort_group {
    type: number
    sql: ${TABLE}."SORT_GROUP" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: revexp {
    type: string
    sql: ${TABLE}."REVEXP" ;;
  }

  dimension: account_map_id {
    type: string
    sql: ${TABLE}."ACCOUNT_MAP_ID" ;;
  }

  dimension: gaap_account_number {
    type: string
    sql: ${TABLE}."GAAP_ACCOUNT_NUMBER" ;;
  }

  dimension: gaap_account_name {
    type: string
    sql: ${TABLE}."GAAP_ACCOUNT_NAME" ;;
  }

  dimension: branch_earnings_account_number {
    type: string
    sql: ${TABLE}."BRANCH_EARNINGS_ACCOUNT_NUMBER" ;;
  }

  dimension: branch_earnings_account_name {
    type: string
    sql: ${TABLE}."BRANCH_EARNINGS_ACCOUNT_NAME" ;;
  }

  dimension: statistical_account_start_date {
    type: date
    sql: ${TABLE}."STATISTICAL_ACCOUNT_START_DATE" ;;
  }

  measure: gaap_amount {
    type: sum
    sql: ${TABLE}."GAAP_AMOUNT" ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: branch_earnings_amount {
    type: sum
    sql: ${TABLE}."BRANCH_EARNINGS_AMOUNT" ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: difference {
    type: number
    sql: coalesce(${branch_earnings_amount} - ${gaap_amount}, 0) ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }
}
