view: min_date_branch_warranty_oec {
  sql_table_name: ANALYTICS.WARRANTIES.MONTHLY_BRANCH_WARRANTY_OEC ;;

  dimension: month {
    type: date
    sql: ${TABLE}.generated_date ;;
  }

  dimension_group: report_month_expanded {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.generated_date AS TIMESTAMP_NTZ) ;;
}


  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.branch_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${month}, ${branch_id}, ${make}) ;;
  }

  dimension: warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
  }

  dimension: month_oec_goal {
    type: number
    value_format_name: usd_0
    sql: (${warranty_oec} * 0.02) / 12 ;;
  }

  measure: total_goal {
    type: sum
    value_format_name: usd_0
    sql: ${month_oec_goal} ;;
  }

  measure: total_oec {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_oec} ;;
  }

  dimension: claim_amt {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claim_amt ;;
  }

  dimension: annualized_claim {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.annualized_claim_total;;
  }

  measure: annualized_claim_total {
    type: sum
    value_format_name: usd_0
    sql: ${annualized_claim};;
  }
}
