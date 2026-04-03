view: backlog_changes {
  derived_table: {
    sql: WITH BACKLOG_CTE AS (
SELECT  SUPPLIER_INVOICE_NUMBER,SUPPLIER_CODE,EMPLOYEE_LAST_NAME,REQUEST_NAME,INVOICE_RECEIVED,
COGNOS_DATE::DATE AS COGNOS_DATE,
IFF(EMPLOYEE_LAST_NAME IS NULL,SUPPLIER_INVOICE_NUMBER||'-'||SUPPLIER_CODE||'-'||REQUEST_NAME||'-'||INVOICE_RECEIVED,
SUPPLIER_INVOICE_NUMBER||'-'||SUPPLIER_CODE||'-'||EMPLOYEE_LAST_NAME||'-'||REQUEST_NAME||'-'||INVOICE_RECEIVED) AS KEY,
SUM(REQUEST_TOTAL) AS REQUEST_TOTAL
FROM ANALYTICS.TREASURY.V_UNSUBMITTED_INVOICES
WHERE COGNOS_DATE::DATE IN (DATEADD(DAY,-1,IFNULL('2023-03-09',CURRENT_TIMESTAMP())),IFNULL('2023-03-09',CURRENT_TIMESTAMP()))
GROUP BY SUPPLIER_INVOICE_NUMBER, SUPPLIER_CODE, EMPLOYEE_LAST_NAME, REQUEST_NAME,INVOICE_RECEIVED,COGNOS_DATE::DATE),
BACKLOG_COUNT_CTE AS (
SELECT KEY, COUNT(KEY) AS CNT
FROM BACKLOG_CTE
GROUP BY KEY)
SELECT B.*,
CASE WHEN C.CNT = 1 AND B.COGNOS_DATE = DATEADD(DAY,-1,IFNULL('2023-03-09',CURRENT_TIMESTAMP())) THEN 'Cleared'
WHEN C.CNT = 1 AND B.COGNOS_DATE = IFNULL('2023-03-09',CURRENT_TIMESTAMP()) THEN 'New'
WHEN C.CNT = 2 THEN 'Existing'
ELSE 'Research' END AS BACKLOG_STATUS
FROM BACKLOG_CTE AS B
LEFT JOIN BACKLOG_COUNT_CTE AS C ON B.KEY = C.KEY
                ;;
  }

  filter: cognos_date_filter {
    type: date
  }

  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}.SUPPLIER_INVOICE_NUMBER ;;
  }

  dimension: supplier_code {
    type: string
    sql: ${TABLE}.SUPPLIER_CODE ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_LAST_NAME ;;
  }

  dimension: request_name {
    type: string
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: invoice_received {
    type: string
    sql: ${TABLE}.INVOICE_RECEIVED ;;
  }

  dimension: cognos_date {
    type: date
    sql: ${TABLE}.COGNOS_DATE ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.KEY ;;
  }

  dimension: backlog_status {
    type: string
    sql: ${TABLE}.BACKLOG_STATUS ;;
  }

  measure: request_total {
    type: sum
    sql: ${TABLE}.REQUEST_TOTAL ;;
  }

measure: count {
  type: count
}

}
