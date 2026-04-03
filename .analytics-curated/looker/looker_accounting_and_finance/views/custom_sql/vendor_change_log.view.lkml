view: vendor_change_log {
  derived_table: {
    sql:
SELECT
    CONCAT(V.OBJECT_KEY, '-', DATE(V.ACCESS_TIME)) AS EVENT_KEY,
    V.OBJECT_KEY                                   AS VENDOR_ID,
    V.ACCESS_MODE,
    V.ACCESS_TIME,
    V.REPORT_FIELD_NAME,
    V.OBJECT_FIELD_NAME,
    V.FIELD_BEFORE,
    V.FIELD_AFTER,
    V.SOURCE,
    V.OBJECT_LINK,
    V.USER_ID,
    V1.STATUS,
    V1.VENDOR_CATEGORY                          AS VENDOR_CATEGORY_LEGACY,
    V1.NEW_VENDOR_CATEGORY                      AS VENDOR_CATEGORY_NEW,
    V1.VENDOR_SUB_CATEGORY                      AS VENDOR_SUBCATEGORY,
    V1.NAME,
    V1.TERMNAME                                 AS PAY_TERMS,
    TRIM( -- weird spacing otherwise
        CASE
          WHEN V1.PAYMETHODREC = '1'  THEN 'Printed Check'
          WHEN V1.PAYMETHODREC = '12' THEN 'ACH'
          WHEN V1.PAYMETHODREC = '3'  THEN 'Charge Card'
          WHEN V1.PAYMETHODREC = '5'  THEN 'EFT'
        END
      )                                         AS PAYMENT_METHOD,
    RIGHT(V1.ACHACCOUNTNUMBER,4)                AS ACH_ACCOUNT_LAST_4,
    V1.ACHBANKROUTINGNUMBER                     AS ACH_ROUTING_NUMBER
FROM ANALYTICS.INTACCT_AUDIT.VENDOR V
LEFT JOIN ANALYTICS.INTACCT.VENDOR V1
    ON V.OBJECT_KEY = V1.VENDORID;;
  }

  dimension: EVENT_KEY {
    type: string
    sql: ${TABLE}.EVENT_KEY;;
  }

  dimension: VENDOR_ID {
    type: string
    sql: ${TABLE}.VENDOR_ID;;
  }

  dimension: ACCESS_MODE {
    type: string
    sql: ${TABLE}.ACCESS_MODE;;
  }

  dimension_group: ACCESSED {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ACCESS_TIME ;;
  }

  dimension: REPORT_FIELD_NAME {
    type: string
    sql: ${TABLE}.REPORT_FIELD_NAME;;
  }

  dimension: OBJECT_FIELD_NAME {
    type: string
    sql: ${TABLE}.OBJECT_FIELD_NAME;;
  }

  dimension: FIELD_BEFORE {
    type: string
    sql: ${TABLE}.FIELD_BEFORE;;
  }

  dimension: FIELD_AFTER {
    type: string
    sql: ${TABLE}.FIELD_AFTER;;
  }

  dimension: SOURCE {
    type: string
    sql: ${TABLE}.SOURCE;;
  }

  dimension: OBJECT_LINK {
    type: string
    sql: ${TABLE}.OBJECT_LINK;;
  }

  dimension: USER_ID {
    type: string
    sql: ${TABLE}.USER_ID;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS;;
  }

  dimension: VENDOR_CATEGORY_LEGACY {
    type: string
    sql: ${TABLE}.VENDOR_CATEGORY_LEGACY;;
  }

  dimension: VENDOR_CATEGORY_NEW {
    type: string
    sql: ${TABLE}.VENDOR_CATEGORY_NEW;;
  }

  dimension: VENDOR_SUBCATEGORY {
    type: string
    sql: ${TABLE}.VENDOR_SUBCATEGORY;;
  }

  dimension: VENDOR_NAME {
    type: string
    sql: ${TABLE}.NAME;;
  }

  dimension: PAY_TERMS {
    type: string
    sql: ${TABLE}.PAY_TERMS;;
  }

  dimension: PAYMENT_METHOD {
    type: string
    sql: ${TABLE}.PAYMENT_METHOD;;
  }

  dimension: ACH_ACCOUNT_LAST_4 {
    type: string
    sql: ${TABLE}.ACH_ACCOUNT_LAST_4;;
  }

  dimension: ACH_ROUTING_NUMBER {
    type: string
    sql: ${TABLE}.ACH_ROUTING_NUMBER;;
  }

  measure: VENDOR_COUNT_DISTINCT {
    type: count_distinct
    sql: ${EVENT_KEY} ;;
    description: "Count of distinct vendors"
  }

  measure: PAYMENT_METHOD_COUNT {
    type: count_distinct
    sql_distinct_key: ${PAYMENT_METHOD} ;;
    sql: ${EVENT_KEY} ;;
  }

  measure: VENDOR_COUNT {
    type: number
    sql: COUNT(${EVENT_KEY}) ;;
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
