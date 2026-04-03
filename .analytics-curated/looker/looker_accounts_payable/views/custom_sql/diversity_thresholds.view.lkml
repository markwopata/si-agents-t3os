view: diversity_thresholds {

    derived_table: {
      sql:
      SELECT 'SDVOSB - Service-Disabled Veteran-Owned Small Business'        AS diversity_classification
      UNION ALL
      SELECT 'SDB - Small Disadvantaged Business' UNION ALL
      SELECT 'VOSB - Veteran-Owned Small Business'            UNION ALL
      SELECT 'WOSB - Women-Owned Small Business'               UNION ALL
      SELECT 'VBE - Veteran Owned Businesses'                UNION ALL

      SELECT 'Other' ;;
  }

        dimension: diversity_classification {
          primary_key: yes
        type: string
        sql: ${TABLE}.diversity_classification ;;
    }


# CASE
#             WHEN ${diversity_classification} = 'DVBE - Disabled Veteran Owned Business' THEN 'SDVOSB - Service-Disabled Veteran-Owned Small Business'

#             WHEN ${diversity_classification} = 'SDVBE - Service-Disabled Veteran Owned Business' THEN 'SDVOSB - Service-Disabled Veteran-Owned Small Business'

#             WHEN ${diversity_classification} = 'MBE - Minority Business Enterprise' THEN 'SDB - Small Disadvantaged Business'
#             WHEN ${diversity_classification} = 'VBE - Veteran Owned Businesses' THEN 'VOSB - Veteran-Owned Small Business'
#             WHEN ${diversity_classification} = 'WBE - Woman Business Enterprise'  THEN 'WOSB - Women-Owned Small Business'
#             ELSE 'none'
#           END ;;
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

# view: diversity_thesholds {
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
