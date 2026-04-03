view: bt_cycle_count {
  derived_table: {
    sql:
SELECT
  B.BranchCode,
  B.NAME AS BranchName,
  CAST(SAH.DateTimeCreated AS DATE) AS AdjustmentDate,
  ROUND(SUM((SA.AdjustStockActual * SAH.CostWithAdditional)),2) AS CumulativeExtendedCost
FROM ANALYTICS.BT_DBO.StockAdjustmentHeader AS SAH
LEFT JOIN ANALYTICS.BT_DBO.StockAdjustment AS SA ON SAH.StockAdjustmentHeaderID = SA.StockAdjustmentHeaderID
LEFT JOIN ANALYTICS.BT_DBO.Branch AS B ON SAH.BranchID = B.BranchID
WHERE CAST(SAH.DateTimeCreated AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)
GROUP BY B.BranchCode, B.Name, CAST(SAH.DateTimeCreated AS DATE)
ORDER BY B.Name, AdjustmentDate desc;;
  }

  dimension: branch_code {
    label: "Branch Code"
    type: string
    sql: ${TABLE}.BranchCode ;;
  }

  dimension: branch_name {
    label: "Branch Name"
    type: string
    sql: ${TABLE}.BranchName ;;
  }

  dimension: adjustment_date {
    label: "Adjustment Date"
    type: date
    sql: ${TABLE}.AdjustmentDate ;;
  }

  dimension: cumulative_extended_cost {
    label: "Total Extended Cost $"
    type: number
    value_format_name: usd
    sql: ${TABLE}.CumulativeExtendedCost ;;
  }








  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: aprecord_time_difference {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
