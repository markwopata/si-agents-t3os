view: damaged_goods {
  derived_table: {
    sql:
       SELECT
    VENDINT.VENDORID                        AS VENDOR_ID,
    VENDINT.NAME                            AS VENDOR_NAME,
    T3PO.PURCHASE_ORDER_NUMBER              AS PO_NUMBER,
    CAST(T3PO.DATE_CREATED AS DATE)         AS DATE_CREATED,
    CAST(CONVERT_TIMEZONE('UTC', 'America/Chicago', TO_TIMESTAMP_NTZ(T3POL._ES_UPDATE_TIMESTAMP)) AS TIMESTAMP) AS UPDATE_TIMESTAMP,
    CONCAT(T3PO.CREATED_BY_ID, ' - ', U1.FIRST_NAME, ' ', U1.LAST_NAME) AS CREATED_BY,
    CONCAT(T3PO.MODIFIED_BY_ID, ' - ', U2.FIRST_NAME, ' ', U2.LAST_NAME) AS MODIFIED_BY,
    CONCAT(T3PO.REQUESTING_BRANCH_ID, ' - ', BRCH1.NAME) AS BRANCH_ORDERED,
    CONCAT(T3PO.DELIVER_TO_ID, ' - ', BRCH2.NAME ) AS BRANCH_DELIVERED,
    P.ITEM_ID                               AS ITEM_ID,
    P.SKU_FIELD                             AS SKU,
    P.SEARCH                                AS ITEM_NAME,
    T3POL.QUANTITY                          AS T3_QTY_ORDERED,
    T3POL.TOTAL_ACCEPTED                    AS T3_QTY_ACCEPTED,
    T3POL.TOTAL_REJECTED                    AS T3_QTY_REJECTED,
    (T3_QTY_ACCEPTED + T3_QTY_REJECTED)     AS T3_QTY_RECEIVED,
    (T3_QTY_REJECTED / T3_QTY_ORDERED)*100      AS PERCENT_REJECTED,
    (T3_QTY_RECEIVED / T3_QTY_ORDERED)*100      AS PERCENTAGE_RECEIVED
FROM PROCUREMENT.PUBLIC.PURCHASE_ORDERS T3PO
    -- link PO doc number to PO line item
    LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS T3POL
        ON T3POL.PURCHASE_ORDER_ID = T3PO.PURCHASE_ORDER_ID
    -- link the T3 PO's vendor id to T3 Vendor repository
    LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS EVS
        ON EVS.ENTITY_ID = T3PO.VENDOR_ID
    -- link the Sage Vendor ID to the T3 Vendor repository
    LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDINT
        ON VENDINT.VENDORID = EVS.EXTERNAL_ERP_VENDOR_REF
    -- link T3 Parts table
    LEFT JOIN ES_WAREHOUSE.INVENTORY.PARTS P
        ON P.ITEM_ID = T3POL.ITEM_ID
    -- link T3 Users table
    LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U1
        ON U1.USER_ID = T3PO.CREATED_BY_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U2
        ON U2.USER_ID = T3PO.MODIFIED_BY_ID
    -- link T3 Market table
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS BRCH1
        ON BRCH1.MARKET_ID = T3PO.REQUESTING_BRANCH_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS BRCH2
        ON BRCH2.MARKET_ID = T3PO.DELIVER_TO_ID
WHERE T3_QTY_RECEIVED > 0;;
  }


  dimension: VENDOR_ID {
    type: string
    sql: ${TABLE}.VENDOR_ID;;
  }

  dimension: VENDOR_NAME {
    type: string
    sql: ${TABLE}.VENDOR_NAME;;
  }

  dimension: PO_NUMBER {
    type: string
    sql: ${TABLE}.PO_NUMBER;;
  }

  dimension: DATE_CREATED {
    type: date
    sql: ${TABLE}.DATE_CREATED;;
  }

  dimension: UPDATE_TIMESTAMP {
    type: date_time
    sql: ${TABLE}.UPDATE_TIMESTAMP;;
  }

  dimension: CREATED_BY {
    type: string
    sql: ${TABLE}.CREATED_BY;;
  }

  dimension: MODIFIED_BY {
    type: string
    sql: ${TABLE}.MODIFIED_BY;;
  }

  dimension: BRANCH_ORDERED {
    type: string
    sql: ${TABLE}.BRANCH_ORDERED;;
  }

  dimension: BRANCH_DELIVERED {
    type: string
    sql: ${TABLE}.BRANCH_DELIVERED;;
  }

  dimension: ITEM_ID {
    type: string
    sql: ${TABLE}.ITEM_ID;;
  }

  dimension: SKU {
    type: string
    sql: ${TABLE}.SKU;;
  }

  dimension: ITEM_NAME {
    type: string
    sql: ${TABLE}.ITEM_NAME;;
  }

  dimension: T3_QTY_ORDERED {
    type: number
    sql: ${TABLE}.T3_QTY_ORDERED;;
  }

  dimension: T3_QTY_ACCEPTED {
    type: number
    sql: ${TABLE}.T3_QTY_ACCEPTED;;
  }

  dimension: T3_QTY_REJECTED {
    type: number
    sql: ${TABLE}.T3_QTY_REJECTED;;
  }

  dimension: T3_QTY_RECEIVED {
    type: number
    sql: ${TABLE}.T3_QTY_REJECTED;;
  }

  dimension: PERCENT_REJECTED {
    type: number
    sql: ${TABLE}.PERCENT_REJECTED;;
  }

  dimension: PERCENTAGE_RECEIVED {
    type: number
    sql: ${TABLE}.PERCENTAGE_RECEIVED;;
  }

  dimension: percent_rejected_of_received_dimension {
    type: number
    sql: CASE WHEN (${T3_QTY_ACCEPTED} + ${T3_QTY_REJECTED}) != 0 THEN (${T3_QTY_REJECTED} / (${T3_QTY_ACCEPTED} + ${T3_QTY_REJECTED})) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity rejected out of received"
  }

# Count of Unique Vendors
  measure: count_distinct_vendor {
    type: count_distinct
    sql: ${VENDOR_ID} ;;
    description: "Number of unique vendors"
  }

  # Sum of Quantities Ordered
  measure: sum_qty_ordered {
    type: sum
    sql: ${TABLE}.T3_QTY_ORDERED ;;
    value_format_name: "decimal_0"
    description: "Total quantity ordered"
  }

  # Sum of Quantities Accepted
  measure: sum_qty_accepted {
    type: sum
    sql: ${TABLE}.T3_QTY_ACCEPTED ;;
    value_format_name: "decimal_0"
    description: "Total quantity accepted"
  }

  # Sum of Quantities Rejected
  measure: sum_qty_rejected {
    type: sum
    sql: ${TABLE}.T3_QTY_REJECTED ;;
    value_format_name: "decimal_0"
    description: "Total quantity rejected"
  }

  # Calculated: Total Quantity Received
  measure: total_qty_received {
    type: number
    sql: ${sum_qty_accepted} + ${sum_qty_rejected} ;;
    value_format_name: "decimal_0"
    description: "Total quantity received (accepted + rejected)"
  }

  # Calculated: Difference between quantity received vs ordered
  measure: qty_received_vs_ordered {
    type: number
    sql: ${sum_qty_ordered} - ${total_qty_received} ;;
    value_format_name: "decimal_0"
    description: "Quantity ordered - quantity received"
  }

  # Calculated: Percentage Rejected of Items Ordered
  measure: percent_rejected_of_ordered {
    type: number
    sql: CASE WHEN ${sum_qty_ordered} != 0 THEN (${sum_qty_rejected} / ${sum_qty_ordered}) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity rejected out of ordered"
  }

  # Calculated: Percentage Rejected of Items Received
  measure: percent_rejected_of_received {
    type: number
    sql: CASE WHEN ${total_qty_received} != 0 THEN (${sum_qty_rejected} / ${total_qty_received}) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity rejected out of received"
  }

  # Calculated: Percentage Accepted of Items Ordered
  measure: percent_accepted_of_ordered {
    type: number
    sql: CASE WHEN ${sum_qty_ordered} != 0 THEN (${sum_qty_accepted} / ${sum_qty_ordered}) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity accepted out of ordered"
  }

  # Calculated: Percentage Rejected of Items Received
  measure: percent_accepted_of_received {
    type: number
    sql: CASE WHEN ${total_qty_received} != 0 THEN (${sum_qty_accepted} / ${total_qty_received}) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity accepted out of received"
  }

  # Calculated: Percentage Received
  measure: percentage_received {
    type: number
    sql: CASE WHEN ${sum_qty_ordered} != 0 THEN (${total_qty_received} / ${sum_qty_ordered}) ELSE NULL END ;;
    value_format: "0.00%"
    description: "Percentage of quantity received out of ordered"
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

# view: damaged_goods {
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
