view: historic_vehicle_market {
  derived_table: {
    sql: WITH vehicles as (
    SELECT ASSET_ID
    FROM ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS
    where (ASSET_TYPE = 'vehicle' or ASSET_TYPE = 'trailer')
      AND COMPANY_ID = 1854
)
SELECT v.ASSET_ID as ASSET_ID, ham.MARKET_ID as MARKET_ID, ham.DATE as DATE
FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET ham
join vehicles v on v.ASSET_ID = ham.ASSET_ID ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
  }



 }
