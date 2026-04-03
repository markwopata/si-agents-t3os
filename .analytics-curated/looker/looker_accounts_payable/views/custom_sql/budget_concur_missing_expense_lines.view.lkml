view: budget_concur_missing_expense_lines {
  derived_table: {
    sql: SELECT
          INT_EXP_LINE.ID   AS                                              EXPENSE_LINE_ID,
          INT_EXP_LINE.NAME AS                                              EXPENSE_LINE_NAME,
          CASE WHEN CONC_EXP_LINE.LIST_KEY IS NULL THEN 'No' ELSE 'Yes' END IN_CONCUR
      FROM
          ANALYTICS.INTACCT.EXPENSE_LINE INT_EXP_LINE
              LEFT JOIN ANALYTICS.CONCUR.CONCUR_EXPENSE_LINES CONC_EXP_LINE
                        ON INT_EXP_LINE.ID = CONC_EXP_LINE.LIST_ITEM_SHORT_CODE
      WHERE
          IN_CONCUR = 'No'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: expense_line_id {
    type: number
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: expense_line_name {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_NAME" ;;
  }

  dimension: in_concur {
    type: string
    sql: ${TABLE}."IN_CONCUR" ;;
  }

  set: detail {
    fields: [expense_line_id, expense_line_name, in_concur]
  }
}
