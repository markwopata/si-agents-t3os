view: sage_department_expense_line_relationships {
  derived_table: {
    sql:
  SELECT
  EXPENSE_LINE                                                       AS EXPENSE_LINE,
  TRY_CAST(CASE WHEN DIMENSION = 'DEPARTMENT' THEN VALUE END AS INT) AS DEPARTMENT,
  TRY_CAST(CASE WHEN DIMENSION = 'GLACCOUNT' THEN VALUE END AS INT)  AS GLACCOUNT,
  _ES_UPDATE_TIMESTAMP                                               AS ES_UPDATE_TIMESTAMP
FROM
  ANALYTICS.INTACCT.EXPENSE_LINE_MAPPING_E1
  WHERE DIMENSION IN ('GLACCOUNT', 'DEPARTMENT')
  AND GLACCOUNT IS NOT NULL OR DEPARTMENT IS NOT NULL
ORDER BY
  DEPARTMENT ASC NULLS LAST,
  GLACCOUNT ASC NULLS LAST ;;
  }

  dimension: expense_line {
    type: string
    label: "Expense Line"
    sql: ${TABLE}.EXPENSE_LINE ;;
  }

  dimension: department {
    type: string
    label: "Department"
    sql: ${TABLE}.DEPARTMENT ;;
  }

  dimension: glaccount {
    type: string
    label: "GL Account"
    sql: ${TABLE}.GLACCOUNT ;;
  }

  dimension_group: es_update_timestamp {
    type: time
    sql: ${TABLE}.ES_UPDATE_TIMESTAMP ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      expense_line,
      department,
      glaccount,
      es_update_timestamp_time,
    ]
  }
 }
