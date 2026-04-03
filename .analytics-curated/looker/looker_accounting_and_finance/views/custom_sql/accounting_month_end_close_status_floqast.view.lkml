view: accounting_month_end_close_status_floqast {
  derived_table: {
    sql:
      SELECT
    c.PERIOD,
    c.FQ_FOLDER,
    c.MEC_TASK_NAME,
    c.PREPARER,
    c.PREPARER_DUE_DATE,
    c.PREPARER_DATE_COMPLETE,
    c.REVIEWER,
    c.REVIEWER_DATE_COMPLETE,
    c.STATUS,
    c.DETAILEDSTATUS AS DETAILED_STATUS,
    c.DATETIMENOW,
    (
        SELECT COUNT(*)
        FROM analytics.floqast.checklist c2
        WHERE c2.STATUS = 'Outstanding'
          AND c2.PERIOD = c.PERIOD
          AND c2.DATETIMENOW = c.DATETIMENOW
    ) AS OUTSTANDING_COUNT
FROM analytics.floqast.checklist c
INNER JOIN (
    SELECT
        PERIOD,
        MAX(DATETIMENOW) AS MAX_TIMESTAMP
    FROM analytics.floqast.checklist
    GROUP BY PERIOD
) mt
    ON c.PERIOD = mt.PERIOD AND c.DATETIMENOW = mt.MAX_TIMESTAMP
ORDER BY c.DATETIMENOW DESC, c.STATUS DESC, c.DETAILEDSTATUS DESC, c.MEC_TASK_NAME ASC
;;
  }


  dimension: PERIOD {
    type: string
    sql: ${TABLE}.PERIOD;;
  }

  dimension: FQ_FOLDER {
    type: string
    sql: ${TABLE}.FQ_FOLDER;;
  }

  dimension: MEC_TASK_NAME {
    type: string
    sql: ${TABLE}.MEC_TASK_NAME;;
  }

  dimension: PREPARER {
    type: string
    sql: ${TABLE}.PREPARER;;
  }

  dimension: PREPARER_DUE_DATE {
    type: date
    sql: ${TABLE}.PREPARER_DUE_DATE;;
  }

  dimension: PREPARER_DATE_COMPLETE {
    type: date
    sql: ${TABLE}.PREPARER_DATE_COMPLETE;;
  }

  dimension: REVIEWER {
    type: string
    sql: ${TABLE}.REVIEWER;;
  }

  dimension: REVIEWER_DATE_COMPLETE {
    type: date
    sql: ${TABLE}.REVIEWER_DATE_COMPLETE;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS;;
  }

  dimension: DETAILED_STATUS {
    type: string
    sql: ${TABLE}.DETAILED_STATUS;;
  }

  dimension: DATETIMENOW {
    type: date_time
    sql: ${TABLE}.DATETIMENOW;;
  }

  dimension: OUTSTANDING_COUNT {
    type: number
    sql: ${TABLE}.OUTSTANDING_COUNT ;;
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
