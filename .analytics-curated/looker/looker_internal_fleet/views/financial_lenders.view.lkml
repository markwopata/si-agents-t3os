view: financial_lenders {
  sql_table_name: "PUBLIC"."FINANCIAL_LENDERS"
    ;;
  drill_fields: [financial_lender_id]

  dimension: financial_lender_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."FINANCIAL_LENDER_ID" ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [financial_lender_id, name]
  }
}
