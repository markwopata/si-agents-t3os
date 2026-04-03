view: bridge_quote_salesperson {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."BRIDGE_QUOTE_SALESPERSON" ;;

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
  dimension: quote_key {
    hidden:  yes
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
  }
  dimension: quote_salesperson_key {
    hidden:  yes
    type: string
    sql: ${TABLE}."QUOTE_SALESPERSON_KEY" ;;
  }
  dimension: salesperson_key {
    hidden:  yes
    type: string
    sql: ${TABLE}."SALESPERSON_KEY" ;;
  }
  dimension: salesperson_type {
    type: string
    sql: ${TABLE}."SALESPERSON_TYPE" ;;
  }
  dimension: salesperson_user_key {
    hidden:  yes
    type: string
    sql: ${TABLE}."SALESPERSON_USER_KEY" ;;
  }
  measure: count {
    type: count
  }
}
