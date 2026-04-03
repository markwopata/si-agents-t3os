view: collector_notes {

  derived_table: {
    sql:
    SELECT
      C.DISPLAY_NAME AS COLLECTOR,
      COUNT(CN.COMPANY_NOTE_ID) AS NOTE_COUNT
FROM ES_WAREHOUSE.PUBLIC.COMPANY_NOTES AS CN
INNER JOIN ANALYTICS.BI_OPS.COLLECTORS AS C ON CN.USER_ID = C.USER_ID
WHERE CN.DATE_CREATED::DATE >= '2026-01-01' AND CN.DATE_CREATED::DATE < '2026-04-01'
GROUP BY C.DISPLAY_NAME
      ;;
  }

######### DIMENSIONS #########

  dimension: collector {
    type: string
    sql: ${TABLE}.COLLECTOR ;;
  }

  dimension: note_count {
    value_format_name: decimal_0
    type: number
    sql: ${TABLE}.NOTE_COUNT ;;
  }

  }

