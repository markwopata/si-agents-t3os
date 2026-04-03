
view: revenue_monthly_insights {
  sql_table_name: analytics.bi_ops.monthly_in_out_rev_totals ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date_month {
    type: time
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: sp_user_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: salesperson {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: current_status {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension: start_month {
    group_label: "Sales Rep Info"
    type: date
    sql: ${TABLE}."START_MONTH" ;;
  }

  dimension: last_month {
    group_label: "Sales Rep Info"
    type: date
    sql: ${TABLE}."LAST_MONTH" ;;
  }

  dimension: jurisdiction {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."JURISDICTION" ;;
  }

  dimension: sp_market_id {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SP_MARKET_ID" ;;
  }

  dimension: sp_market {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."SP_MARKET" ;;
  }

  dimension: current_location {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."CURRENT_HOME" ;;
  }

  dimension: rep {
    group_label: "Sales Rep Info"
    label: "Rep - Market"
    type:  string
    sql: concat(${name}, ' - ', ${sp_market}) ;;
  }

  dimension: rep_current_location {
    group_label: "Sales Rep Info"
    label: "Rep - Current Location"
    type:  string
    sql: concat(${name}, ' - ', ${current_location}) ;;
  }


  dimension: district {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_dated {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION_DATED" ;;
  }

  dimension: region_name {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    group_label: "Sales Rep Info"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: in_market_rev_monthly_pb {
    type: number
    sql: ${TABLE}."IN_MARKET_REV_MONTHLY_PB" ;;
    value_format_name: usd_0
  }

  dimension: total_rev_monthly_pb {
    type: number
    sql: ${TABLE}."TOTAL_REV_MONTHLY_PB" ;;
    value_format_name: usd_0
  }

  dimension: in_market_total_rev_pb_max {
    type: number
    sql: ${TABLE}."IN_MARKET_TOTAL_REV_PB_MAX" ;;
    value_format_name: usd_0
  }

  dimension: total_rev_pb_max {
    type: number
    sql: ${TABLE}."TOTAL_REV_PB_MAX" ;;
    value_format_name: usd_0
  }

  dimension: current_month_flag {
    type: yesno
    sql:  CASE WHEN ${date_month_date} = date_trunc(month, current_date) THEN TRUE ELSE FALSE END ;;
  }


  measure: total_rev_monthly_pb_sum {
    type: sum
    sql: ${total_rev_monthly_pb};;
    value_format_name: usd_0
  }

  measure: in_market_total_rev_pb_max_sum {
    type: number
    sql: ${in_market_total_rev_pb_max};;
    value_format_name: usd_0
  }

  measure: total_rev_pb_max_sum {
    type: sum
    sql: ${total_rev_pb_max};;
    value_format_name: usd_0
  }

  dimension: in_market_rev {
    type: number
    sql: ${TABLE}."IN_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: in_market_sum {
    type: sum
    sql:  ${in_market_rev} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: in_market_total {
    type: sum
    sql:  ${in_market_rev} ;;
    value_format_name: usd_0
  }

  dimension: out_market_rev {
    type: number
    sql: ${TABLE}."OUT_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: out_market_sum {
    type: sum
    sql:  ${out_market_rev} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: no_sp_market_rev {
    type: number
    sql: ${TABLE}."NO_SP_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: no_sp_market_sum {
    type: sum
    sql:  ${no_sp_market_rev} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }


  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV" ;;
    value_format_name: usd_0
  }

  measure: total_rev_sum {
    type: sum
    sql:  ${total_rev} ;;
    value_format_name: usd_0
  }

  measure: total_rev_pb_check {
    type: number
    sql: CASE WHEN  ${total_rev_sum} < ${total_rev_monthly_pb_sum}
          THEN ${total_rev_sum} ELSE 0 END;;
    value_format_name: usd_0
  }
  measure: total_rev_sum_check {
    type: number
    sql: CASE WHEN  (${total_rev_sum} = ${total_rev_monthly_pb_sum}) AND (${total_rev_sum} < ${total_rev_pb_max_sum})
          THEN ${total_rev_monthly_pb_sum} ELSE 0 END;;
    value_format_name: usd_0
  }

  measure: total_rev_max_sum_check {
    type: number
    sql: CASE WHEN  (${total_rev_sum} = ${total_rev_monthly_pb_sum}) AND (${total_rev_sum} = ${total_rev_pb_max_sum})
          THEN ${total_rev_pb_max_sum} ELSE 0 END;;
    value_format_name: usd_0
  }

  dimension: in_market_prct {
    type: number
    sql: ${TABLE}."IN_MARKET_PRCT" ;;
    value_format_name: percent_2
  }

  measure: in_market_percent {
    type: average
    sql: ${in_market_prct} ;;
    value_format_name: percent_2
  }

  dimension: in_market_rev_incr_flag {
    type: yesno
    sql: ${TABLE}."IN_MARKET_REV_INCR_FLAG" ;;
  }

  dimension: total_rev_incr_flag {
    type: yesno
    sql: ${TABLE}."TOTAL_REV_INCR_FLAG" ;;
  }

  dimension: in_market_prct_incr_flag {
    type: yesno
    sql: ${TABLE}."IN_MARKET_PRCT_INCR_FLAG" ;;
  }

  dimension: rolling_avg_in_market_rev {
    type: number
    sql: ${TABLE}."ROLLING_AVG_IN_MARKET_REV" ;;
    value_format_name: usd_0
  }

  measure: rolling_avg_in_market_rev_num {
    type: sum
    description: "Rolling three-month average of monthly in-market revenue"
    sql:  ${rolling_avg_in_market_rev} ;;
    value_format_name: usd_0
  }

  dimension: rolling_avg_total_rev {
    type: number
    sql: ${TABLE}."ROLLING_AVG_TOTAL_REV" ;;
    value_format_name: usd_0
  }

  measure: rolling_avg_total_rev_num {
    type: sum
    description: "Rolling three-month average of monthly total revenue"
    sql:  ${rolling_avg_total_rev} ;;
    value_format_name: usd_0
  }

  dimension: in_market_rev_monthly_prct_change {
    type: number
    sql: ${TABLE}."IN_MARKET_REV_MONTHLY_PRCT_CHANGE" ;;
  }

  measure: in_market_rev_monthly_prct_change_num {
    type: number
    description: "Percent change of in market revenue between current and previous month"
    sql:  ${in_market_rev_monthly_prct_change} ;;
    value_format_name: percent_1
  }

  dimension: total_rev_monthly_prct_change {
    type: number
    sql: ${TABLE}."TOTAL_REV_MONTHLY_PRCT_CHANGE" ;;
  }

  measure: total_rev_monthly_prct_change_num {
    type: number
    description: "Percent change of total revenue between current and previous month"
    sql:  ${total_rev_monthly_prct_change} ;;
    value_format_name: percent_1
  }

  dimension: current_monthly_rev_goal {
    type: number
    sql: ${TABLE}."CURRENT_MONTHLY_REV_GOAL" ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: current_monthly_rev_goal_sum {
    type:  sum
    sql: ${current_monthly_rev_goal} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: current_in_market_monthly_revenue_goal {
    type: number
    sql: ${TABLE}."CURRENT_IN_MARKET_MONTHLY_REVENUE_GOAL" ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: current_in_market_monthly_revenue_goal_sum {
    type:  sum
    sql: ${current_in_market_monthly_revenue_goal} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: current_out_market_monthly_revenue_goal {
    type: number
    sql: ${TABLE}."CURRENT_OUT_MARKET_MONTHLY_REVENUE_GOAL" ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: current_out_market_monthly_revenue_goal_sum {
    type:  sum
    sql: ${current_out_market_monthly_revenue_goal} ;;
    value_format_name: usd_0
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: total_rev_goal_met_sum {
    type: number
    sql: CASE WHEN SUM(${current_monthly_rev_goal}) IS NULL THEN NULL
              WHEN ${current_monthly_rev_goal_sum} - ${total_rev_sum} <= 0 THEN ${total_rev_sum} ELSE NULL END  ;;
    value_format_name: usd_0
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: total_rev_goal_unmet_sum {
    type: number
    sql: CASE WHEN SUM(${current_monthly_rev_goal}) IS NULL THEN NULL
              WHEN ${current_monthly_rev_goal_sum} - ${total_rev_sum} > 0 THEN ${total_rev_sum} ELSE NULL END  ;;
    value_format_name: usd_0
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: total_rev_no_goal_sum {
    type: number
    sql: CASE WHEN SUM(${current_monthly_rev_goal}) IS NULL THEN ${total_rev_sum} ELSE NULL END  ;;
    value_format_name: usd_0
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }


  dimension_group: date_goal_created {
    type: time
    sql: ${TABLE}."DATE_GOAL_CREATED" ;;
  }

  dimension: new_sp_flag {
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  dimension_group: first_date_as_TAM {
    type: time
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  set: detail {
    fields: [

  sp_user_id,
  salesperson,
  name,
  current_status,
  start_month,
  last_month,
  jurisdiction,
  sp_market_id,
  sp_market,
  district,
  region_dated,
  region_name,
  market_type,
  in_market_rev_monthly_pb,
  total_rev_monthly_pb,
  in_market_rev,
  out_market_rev,
  no_sp_market_rev,
  total_rev,
  in_market_prct,
  in_market_rev_incr_flag,
  total_rev_incr_flag,
  in_market_prct_incr_flag,
  rolling_avg_in_market_rev,
  rolling_avg_total_rev,
  in_market_rev_monthly_prct_change,
  total_rev_monthly_prct_change,
  current_monthly_rev_goal,
  current_in_market_monthly_revenue_goal,
  current_out_market_monthly_revenue_goal,
  date_goal_created_time,
  new_sp_flag
    ]
  }
}
