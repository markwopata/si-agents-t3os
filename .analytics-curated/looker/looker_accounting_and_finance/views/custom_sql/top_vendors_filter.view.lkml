view: top_vendors_filter {
  derived_table: {
    sql: SELECT VENDOR_ID,
CASE WHEN  COUNT(DISTINCT LOCATION_NAME) = 0 THEN 'No Cost Centers'
WHEN COUNT(DISTINCT LOCATION_NAME) = 1 THEN '1 Cost Center'
WHEN COUNT(DISTINCT LOCATION_NAME) > 1 THEN 'Multiple Cost Centers'
END AS COST_CENTER_FILTER
FROM ANALYTICS.TREASURY.TOP_VENDORS
WHERE BILL_DATE::DATE >= '2023-01-01'
GROUP BY VENDOR_ID;;
  }


  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: cost_center_filter {
    type: string
    sql: ${TABLE}.COST_CENTER_FILTER ;;
  }

  }
