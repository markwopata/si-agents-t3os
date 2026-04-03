view: ap_user_submitted_averages {

    derived_table: {
      sql: SELECT
                "AP_USER_NAME",
                DATE_TRUNC('day', COGNOS_DATE) AS submission_day,
                COUNT(DISTINCT "REQUEST_ID") AS num_submissions
              FROM
                 "ANALYTICS"."CONCUR"."APPROVED_INVOICES_BY_AP_USER"
              WHERE
                YEAR(COGNOS_DATE) = YEAR(CURRENT_DATE())
              GROUP BY
                1, 2
               ;;
    }





    dimension: rep_name {
      type: string
      sql: ${TABLE}."AP_USER_NAME" ;;
    }
    dimension: submission_day {
      type: date
      sql: ${TABLE}.submission_day ;;
    }




    dimension: num_submissions {
      type: number
      sql: ${TABLE}.num_submissions ;;
    }
  }


# view: ap_user_submitted_averages {
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
