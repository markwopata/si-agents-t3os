view: t3_damaged_goods {
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
      T3POL.PRICE_PER_UNIT                    AS PRICE_PER_UNIT
      FROM PROCUREMENT.PUBLIC.PURCHASE_ORDERS T3PO
      LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS T3POL
        ON T3POL.PURCHASE_ORDER_ID = T3PO.PURCHASE_ORDER_ID
      LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS EVS
        ON EVS.ENTITY_ID = T3PO.VENDOR_ID
      LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDINT
        ON VENDINT.VENDORID = EVS.EXTERNAL_ERP_VENDOR_REF
      LEFT JOIN ES_WAREHOUSE.INVENTORY.PARTS P
        ON P.ITEM_ID = T3POL.ITEM_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U1
        ON U1.USER_ID = T3PO.CREATED_BY_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U2
        ON U2.USER_ID = T3PO.MODIFIED_BY_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS BRCH1
        ON BRCH1.MARKET_ID = T3PO.REQUESTING_BRANCH_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS BRCH2
        ON BRCH2.MARKET_ID = T3PO.DELIVER_TO_ID
    WHERE (T3POL.TOTAL_ACCEPTED > 0 OR T3POL.TOTAL_REJECTED > 0)
    ;;
  }

  # -------------------------------
  # Dimensions
  # -------------------------------

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.PO_NUMBER ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension: update_timestamp {
    type: date_time
    sql: ${TABLE}.UPDATE_TIMESTAMP ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}.CREATED_BY ;;
  }

  dimension: modified_by {
    type: string
    sql: ${TABLE}.MODIFIED_BY ;;
  }

  dimension: branch_ordered {
    type: string
    sql: ${TABLE}.BRANCH_ORDERED ;;
  }

  dimension: branch_delivered {
    type: string
    sql: ${TABLE}.BRANCH_DELIVERED ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.ITEM_ID ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.SKU ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.ITEM_NAME ;;
  }

  dimension: qty_ordered {
    type: number
    sql: ${TABLE}.T3_QTY_ORDERED ;;
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}.T3_QTY_ACCEPTED ;;
  }

  dimension: qty_rejected {
    type: number
    sql: ${TABLE}.T3_QTY_REJECTED ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}.PRICE_PER_UNIT ;;
  }


  # -------------------------------
  # Measures
  # -------------------------------


  # Count of Unique Vendors
  measure: count_distinct_vendor {
    type: count_distinct
    sql: ${vendor_id} ;;
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

  # Price per unit
  measure: price_per_unit_measure {
    type: number
    sql: ${TABLE}.PRICE_PER_UNIT ;;
    value_format_name: "decimal_0"
    description: "Price per unit"
  }

# Calculated: Price Difference
  measure: price_difference {
    type: number
    sql: ${qty_received_vs_ordered} * ${price_per_unit_measure} ;;
    value_format: "$0.00"
    description: "Price per Unit * (Ordered - Received)"
  }


  measure: PO_PER_VENDOR {
    type: count_distinct
    sql_distinct_key: ${TABLE}.VENDOR_ID ;;
    sql: ${TABLE}.PO_NUMBER ;;
  }

  measure: count_of_offenses_per_vendor {
    type: number
    sql: SUM(CASE WHEN (${TABLE}.T3_QTY_ORDERED - (${TABLE}.T3_QTY_ACCEPTED + ${TABLE}.T3_QTY_REJECTED)) < 0 THEN 1 ELSE 0 END) ;;
    description: "Count of offenses where ordered quantity is less than total received for each vendor"
  }

  measure: count_of_offenses_per_user {
    type: number
    sql: SUM(CASE WHEN (${TABLE}.T3_QTY_ORDERED - (${TABLE}.T3_QTY_ACCEPTED + ${TABLE}.T3_QTY_REJECTED)) < 0 THEN 1 ELSE 0 END) ;;
    description: "Count of offenses where ordered quantity is less than total received for each user"
  }

  measure: po_per_vendor {
    type: count_distinct
    sql: ${TABLE}.PO_NUMBER ;;
    description: "Number of distinct purchase orders per vendor"
  }

  measure: count_of_offenses {
    type: number
    sql: SUM(CASE WHEN ${qty_received_vs_ordered} < 0 THEN 1 ELSE 0 END) ;;
    description: "Number of offenses where quantity received vs. ordered is negative"
  }



  }
