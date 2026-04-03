view: market_collector_assignments {
  derived_table: {
    sql: SELECT DISTINCT
          CCA.COMPANY_ID,
          CCA.COMPANY_NAME,
          CCA.FINAL_COLLECTOR,
          CCA.MARKET_ID,
          CCA.MARKET_NAME,
          CCA.MARKET_COLLECTOR,
          CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS "MARKET",
          CCA.COLLECTOR_EXCEPTION,
          CCA.PRE_LEGAL_COLLECTOR,
          CCA.INSIDE_COLLECTIONS,
          CCA.DIRECT_MANAGER_NAME,
          XW.DISTRICT
      FROM
          ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
      LEFT JOIN
          ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW
              ON CCA.MARKET_ID = XW.MARKET_ID
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_collector {
    type: string
    sql: ${TABLE}."MARKET_COLLECTOR" ;;
  }

  dimension: collector_exception {
    type: string
    sql: ${TABLE}."COLLECTOR_EXCEPTION" ;;
  }

  dimension: pre_legal_collector {
    type: string
    sql: ${TABLE}."PRE_LEGAL_COLLECTOR" ;;
  }

  dimension: inside_collections {
    type: string
    sql: ${TABLE}."INSIDE_COLLECTIONS" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  set: detail {
    fields: [
      company_id,
      company_name,
      final_collector,
      market_id,
      market_name,
      market_collector,
      market,
      collector
    ]
  }
}
