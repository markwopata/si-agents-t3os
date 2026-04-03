view: ar_related_party {
  derived_table: {
    sql:
       SELECT
        ARD.ACCOUNTNO       AS ACCOUNT_NUMBER,
        GLA.TITLE           AS ACCOUNT_NAME,
        ARR.WHENCREATED     AS INVOICE_DATE,
        ARR.WHENPOSTED      AS POST_DATE,
        ARR.RECORDID        AS INVOICE_NUMBER,
        ARD.AMOUNT          AS AMOUNT,
        C.CUSTOMERID,
        C.NAME              AS CUSTOMER_NAME,
        ARD.ENTRYDESCRIPTION AS MEMO,
FROM ANALYTICS.INTACCT.ARRECORD AS ARR
LEFT JOIN ANALYTICS.INTACCT.ARDETAIL AS ARD ON ARR.RECORDNO = ARD.RECORDKEY AND ARR.RECORDTYPE IN ('arinvoice','aradjustment')
LEFT JOIN ANALYTICS.INTACCT.CUSTOMER AS C ON ARR.CUSTOMERID = C.CUSTOMERID
LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT AS GLA ON ARD.ACCOUNTNO = GLA.ACCOUNTNO
WHERE C.REPORTING_CATEGORY = 'Related Party';;
  }


  dimension: ACCOUNT_NUMBER {
    type: string
    sql: ${TABLE}.ACCOUNT_NUMBER;;
  }

  dimension: ACCOUNT_NAME {
    type: string
    sql: ${TABLE}.ACCOUNT_NAME;;
  }

  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}.INVOICE_DATE;;
  }

  dimension: POST_DATE {
    type: date
    sql: ${TABLE}.POST_DATE;;
  }

  dimension: INVOICE_NUMBER {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER;;
  }

  measure: AMOUNT {
    type: sum
    sql: ${TABLE}.AMOUNT;;
  }

  dimension: CUSTOMERID {
    type: string
    sql: ${TABLE}.CUSTOMERID;;
  }

  dimension: CUSTOMER_NAME {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME;;
  }

  dimension: MEMO {
    type: string
    sql: ${TABLE}.MEMO;;
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
