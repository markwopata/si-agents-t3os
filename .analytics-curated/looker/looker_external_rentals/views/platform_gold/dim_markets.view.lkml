view: dim_markets {
  sql_table_name: "PLATFORM"."GOLD"."V_MARKETS" ;;

  # PRIMARY KEY
  dimension: market_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: market_source {
    type: string
    sql: ${TABLE}."MARKET_SOURCE" ;;
    description: "Source system for market data"
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    description: "Natural market ID"
    value_format_name: id
  }

  # MARKET DETAILS
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    description: "Market name"
  }

  dimension: market_nickname {
    type: string
    sql: ${TABLE}."MARKET_NICKNAME" ;;
    description: "Market nickname"
  }

  dimension: market_address {
    type: string
    sql: ${TABLE}."MARKET_ADDRESS" ;;
    description: "Market address"
  }

  dimension: market_city {
    type: string
    sql: ${TABLE}."MARKET_CITY" ;;
    description: "Market city"
  }

  dimension: market_state {
    type: string
    sql: ${TABLE}."MARKET_STATE" ;;
    description: "Market state"
  }

  dimension: market_zip {
    type: string
    sql: ${TABLE}."MARKET_ZIP" ;;
    description: "Market ZIP code"
  }

  # MARKET FLAGS
  dimension: market_deleted {
    type: yesno
    sql: ${TABLE}."MARKET_DELETED" ;;
    description: "Market is deleted"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of markets"
    drill_fields: [market_name, market_city, market_state]
  }

  # TIMESTAMP
  dimension_group: market_recordtimestamp {
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
    sql: CAST(${TABLE}."MARKET_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this market record was created"
  }
}
