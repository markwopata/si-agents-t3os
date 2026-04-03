view: tracker_type_buckets {

  derived_table: {
    sql:
WITH MAIN_QUERY AS (
SELECT T.TRACKER_ID,T.DEVICE_SERIAL,
CASE WHEN TT.NAME = 'MC-4+' AND MPT.DEVICE_TYPE IS NULL THEN 'MC-4+/KORE'
WHEN TT.NAME = 'MC-4+' AND MPT.DEVICE_TYPE IS NOT NULL THEN 'MC-4+/TWILIO'
ELSE TT.NAME END AS TRACKER_TYPE, ASKV.VALUE_TIMESTAMP::DATE as OOL_DATE,
TIMESTAMPDIFF( DAY , ASKV.VALUE_TIMESTAMP , CURRENT_TIMESTAMP ) AS DAYS_OOL,
CASE WHEN DAYS_OOL = 0 THEN '< 1 Day'
WHEN DAYS_OOL = 1 THEN '1 Day'
WHEN DAYS_OOL = 2 THEN '2 Days'
WHEN DAYS_OOL = 3 THEN '3 Days'
WHEN DAYS_OOL = 4 THEN '4 Days'
WHEN DAYS_OOL = 5 THEN '5 Days'
WHEN DAYS_OOL = 6 THEN '6 Days'
WHEN DAYS_OOL = 7 THEN '1 Week'
WHEN DAYS_OOL BETWEEN 8 AND 14 THEN '2 Weeks'
WHEN DAYS_OOL BETWEEN 15 AND 21 THEN '3 Weeks'
WHEN DAYS_OOL BETWEEN 22 AND 28 THEN '4 Weeks'
WHEN DAYS_OOL > 28 THEN '> 4 Weeks' ELSE 'Not OOL' END AS OOL_BUCKET,
CASE WHEN DAYS_OOL = 0 THEN 1
WHEN DAYS_OOL = 1 THEN 2
WHEN DAYS_OOL = 2 THEN 3
WHEN DAYS_OOL = 3 THEN 4
WHEN DAYS_OOL = 4 THEN 5
WHEN DAYS_OOL = 5 THEN 6
WHEN DAYS_OOL = 6 THEN 7
WHEN DAYS_OOL = 7 THEN 8
WHEN DAYS_OOL BETWEEN 8 AND 14 THEN 9
WHEN DAYS_OOL BETWEEN 15 AND 21 THEN 10
WHEN DAYS_OOL BETWEEN 22 AND 28 THEN 11
WHEN DAYS_OOL > 28 THEN 12 ELSE 13 END AS OOL_BUCKET_SORT
FROM ES_WAREHOUSE.PUBLIC.TRACKERS AS T
LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKER_TYPES AS TT ON T.TRACKER_TYPE_ID = TT.TRACKER_TYPE_ID
LEFT JOIN ANALYTICS.PUBLIC.MC4_PLUS_TWILIO AS MPT ON T.DEVICE_SERIAL = MPT.MOREY_SN
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS A ON T.TRACKER_ID = A.TRACKER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES AS ASKV ON A.ASSET_ID = ASKV.ASSET_ID
WHERE TT.NAME IN ('MC-4+','FJ2500LA','FJ2500LS','MC-4','MCX 101','TTU 2830','LMU 3030','GL500M','GL520M')
AND LOWER(ASKV.NAME) = 'out_of_lock')
SELECT TRACKER_ID,TRACKER_TYPE,OOL_DATE,CASE WHEN TRACKER_TYPE = 'MC-4+/KORE' THEN 1 ELSE 0 END AS MC4PLUSKORE,
CASE WHEN TRACKER_TYPE = 'MC-4+/TWILIO' THEN 1 ELSE 0 END AS MC4PLUSTWILIO,
CASE WHEN TRACKER_TYPE = 'MC-4' THEN 1 ELSE 0 END AS MC4,
CASE WHEN TRACKER_TYPE = 'FJ2500LA' THEN 1 ELSE 0 END AS FJ2500LA,
CASE WHEN TRACKER_TYPE = 'FJ2500LS' THEN 1 ELSE 0 END AS FJ2500LS,
CASE WHEN TRACKER_TYPE = 'MCX 101'THEN 1 ELSE 0 END AS MCX101,
CASE WHEN TRACKER_TYPE = 'TTU 2830' THEN 1 ELSE 0 END AS TTU2830,
CASE WHEN TRACKER_TYPE = 'LMU 3030' THEN 1 ELSE 0 END AS LMU3030,
CASE WHEN TRACKER_TYPE = 'GL500M' THEN 1 ELSE 0 END AS GL500M,
CASE WHEN TRACKER_TYPE = 'GL520M' THEN 1 ELSE 0 END AS GL520M,
OOL_BUCKET,  OOL_BUCKET_SORT
FROM MAIN_QUERY
WHERE OOL_BUCKET NOT IN ('NOT OOL','GREATER THAN 4 WEEKS')
ORDER BY TRACKER_TYPE, OOL_BUCKET_SORT
                         ;;
  }

  dimension: tracker_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.TRACKER_ID ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}.TRACKER_TYPE ;;
  }

  dimension: ool_bucket {
    type: string
    sql: ${TABLE}.OOL_BUCKET ;;
  }

  dimension: ool_bucket_sort {
    type: number
    sql: ${TABLE}.OOL_BUCKET_SORT ;;
  }

  dimension: ool_date {
    type: date
    sql: ${TABLE}.OOL_DATE ;;
  }


  dimension: mc4pluskore {
    type: string
    sql: ${TABLE}.MC4PLUSKORE ;;
  }

  dimension: mc4plustwilio {
    type: string
    sql: ${TABLE}.MC4PLUSTWILIO ;;
  }

  dimension: mc4 {
    type: string
    sql: ${TABLE}.MC4 ;;
  }

  dimension:  fj2500la {
    type: string
    sql: ${TABLE}.FJ2500LA ;;
  }

  dimension:  fj2500ls {
    type: string
    sql: ${TABLE}.FJ2500LS ;;
  }

  dimension: mcx101 {
    type: string
    sql: ${TABLE}.MCX101 ;;
  }

  dimension: ttu2830 {
    type: string
    sql: ${TABLE}.TTU2830 ;;
  }

  dimension:  lmu3030 {
    type: string
    sql: ${TABLE}.LMU3030 ;;
  }

  dimension:  gl500m {
    type: string
    sql: ${TABLE}.GL500M ;;
  }

  dimension:  gl520m {
    type: string
    sql: ${TABLE}.GL520M ;;
  }

  measure: mc4pluskore_count {
    type: sum
    value_format: "#,##0"
    sql: ${mc4pluskore} ;;
  }

  measure: mc4plustwilio_count {
    type: sum
    value_format: "#,##0"
    sql: ${mc4plustwilio} ;;
  }

  measure: mc4_count {
    type: sum
    value_format: "#,##0"
    sql: ${mc4} ;;
  }

  measure: fj2500la_count {
    type: sum
    value_format: "#,##0"
    sql: ${fj2500la} ;;
  }

  measure: fj2500ls_count  {
    type: sum
    value_format: "#,##0"
    sql: ${fj2500ls} ;;
  }

  measure: mcx101_count  {
    type: sum
    value_format: "#,##0"
    sql: ${mcx101} ;;
  }

  measure: ttu2830_count {
    type: sum
    value_format: "#,##0"
    sql: ${ttu2830} ;;
  }

  measure: lmu3030_count  {
    type: sum
    value_format: "#,##0"
    sql: ${lmu3030} ;;
  }

  measure: gl500m_count  {
    type: sum
    value_format: "#,##0"
    sql: ${gl500m} ;;
  }

  measure: gl520m_count  {
    type: sum
    value_format: "#,##0"
    sql: ${gl520m} ;;
  }

  }
