view: contractor_owned_es_rental_fleet {

  derived_table: {
    sql:
      SELECT P.ASSET_ID AS ASSET_ID, COALESCE(AA.SERIAL_NUMBER,AA.VIN) AS SERIAL_VIN ,AA.COMPANY_ID AS COMPANY_ID, AA.OWNER AS OWNER, AA.YEAR AS YEAR, AA.MAKE AS MAKE, AA.MODEL AS MODEL,
M.NAME AS BRANCH, AA.CATEGORY AS CATEGORY
FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS AS P
INNER JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
ON P.ASSET_ID = AA.ASSET_ID
INNER JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS A
ON AA.ASSET_ID = A.ASSET_ID
INNER JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS M
ON COALESCE(A.RENTAL_BRANCH_ID,A.INVENTORY_BRANCH_ID) = M.MARKET_ID
WHERE AA.COMPANY_ID NOT IN (1854,1855)
AND P.END_DATE IS NULL
                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.SERIAL_VIN ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}.OWNER ;;
  }

  dimension:  year {
    type: number
    sql: ${TABLE}.YEAR ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}.BRANCH ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.CATEGORY ;;
  }

  }
