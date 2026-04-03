view: parent_market {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."PARENT_MARKET"
    ;;
  drill_fields: [parent_market_id]

  dimension: parent_market_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension_group: end {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [parent_market_id]
  }
}
