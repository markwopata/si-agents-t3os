view: net_terms {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."NET_TERMS"
    ;;
  drill_fields: [net_terms_id]

  dimension: net_terms_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."NET_TERMS_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: days {
    type: number
    sql: ${TABLE}."DAYS" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [net_terms_id, name]
  }
}
