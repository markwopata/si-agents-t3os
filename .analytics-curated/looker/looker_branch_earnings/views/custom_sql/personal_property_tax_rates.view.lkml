view: personal_property_tax_rates {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."PERSONAL_PROPERTY_TAX_RATES"
    ;;

  dimension: end_date {
    type: string
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: monthly_oec_percent {
    type: number
    sql: ${TABLE}."MONTHLY_OEC_PERCENT" ;;
    value_format: "#,##0.0000%;-#,##0.0000%;-"
  }

  dimension: start_date {
    type: string
    sql: ${TABLE}."START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
