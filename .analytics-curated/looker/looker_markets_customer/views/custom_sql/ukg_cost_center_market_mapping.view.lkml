view: ukg_cost_center_market_mapping {
  derived_table: {
    sql: SELECT DISTINCT CCM._COST_CENTERS_FULL_PATH AS COST_CENTERS_FULL_PATH,  CCM.INTAACT_CODE AS INTAACT_CODE, M.NAME AS MARKET_NAME
FROM ANALYTICS.PAYROLL.UKG_COST_CENTER_MARKET_ID_MAPPING AS  CCM
LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS M
ON CCM.INTAACT_CODE = M.MARKET_ID
WHERE CCM.INTAACT_CODE <> 'CORP1';;
  }

  dimension: cost_centers_full_path {
    type: string
    sql: ${TABLE}."COST_CENTERS_FULL_PATH"  ;;
  }

  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE"  ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME"  ;;
  }


  }
