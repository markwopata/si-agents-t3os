view: parent_market {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."PARENT_MARKET" ;;
  drill_fields: [parent_market_id]

  dimension: parent_market_id {
    type: number
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }
  dimension: end {
    type: date_raw
    sql: ${TABLE}."END_DATE" ;;
    hidden: yes
  }
  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: start {
    type: date_raw
    sql: ${TABLE}."START_DATE" ;;
    hidden: yes
  }
  measure: count {
    type: count
    drill_fields: [parent_market_id]
  }
}
