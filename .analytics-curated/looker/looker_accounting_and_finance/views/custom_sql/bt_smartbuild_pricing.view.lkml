view: bt_smartbuild_pricing {
  derived_table: {
    sql:
SELECT DISTINCT
  P.ProductCode,
  P.Description,
  ROUND(PP.AverageCostWithAdd,2) AS AverageCost,
  ROUND((PP.AverageCostWithAdd / 0.72),2) AS StandardSell
FROM ANALYTICS.BT_DBO.PRODUCT as P
JOIN ANALYTICS.BT_DBO.PRODUCTPRICE AS PP ON P.ProductID = PP.ProductID AND PP.BranchID = 140602
JOIN ANALYTICS.BT_DBO.SELLPRICERULEPRODUCT AS SP ON P.ProductID = SP.PRODUCTID
WHERE P.DELETED = 0 AND SP.SELLPRICERULEID = 103
;;
  }

  dimension: ProductCode {
    label: "Product Code"
    type: string
    sql: ${TABLE}.ProductCode ;;
  }

  dimension: Description {
    label: "Description"
    type: string
    sql: ${TABLE}.Description ;;
  }

  dimension: AverageCost {
    label: "Average Cost $"
    type: number
    value_format_name: usd
    sql: ${TABLE}.AverageCost ;;
  }

  dimension: StandardSell {
    label: "Standard Sell $"
    type: number
    value_format_name: usd
    sql: ${TABLE}.StandardSell ;;
  }
}

# view: bt_smartbuild_pricing {
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
