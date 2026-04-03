view: oec_detail_aggregated {
  sql_table_name: analytics.branch_earnings.int_branch_earnings_oec_detail_summary_looker ;;

  dimension: gl_date {
    label: "GL Date"
    type: date
    convert_tz: no
    sql: ${TABLE}.gl_date ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}.market_id ;;
  }

  measure: amount {
    label: "Amount"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.amount ;;
  }

  measure: previous_month_amount {
    label: "Previous Month Amount"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.previous_month_amount ;;
  }

  measure: amount_difference {
    label: "Amount Difference"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.amount_difference ;;
  }

  measure: equipment_charge {
    label: "Equipment Charge"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.equipment_charge ;;
  }

  measure: previous_month_equipment_charge {
    label: "Previous Month Equipment Charge"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.previous_month_equipment_charge ;;
  }

  measure: equipment_charge_difference {
    label: "Equipment Charge Difference"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.equipment_charge_difference ;;
  }

  measure: asset_count {
    label: "Asset Count"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.asset_count ;;
  }

  measure: previous_month_asset_count {
    label: "Previous Month Asset Count"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.previous_month_asset_count ;;
  }

  measure: asset_count_difference {
    label: "Asset Count Difference"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.asset_count_difference ;;
  }
}


