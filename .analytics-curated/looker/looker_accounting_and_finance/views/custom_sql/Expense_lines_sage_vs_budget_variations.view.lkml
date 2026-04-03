view: expense_lines_sage_vs_budget_variations {
  derived_table: {
    sql: WITH sage AS (
    SELECT
        m.VALUE AS SUB_DEPARTMENT_ID,
        d.TITLE AS SUB_DEPARTMENT_NAME,
        e.ID AS EXPENSE_LINE_ID,
        m.EXPENSE_LINE AS EXPENSE_LINE_NAME,
        '2026' AS BUDGET_YEAR,
        COUNT(DISTINCT m.VALUE) OVER (PARTITION BY e.ID) AS department_count,
        CONCAT('2026', '.', e.ID, '.', m.VALUE) AS ID
    FROM ANALYTICS.INTACCT.EXPENSE_LINE_MAPPING_E1 m
    LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE e ON m.EXPENSE_LINE = e.NAME
    LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT d ON m.VALUE = d.DEPARTMENTID
    WHERE m.DIMENSION = 'DEPARTMENT'
      AND (e.EXPENSE_LINE_DISCONTINUED = FALSE OR e.EXPENSE_LINE_DISCONTINUED IS NULL)
),
consolidated AS (
    SELECT DISTINCT
        CASE
            WHEN department_count > 600 THEN 'Un-restricted'
            ELSE SUB_DEPARTMENT_ID
        END AS SUB_DEPARTMENT_ID,
        CASE
            WHEN department_count > 600 THEN ''
            ELSE SUB_DEPARTMENT_NAME
        END AS SUB_DEPARTMENT_NAME,
        EXPENSE_LINE_ID,
        EXPENSE_LINE_NAME,
        BUDGET_YEAR,
        CASE
            WHEN department_count > 600 THEN CONCAT('2026', '.', EXPENSE_LINE_ID, '.Un-restricted')
            ELSE ID
        END AS ID
    FROM sage
),
budget AS (
    SELECT
        SUB_DEPARTMENT_ID,
        SUB_DEPARTMENT_NAME,
        EXPENSE_LINE_ID,
        EXPENSE_LINE_NAME,
        BUDGET_YEAR,
        CONCAT(BUDGET_YEAR, '.', EXPENSE_LINE_ID, '.', SUB_DEPARTMENT_ID) AS BUDGET_ID
    FROM ANALYTICS.CORPORATE_BUDGET.APPROVED_BUDGETS
    WHERE BUDGET_YEAR = 2026
)
SELECT c.*
FROM consolidated c
LEFT JOIN budget b ON c.ID = b.BUDGET_ID
WHERE b.BUDGET_ID IS NULL
ORDER BY SUB_DEPARTMENT_ID DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: SUB_DEPARTMENT_ID {
    type: string
    label: "Sub Department ID"
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: SUB_DEPARTMENT_NAME {
    type: string
    label: "Sub Department Name"
    sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;
  }

  dimension: EXPENSE_LINE_ID {
    type: number
    label: "Expense Line ID"
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: EXPENSE_LINE_NAME {
    type: string
    label: "Expense Line Name"
    sql: ${TABLE}."EXPENSE_LINE_NAME" ;;
  }

  dimension: BUDGET_YEAR {
    type: string
    label: "Budget Year"
    sql: ${TABLE}."BUDGET_YEAR" ;;
  }

  dimension: ID {
    type: string
    label: "ID"
    sql: ${TABLE}."ID" ;;
  }

  set: detail {
    fields: [
      SUB_DEPARTMENT_ID,
      SUB_DEPARTMENT_NAME,
      EXPENSE_LINE_ID,
      EXPENSE_LINE_NAME,
      BUDGET_YEAR,
      ID
    ]
  }
}
