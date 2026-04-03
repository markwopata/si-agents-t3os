view: dodge_proj_cross_join {

  derived_table: {
    sql:
       WITH PROJ AS (
SELECT PC.DR_NBR  , PC.STD_FIPS_CODE , PC.STD_COUNTY_NAME , CC.LATITUDE , CC.LONGITUDE
FROM INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_PROJECT_CAPSULE AS PC
LEFT JOIN INBOUND.DODGE_CONSTRUCTION_VIEW.COUNTIES_COORDINATES AS CC
ON PC.STD_FIPS_CODE = CC.FIPS)
SELECT P.DR_NBR AS DR_NBR, P.STD_FIPS_CODE AS FIPS, P.STD_COUNTY_NAME AS COUNTY, P.LATITUDE AS COUNTY_LATITUDE, P.LONGITUDE AS COUNTY_LONGITUDE,
M.MARKET_ID AS MARKET_ID ,M.LATITUDE AS MARKET_LATITUDE, M.LONGITUDE AS MARKET_LONGITUDE,
HAVERSINE(P.LATITUDE, P.LONGITUDE, M.LATITUDE, M.LONGITUDE)/1.60934 AS MILES
FROM PROJ AS P, ANALYTICS.DODGE.MARKETS_COORDINATES AS M
--WHERE HAVERSINE(P.LATITUDE, P.LONGITUDE, M.LATITUDE, M.LONGITUDE)/1.60934 <= 100

    ;;
  }

  dimension: dr_nbr {
    type: number
    sql: ${TABLE}.DR_NBR ;;
  }

  dimension: fips {
    type: number
    sql: ${TABLE}.FIPS ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}.COUNTY ;;
  }

  dimension: county_latitude {
    type: number
    sql: ${TABLE}.COUNTY_LATITUDE ;;
  }

  dimension: county_longitude {
    type: number
    sql: ${TABLE}.COUNTY_LONGITUDE ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: market_latitude {
    type: number
    sql: ${TABLE}.MARKET_LATITUDE ;;
  }

  dimension: market_longitude {
    type: number
    sql: ${TABLE}.MARKET_LONGITUDE ;;
  }

  dimension: miles {
    type: number
    sql: ${TABLE}.MILES ;;
  }

  }
