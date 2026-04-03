view: asset_rental_status {
  derived_table: {
    sql:    SELECT
    ASKV.ASSET_ID AS ASSET_ID,
    ASKV.NAME AS NAME,
    ASKV.VALUE AS VALUE,
    COALESCE(AA.SERIAL_NUMBER, AA.VIN) AS SERIAL_VIN,
    AA.YEAR AS YEAR,
    AA.MAKE AS MAKE,
    AA.MODEL AS MODEL,
    AA.RENTAL_BRANCH_ID AS RENTAL_BRANCH_ID,
    M.NAME AS MARKET_NAME,
    AA.CLASS AS EQUIPMENT_CLASS,
    TR.STATUS AS TRANSFER_STATUS
FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES AS ASKV
    ON AA.ASSET_ID = ASKV.ASSET_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS M
    ON AA.RENTAL_BRANCH_ID = M.MARKET_ID
LEFT JOIN (
    SELECT
        ASSET_ID,
        STATUS,
        ROW_NUMBER() OVER (PARTITION BY ASSET_ID ORDER BY _es_update_timestamp DESC) AS rn
    FROM ASSET_TRANSFER.PUBLIC.TRANSFER_ORDERS
) TR
    ON AA.ASSET_ID = TR.ASSET_ID
    AND TR.rn = 1
WHERE lower(ASKV.NAME) LIKE '%asset_inventory_status%'
  AND AA.RENTAL_BRANCH_ID IS NOT NULL
  AND AA.COMPANY_ID IN (1854,1855,55524,6954)
  AND ASKV.VALUE <> 'On Rent';;
  }



  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.EQUIPMENT_CLASS ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.VALUE ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.SERIAL_VIN ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.YEAR;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}.RENTAL_BRANCH_ID ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: transfer_status {
    type: string
    sql: ${TABLE}.TRANSFER_STATUS ;;
  }

  }
