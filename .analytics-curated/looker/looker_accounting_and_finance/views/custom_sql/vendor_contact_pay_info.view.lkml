view: vendor_contact_pay_info {
  derived_table: {
    sql:
      SELECT
        V.VENDORID,
        V.STATUS,
        V.REPORTING_CATEGORY,
        V.TERMNAME AS PAY_TERMS,
        TRIM(
        CASE
            WHEN V.PAYMETHODREC = 1 THEN 'Printed Check'
            WHEN V.PAYMETHODREC = 12 THEN 'ACH'
            WHEN V.PAYMETHODREC = 3 THEN 'Charge Card'
            WHEN V.PAYMETHODREC = 5 THEN 'EFT'
            ELSE CAST(V.PAYMETHODREC AS STRING)
        END
        ) AS PAYMENT_METHOD,
    FROM ANALYTICS.INTACCT.VENDOR V;;
  }

  dimension: VENDORID {
    type: string
    sql: ${TABLE}.VENDORID;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS;;
  }

  dimension: REPORTING_CATEGORY {
    type: string
    sql: ${TABLE}.REPORTING_CATEGORY;;
  }

  dimension: PAY_TERMS {
    type: string
    sql: ${TABLE}.PAY_TERMS;;
  }

  dimension: PAYMENT_METHOD {
    type: string
    sql: ${TABLE}.PAYMENT_METHOD;;
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

# view: vendor_contact_info {
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
