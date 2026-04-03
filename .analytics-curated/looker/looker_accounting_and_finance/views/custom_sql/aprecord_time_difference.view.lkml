view: aprecord_time_difference {
  derived_table: {
    sql:
       SELECT *
FROM (
    SELECT
        DDSREADTIME,
        LAG(DDSREADTIME) OVER (ORDER BY DDSREADTIME) AS prev_ddsreadtime,
        TIMESTAMPDIFF(MINUTE, LAG(DDSREADTIME) OVER (ORDER BY DDSREADTIME), DDSREADTIME) AS Time_Diff, -- difference in consecutive DDSREAD (minutes)
        CASE
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 0 THEN 'Sunday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 1 THEN 'Monday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 2 THEN 'Tuesday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 3 THEN 'Wednesday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 4 THEN 'Thursday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 5 THEN 'Friday'
            WHEN EXTRACT(DAYOFWEEK FROM DDSREADTIME) = 6 THEN 'Saturday'
        END AS DOW
    FROM "ANALYTICS"."INTACCT"."APRECORD"
    WHERE EXTRACT(DAYOFWEEK FROM DDSREADTIME) BETWEEN 1 AND 5 -- Include only weekdays
) AS sub
WHERE Time_Diff > 90
ORDER BY DDSREADTIME desc;;
  }


  dimension: DDSREADTIME {
    type: date_time
    sql: ${TABLE}.DDSREADTIME;;
  }

  dimension: prev_ddsreadtime {
    type: date_time
    sql: ${TABLE}.prev_ddsreadtime;;
  }

  dimension: Time_Diff {
    type: number
    value_format: "$#,,;-$#,,;-"
    sql: ${TABLE}.Time_Diff;;
  }

  dimension: DOW {
    type: string
    sql: ${TABLE}.DOW;;
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
