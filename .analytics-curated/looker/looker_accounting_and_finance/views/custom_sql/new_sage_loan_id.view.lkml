view: new_sage_loan_id {
  derived_table: {
    sql:
SELECT --NAME, SUBSTR(NAME, 6, len(TRIM(NAME)) - 5), SUBSTR(NAME,1,4)
('2500-0'||(MAX(SUBSTR(NAME, 6, len(TRIM(NAME)) - 5)) + 1)::NUMERIC)::STRING AS SAGE_LOAN_ID
FROM ANALYTICS.INTACCT.UD_LOAN
WHERE SUBSTR(NAME,1,4) = '2500'
AND SUBSTR(NAME, 6, len(TRIM(NAME)) - 5) <> '99999'
                      ;;
  }
  dimension: sage_loan_id {
    description: "This is the next sage loan id that should be used in custom dimensions."
    type: string
    sql: ${TABLE}.sage_loan_id ;;
  }
}
