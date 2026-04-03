view: fleet_qbr_markets_monday {
  derived_table: {
    sql:
        Select
        monday_market_id,
        es_market_id,
        market_name,
        status_group,
        division,
        region,
        district,
        target_first_rental_date,
        launch_phase,
        usable_acres,
        status_group_numeric
        from fleet_optimization.gold.dim_monday_markets
          ;;
  }

  dimension: monday_market_id {
    type: number
    primary_key: yes
    hidden: yes
    description: "Monday.com ID field, one id/name per row"
    sql:  ${TABLE}."MONDAY_MARKET_ID" ;;
  }

  dimension: es_market_id {
    type: number
    description: "EquipmentShare market_id, will be null until assigned. Foreign key to tables using market_id"
    sql: ${TABLE}."ES_MARKET_ID" ;;
  }

  dimension: market_name {
    type:  string
    description: "market name - one row per market"
    sql:${TABLE}."MARKET_NAME";;
  }

  dimension_group: target_first_rental {
    type: time
    description: "date grouping for target first rental dates"
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TARGET_FIRST_RENTAL_DATE" ;;
  }

  dimension: status_group {
    type: string
    description: "progress stage for each real estate transaction"
    sql: ${TABLE}."STATUS_GROUP" ;;
  }

  dimension: division {
    type: string
    description: "type of market (Core, Advanced, Tooling, etc.)"
    sql: ${TABLE}."DIVISION" ;;
  }

  dimension: region {
    type: string
    description: "numeric region of proposed market (stored as varchar)"
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    description: "numeric district of proposed market (stored as varchar)"
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: launch_phase {
    type: string
    description: "property acquisition status"
    sql: ${TABLE}."LAUNCH_PHASE" ;;
  }

  dimension: group_for_sorting {
    type: number
    description: "ordered group stage to sort by property's stage in process rather than alphabetically"
    sql: ${TABLE}."STATUS_GROUP_NUMERIC" * 2 ;;
  }

  measure: usable_acres {
    type: sum
    description: "lot acreage for proposed property available to store rental assets"
    value_format: "#,##0.0"
    sql: ${TABLE}."USABLE_ACRES" ;;
  }



}
