view: warranty_claim_performance {
  sql_table_name: ANALYTICS.WARRANTIES.weekly_trailing_warranty_oec  ;;

  dimension: report_date {
    type: date
    sql: ${TABLE}.reference_date ;;
  }

  dimension: OEM {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: trailing_warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
  }

  dimension: warranty_goal {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warranty_goal ;;
  }

  dimension: ltm_claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_claimed ;;
  }

  dimension: claimed_to_goal {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.claimed_to_goal ;;
  }

  dimension: ltm_paid {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_paid ;;
  }

  dimension: paid_to_goal {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}.paid_to_goal ;;
  }
}
