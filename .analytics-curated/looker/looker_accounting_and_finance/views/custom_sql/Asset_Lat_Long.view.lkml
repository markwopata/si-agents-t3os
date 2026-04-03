view: asset_lat_long {
  derived_table: {
    sql:WITH step_1_cte as
(
SELECT
  ASSET_ID,
  0  as LOCATION_ID,
  st_y(to_geography(value)) AS LATITUDE,
  st_x(to_geography(value)) AS LONGITUDE
FROM
  ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
WHERE
  NAME = 'location'
),
step_2_cte as
(
SELECT
  ea.ASSET_ID,
  rla.LOCATION_ID,
  l.LATITUDE,
  l.LONGITUDE
FROM
  ES_WAREHOUSE.PUBLIC.RENTAL_LOCATION_ASSIGNMENTS rla
  JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_ASSIGNMENTS ea
    ON rla.RENTAL_ID = ea.RENTAL_ID
  JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l
    ON rla.LOCATION_ID = l.LOCATION_ID
WHERE
  current_timestamp between ea.START_DATE
  AND coalesce(ea.END_DATE, '2099-12-31')
  AND rla.RENTAL_LOCATION_ASSIGNMENT_ID in
    (SELECT max(RENTAL_LOCATION_ASSIGNMENT_ID)
    FROM ES_WAREHOUSE.PUBLIC.RENTAL_LOCATION_ASSIGNMENTS
    GROUP BY RENTAL_ID)
),
step_3_cte as
(
SELECT
  a.ASSET_ID,
  m.LOCATION_ID,
  l.LATITUDE,
  l.LONGITUDE
FROM
  ES_WAREHOUSE.PUBLIC.ASSETS a
  JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
    ON coalesce(a.RENTAL_BRANCH_ID, a.SERVICE_BRANCH_ID) = m.MARKET_ID
  JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l
    ON m.LOCATION_ID = l.LOCATION_ID
),
combine_cte as
(
SELECT
  a.ASSET_ID,
  coalesce(s1.LOCATION_ID, s2.LOCATION_ID, s3.LOCATION_ID) AS LOCATION_ID,
  l.STREET_1,
  l.STREET_2,
  COALESCE(l.CITY, m.NAME) as city,
  l.ZIP_CODE,
  s.NAME  as state,
  coalesce(s1.LATITUDE, s2.LATITUDE, s3.LATITUDE) AS LATITUDE,
  coalesce(s1.LONGITUDE, s2.LONGITUDE, s3.LONGITUDE)  AS LONGITUDE
FROM
  ES_WAREHOUSE.PUBLIC.ASSETS a
  LEFT JOIN step_1_cte s1
    ON a.ASSET_ID = s1.ASSET_ID
  LEFT JOIN step_2_cte s2
    ON a.ASSET_ID = s2.ASSET_ID
  LEFT JOIN step_3_cte s3
    ON a.ASSET_ID = s3.ASSET_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS l
    ON coalesce(s1.LOCATION_ID, s2.LOCATION_ID, s3.LOCATION_ID) = l.LOCATION_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES s
    ON l.STATE_ID = s.STATE_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
    ON coalesce(a.RENTAL_BRANCH_ID, a.SERVICE_BRANCH_ID) = m.MARKET_ID
WHERE
  a.COMPANY_ID = 1854
)
SELECT *
FROM combine_cte
                  ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}.location_id ;;
  }
  dimension: street_1 {
    type: string
    sql: ${TABLE}.street_1 ;;
  }
  dimension: street_2 {
    type: string
    sql: ${TABLE}.street_2 ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }
  dimension: zip_code {
    type: number
    sql: ${TABLE}.zip_code ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }
  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }
}
