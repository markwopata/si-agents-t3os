view: rental_alerts {


  derived_table: {
    sql:

-- No utilization due to tracker having ble ability
-- No utilization due to tracker having location only ability
-- No tracker installed
-- No utilization due to tracker having undefined ability
-- show utilization
-- No utilization due to last location check in over 120 hours

-- Average Utilization
-- Higher Utilization
-- Lower Utilization
-- No Utilization Reported
-- Class Does Not Report Utilization


SELECT
*
FROM
business_intelligence.triage.stg_t3__geofence_asset_usage gau
LEFT JOIN
(
SELECT ASSET_ID, CLASS_UTILIZATION_COMPARISON FROM  business_intelligence.triage.stg_t3__on_rent r
GROUP BY 1,2
) X USING(ASSET_ID)
WHERE X.CLASS_UTILIZATION_COMPARISON IN ('Lower Utilization', 'No Utilization Reported')
AND gau.company_id = 109154
          ;;
  }



  dimension: asset_id { type: number sql: ${TABLE}.ASSET_ID ;; }

  measure: distinct_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    value_format_name: decimal_0
  }



}
