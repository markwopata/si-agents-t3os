view: ap_procurement_non_fleet_rebates {
  sql_table_name: "PROCURE_2_PAY"."AP_PROCUREMENT_NON_FLEET_REBATES" ;;

  dimension: active_flag {
    type: yesno
    sql: ${TABLE}."ACTIVE_FLAG" ;;
  }
  dimension: growth_amount {
    type: number
    sql: ${TABLE}."GROWTH_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: payment_frequency {
    type: string
    sql: ${TABLE}."PAYMENT_FREQUENCY" ;;
  }
  dimension: plan_year {
    type: string
    sql: ${TABLE}."PLAN_YEAR" ;;
  }
  dimension: plan_yr_q_four {
    type: number
    sql: ${TABLE}."PLAN_YR_Q_FOUR" ;;
    value_format: "$#,##0.00"
  }
  dimension: plan_yr_q_one {
    type: number
    sql: ${TABLE}."PLAN_YR_Q_ONE" ;;
    value_format: "$#,##0.00"
  }
  dimension: plan_yr_q_three {
    type: number
    sql: ${TABLE}."PLAN_YR_Q_THREE" ;;
    value_format: "$#,##0.00"
  }
  dimension: plan_yr_q_two {
    type: number
    sql: ${TABLE}."PLAN_YR_Q_TWO" ;;
    value_format: "$#,##0.00"
  }
  dimension: posting_year {
    type: string
    sql: ${TABLE}."POSTING_YEAR" ;;
  }
  dimension: prior_plan_year_q_four {
    type: number
    sql: ${TABLE}."PRIOR_PLAN_YEAR_Q_FOUR" ;;
    value_format: "$#,##0.00"
  }
  dimension: prior_plan_year_q_one {
    type: number
    sql: ${TABLE}."PRIOR_PLAN_YEAR_Q_ONE" ;;
    value_format: "$#,##0.00"
  }
  dimension: prior_plan_year_q_three {
    type: number
    sql: ${TABLE}."PRIOR_PLAN_YEAR_Q_THREE" ;;
    value_format: "$#,##0.00"
  }
  dimension: prior_plan_year_q_two {
    type: number
    sql: ${TABLE}."PRIOR_PLAN_YEAR_Q_TWO" ;;
    value_format: "$#,##0.00"
  }
  dimension: prior_posting_year {
    type: string
    sql: ${TABLE}."PRIOR_POSTING_YEAR" ;;
  }
  dimension: prior_posting_year_total_spend {
    type: number
    sql: ${TABLE}."PRIOR_POSTING_YEAR_TOTAL_SPEND" ;;
  }
  dimension: program_id {
    type: string
    sql: ${TABLE}."PROGRAM_ID" ;;
  }
  dimension: program_type {
    type: string
    sql: ${TABLE}."PROGRAM_TYPE" ;;
  }
  dimension: pseudo_code {
    type: string
    sql: ${TABLE}."PSEUDO_CODE" ;;
  }
  dimension: rebate_amount {
    type: number
    sql: ${TABLE}."REBATE_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: rebate_q_four_amount {
    type: number
    sql: ${TABLE}."REBATE_Q_FOUR_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: rebate_q_one_amount {
    type: number
    sql: ${TABLE}."REBATE_Q_ONE_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: rebate_q_three_amount {
    type: number
    sql: ${TABLE}."REBATE_Q_THREE_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: rebate_q_two_amount {
    type: number
    sql: ${TABLE}."REBATE_Q_TWO_AMOUNT" ;;
    value_format: "$#,##0.00"
  }
  dimension: threshold_logic {
    type: string
    sql: ${TABLE}."THRESHOLD_LOGIC" ;;
  }
  dimension: total_spend {
    type: number
    sql: ${TABLE}."TOTAL_SPEND" ;;
    value_format: "$#,##0.00"
  }
  dimension: total_units {
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [vendor_name]
  }
}
