view: ap_ar_related_party {
  derived_table: {
    sql:
      SELECT
        APD.ACCOUNTNO       AS ACCOUNT_NUMBER,
        GLA.TITLE           AS ACCOUNT_NAME,
        APR.WHENCREATED     AS BILL_DATE,
        APR.WHENPOSTED      AS POST_DATE,
        APR.RECORDID        AS BILL_NUMBER,
        APD.AMOUNT          AS AMOUNT,
        V.VENDORID,
        V.NAME              AS VENDOR_NAME,
        APD.ENTRYDESCRIPTION AS MEMO
FROM ANALYTICS.INTACCT.APRECORD AS APR
LEFT JOIN ANALYTICS.INTACCT.APDETAIL AS APD ON APR.RECORDNO = APD.RECORDKEY AND APR.RECORDTYPE IN ('apbill', 'apadjustment')
LEFT JOIN ANALYTICS.INTACCT.VENDOR AS V ON APR.VENDORID = V.VENDORID
LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT AS GLA ON APD.ACCOUNTNO = GLA.ACCOUNTNO
WHERE V.REPORTING_CATEGORY = 'Related Party';;
  }


  dimension: ACCOUNT_NUMBER {
    type: string
    sql: ${TABLE}.ACCOUNT_NUMBER;;
  }

  dimension: ACCOUNT_NAME {
    type: string
    sql: ${TABLE}.ACCOUNT_NAME;;
  }

  dimension: BILL_DATE {
    type: date
    sql: ${TABLE}.BILL_DATE;;
  }

  dimension: POST_DATE {
    type: date
    sql: ${TABLE}.POST_DATE;;
  }

  dimension: BILL_NUMBER {
    type: string
    sql: ${TABLE}.BILL_NUMBER;;
  }

  measure: AMOUNT {
    type: sum
    sql: ${TABLE}.AMOUNT;;
  }

  dimension: VENDORID {
    type: string
    sql: ${TABLE}.VENDORID;;
  }

  dimension: VENDOR_NAME {
    type: string
    sql: ${TABLE}.VENDOR_NAME;;
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
