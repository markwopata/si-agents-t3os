view: market_alerts {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_ALERTS"
    ;;

  dimension: alert {
    type: string
    sql: ${TABLE}."ALERT" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: metric {
    type: number
    sql: ${TABLE}."METRIC" ;;
  }

  dimension: serviced_by {
    type: string
    sql: ${TABLE}."SERVICED_BY" ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.timestamp ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
