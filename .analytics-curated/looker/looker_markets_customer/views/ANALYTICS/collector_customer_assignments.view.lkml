view: collector_customer_assignments {
  sql_table_name: "ANALYTICS"."GS"."COLLECTOR_CUSTOMER_ASSIGNMENTS"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: active_company {
    type: number
    sql: ${TABLE}."ACTIVE_COMPANY" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
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

  dimension: market_collector {
    type: string
    sql: ${TABLE}."MARKET_COLLECTOR" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: perc_of_rev {
    type: number
    sql: ${TABLE}."PERC_OF_REV" ;;
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: total_ar {
    type: number
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name]
  }
}
