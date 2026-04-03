view: comp_geocode_address {
  derived_table: {
    sql:  WITH HUBSPOT AS (
SELECT D.DEAL_ID AS DEAL_ID, D.PROPERTY_DEALNAME AS PROPERTY_DEALNAME,
COALESCE(D.PROPERTY_PROPERTY_LATITUDE,DLL.LATITUDE) AS DEAL_LATITUDE,
COALESCE(D.PROPERTY_PROPERTY_LONGITUDE,DLL.LONGITUDE) AS DEAL_LONGITUDE
FROM ANALYTICS.HUBSPOT.DEAL AS D
LEFT JOIN ANALYTICS.HUBSPOT.DEAL_LAT_LON AS DLL
ON D.DEAL_ID = DLL.DEAL_ID
)
SELECT C.COMPETITOR AS COMPETITOR, C.STREET AS STREET, C.CITY AS CITY, C.STATE AS STATE, C.ZIP AS ZIP,
C.LATITUDE AS COMP_LATITUDE, C.LONGITUDE AS COMP_LONGITUDE ,H.DEAL_ID AS DEAL_ID, H.PROPERTY_DEALNAME AS PROPERTY_DEALNAME,
H.DEAL_LATITUDE AS DEAL_LATITUDE, H.DEAL_LONGITUDE AS DEAL_LONGITUDE,
HAVERSINE(C.LATITUDE,C.LONGITUDE,H.DEAL_LATITUDE,H.DEAL_LONGITUDE)/1.60934 AS MILES
FROM ANALYTICS.PUBLIC.COMP_GEOCODE AS C, HUBSPOT AS H

                                     ;;
  }

  dimension: competitor {
    type: string
    sql: ${TABLE}."COMPETITOR" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: comp_latitude {
    type: number
    sql: ${TABLE}."COMP_LATITUDE" ;;
  }

  dimension: comp_longitude {
    type: number
    sql: ${TABLE}."COMP_LONGITUDE" ;;
  }

  dimension: deal_id {
    type: number
    sql: ${TABLE}."DEAL_ID" ;;
  }

  dimension: property_dealname {
    type: string
    sql: ${TABLE}."PROPERTY_DEALNAME" ;;
  }

  dimension: deal_latitude {
    type: number
    sql: ${TABLE}."DEAL_LATITUDE" ;;
  }

  dimension: deal_longitude {
    type: number
    sql: ${TABLE}."DEAL_LONGITUDE" ;;
  }


  dimension: miles {
    type: number
    sql: ${TABLE}."MILES" ;;
  }

  measure: comp_count {
    type: count_distinct
    sql: ${miles} ;;
  }





}
