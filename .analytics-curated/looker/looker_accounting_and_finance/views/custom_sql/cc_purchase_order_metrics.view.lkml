view: cc_purchase_order_metrics {
  derived_table: {
    sql:
SELECT
    DATE_TRUNC('MONTH', P.DATE_CREATED) AS MONTH,
    -- Categorize PO as OPEN / CLOSED / DELETED
    CASE
        WHEN P.DATE_ARCHIVED IS NOT NULL OR P.STATUS = 'ARCHIVED' THEN 'DELETED'
        ELSE P.STATUS
    END AS PO_CATEGORY,
    -- Inventory vs Non-Inventory
    I.ITEM_TYPE,
    -- Metrics
    COUNT(DISTINCT P.PURCHASE_ORDER_ID) AS TOTAL_POS,
    COUNT(DISTINCT LI.PURCHASE_ORDER_LINE_ITEM_ID) AS TOTAL_LINE_ITEMS,
    SUM(LI.QUANTITY) AS TOTAL_QUANTITY,
    SUM(LI.TOTAL_ACCEPTED) AS TOTAL_ACCEPTED_QUANTITY,
    SUM(LI.TOTAL_ACCEPTED * LI.PRICE_PER_UNIT) AS TOTAL_ACCEPTED_VALUE
FROM PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS P
JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS AS LI
    ON LI.PURCHASE_ORDER_ID = P.PURCHASE_ORDER_ID
JOIN PROCUREMENT.PUBLIC.ITEMS AS I
    ON I.ITEM_ID = LI.ITEM_ID
WHERE
    P.COMPANY_ID = 1854
    AND I.COMPANY_ID = 1854
GROUP BY
    MONTH,
    PO_CATEGORY,
    I.ITEM_TYPE
    ;;
  }

  dimension_group: month {
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}.MONTH ;;
  }

  dimension_group: month_raw {
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}.MONTH ;;
  }

  dimension: is_before_current_month {
    type: yesno
    label: "Before Current Month"
    sql: ${month_raw} < date_trunc('month', current_date) ;;
  }

  dimension: po_category {
    type: string
    sql: ${TABLE}.PO_CATEGORY ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}.ITEM_TYPE ;;
  }

  measure: total_pos {
    type: sum
    sql: ${TABLE}.TOTAL_POS ;;
  }

  measure: total_line_items {
    type: sum
    sql: ${TABLE}.TOTAL_LINE_ITEMS ;;
  }

  measure: total_quantity {
    type: sum
    sql: ${TABLE}.TOTAL_QUANTITY ;;
  }

  measure: total_accepted_quantity {
    type: sum
    sql: ${TABLE}.TOTAL_ACCEPTED_QUANTITY ;;
  }

  measure: total_accepted_value {
    type: sum
    sql: ${TABLE}.TOTAL_ACCEPTED_VALUE ;;
    value_format_name: "usd"
  }
}
