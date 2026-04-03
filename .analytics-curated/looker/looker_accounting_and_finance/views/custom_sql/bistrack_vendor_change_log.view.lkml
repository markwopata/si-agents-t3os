view: bistrack_vendor_change_log {
  derived_table: {
    sql:
SELECT
    CONCAT(V.OBJECT_KEY, '-', DATE(V.ACCESS_TIME)) AS EVENT_KEY,
    V.OBJECT_KEY                                   AS VENDOR_ID,
    V1.NAME                                        AS VENDOR_NAME,
    V.ACCESS_MODE,
    V.ACCESS_TIME,
    V.REPORT_FIELD_NAME,
    V.OBJECT_FIELD_NAME,
    V.FIELD_BEFORE,
    V.FIELD_AFTER,
    V.SOURCE,
    V.USER_ID,
    DISP_CONT.CONTACTNAME,
    DISP_CONT.EMAIL1,
    DISP_CONT.PHONE1,
    DISP_CONT.MAILADDRESS_ADDRESS1,
    DISP_CONT.MAILADDRESS_ADDRESS2,
    DISP_CONT.MAILADDRESS_CITY,
    DISP_CONT.MAILADDRESS_STATE,
    DISP_CONT.MAILADDRESS_ZIP,
    V1.NON_INVENTORY,
    V1.TERMNAME,
    V1.STATUS
FROM ANALYTICS.INTACCT_AUDIT.VENDOR V
LEFT JOIN ANALYTICS.INTACCT.VENDOR V1
    ON V.OBJECT_KEY = V1.VENDORID
LEFT JOIN ANALYTICS.INTACCT.CONTACT DISP_CONT ON V1.DISPLAYCONTACTKEY = DISP_CONT.RECORDNO
WHERE V1.APPROVED_ENTITIES LIKE '%Bistrack/Forge and Build%'
ORDER BY ACCESS_TIME DESC;;
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

  dimension: USER_ID {
    type: string
    sql: ${TABLE}.USER_ID;;
  }

  dimension: VENDOR_NAME {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: CONTACTNAME {
    type: string
    sql: ${TABLE}.CONTACTNAME ;;
  }

  dimension: EMAIL1 {
    type: string
    sql: ${TABLE}.EMAIL1 ;;
  }

  dimension: PHONE1 {
    type: string
    sql: ${TABLE}.PHONE1 ;;
  }

  dimension: MAILADDRESS_ADDRESS1 {
    type: string
    sql: ${TABLE}.MAILADDRESS_ADDRESS1 ;;
  }

  dimension: MAILADDRESS_ADDRESS2 {
    type: string
    sql: ${TABLE}.MAILADDRESS_ADDRESS2 ;;
  }

  dimension: MAILADDRESS_CITY {
    type: string
    sql: ${TABLE}.MAILADDRESS_CITY ;;
  }

  dimension: MAILADDRESS_STATE {
    type: string
    sql: ${TABLE}.MAILADDRESS_STATE ;;
  }

  dimension: MAILADDRESS_ZIP {
    type: string
    sql: ${TABLE}.MAILADDRESS_ZIP ;;
  }

  dimension: NON_INVENTORY {
    type: string
    sql: ${TABLE}.NON_INVENTORY ;;
  }

  dimension: TERMNAME {
    type: string
    sql: ${TABLE}.TERMNAME ;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  measure: VENDOR_COUNT_DISTINCT {
    type: count_distinct
    sql: ${EVENT_KEY} ;;
    description: "Count of distinct vendors"
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
