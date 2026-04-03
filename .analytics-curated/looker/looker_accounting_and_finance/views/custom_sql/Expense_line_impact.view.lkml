view: Expense_line_impact {
  derived_table: {
    sql: SELECT DISTINCT
       e.ID                                                                         AS EXPENSE_LINE_ID,
       e.NAME                                                                       AS EXPENSE_LINE,
       e.WHENMODIFIED                                                               AS UPDATED_AT,
       u.DESCRIPTION                                                                AS UPDATED_BY,
       e.EXPENSE_CATEGORY                                                           AS EXPENSE_CATEGORY,
       m2.GLACCOUNT                                                                 AS GLACCOUNT,
       m2.ITEM                                                                      AS ITEM,
       m2.DEPARTMENT                                                                AS LOCATION,
FROM ANALYTICS.INTACCT.EXPENSE_LINE_MAPPING_E1 m
LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE e ON m.EXPENSE_LINE = e.NAME
LEFT JOIN ANALYTICS.INTACCT.USERINFO u ON u.RECORDNO = e.MODIFIEDBY
LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.ALL_VALID_EXPENSE_LINE_MAPPINGS m2 ON m2.EXPENSE_LINE_ID = e.ID
WHERE e.ID NOT IN (287208,287213,287227,287231,287232,287486,287485,287482,287481,287484,287483,287480,287479,287242,287249,287252,287265,287266,287275,287286,287293,287299,287310,287314,287315,287316,287317,287341,287342,287343,287350,287351,287352,287356,287357,287436,287373,287397) ;;
  }


  dimension: expense_line_id {
    type: number
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
    value_format: "0"
  }

  dimension: expense_line {
    type: string
    label: "Expense Line"
    sql: ${TABLE}.EXPENSE_LINE ;;
  }

  dimension_group: updated_at {
    type: time
    sql: ${TABLE}."UPDATED_AT" ;;
  }

  dimension: updated_by {
    type: string
    label: "Updated By"
    sql: ${TABLE}.UPDATED_BY ;;
  }

  dimension: expense_category {
    type: string
    label: "Expense Category"
    sql: ${TABLE}.EXPENSE_CATEGORY ;;
  }

  dimension: glaccount {
    type: string
    label: "GL Account"
    sql: ${TABLE}.GLACCOUNT ;;
  }

  dimension: item {
    type: string
    label: "Item"
    sql: ${TABLE}.ITEM ;;
  }

  dimension: location {
    type: string
    label: "Location"
    sql: ${TABLE}.LOCATION ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      expense_line_id,
      expense_line,
      updated_at_raw,
      updated_by,
      expense_category,
      glaccount,
      item,
      location
    ]
  }
}
