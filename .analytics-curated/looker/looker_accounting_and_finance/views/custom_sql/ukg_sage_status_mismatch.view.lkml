view: ukg_sage_status_mismatch {
  derived_table: {
    sql: WITH DEPT AS (
    SELECT
        TO_VARCHAR(DEPARTMENTID) AS SAGE_ID,
        TITLE AS SAGE_NAME,
        STATUS AS SAGE_STATUS
    FROM
        ANALYTICS.INTACCT.DEPARTMENT
),
COMPCC AS (
    SELECT
        TO_VARCHAR(INTAACT) AS UKG_ID,
        REVERSE(LEFT(REVERSE(FULL_NAME), CHARINDEX('/', REVERSE(FULL_NAME)) - 1)) AS UKG_NAME,
        LEVEL,
        CASE IS_VISIBLE
            WHEN 'Y' THEN 'active'
            WHEN 'N' THEN 'inactive'
        END AS UKG_STATUS
    FROM
        ANALYTICS.PAYROLL.UKG_ALL_COMPANY_COST_CENTERS
)
SELECT
    COMPCC.UKG_ID AS COST_CENTER_ID,
    COMPCC.UKG_NAME,
    DEPT.SAGE_NAME,
    COMPCC.UKG_STATUS,
    DEPT.SAGE_STATUS
FROM
    COMPCC
LEFT JOIN
    DEPT ON COMPCC.UKG_ID = DEPT.SAGE_ID
WHERE
    COMPCC.LEVEL = 4
--AND (UKG_NAME != SAGE_NAME OR (UKG_NAME = SAGE_NAME AND UKG_ID != SAGE_ID))
AND (UKG_STATUS = 'active' AND SAGE_STATUS = 'inactive');;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: COST_CENTER_ID {
    type: number
    label: "Cost Center ID"
    sql: ${TABLE}."COST_CENTER_ID" ;;
  }

  dimension: UKG_NAME {
    type: string
    label: "UKG Account Name"
    sql: ${TABLE}."UKG_NAME" ;;
  }

  dimension: SAGE_NAME {
    type: string
    label: "Sage Intacct Account Name"
    sql: ${TABLE}."SAGE_NAME" ;;
  }

  dimension: UKG_STATUS {
    type: string
    label: "UKG Account Status"
    sql: ${TABLE}."UKG_STATUS" ;;
  }

  dimension: SAGE_STATUS {
    type: string
    label: "Sage Intacct Account Status"
    sql: ${TABLE}."SAGE_STATUS" ;;
  }


  set: detail {
    fields: [
      COST_CENTER_ID,
      UKG_NAME,
      SAGE_NAME,
      UKG_STATUS,
      SAGE_STATUS
    ]
  }
}
