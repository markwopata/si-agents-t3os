view: bridge_quote_salesperson {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_BRIDGE_QUOTE_SALESPERSON" ;;

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension: quote_key {
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
    hidden: yes
  }

  dimension: quote_salesperson_key {
    type: string
    sql: ${TABLE}."QUOTE_SALESPERSON_KEY" ;;
    hidden: yes
  }

# In bridge_salesperson view
  dimension: salesperson_name {
    type: string
    sql: ${salesperson.user_full_name} ;;
    # This will only show users who exist in the bridge
  }

  dimension: salesperson_key {
    type: string
    sql: ${TABLE}."SALESPERSON_KEY" ;;
    hidden: yes
  }

  dimension: salesperson_type {
    type: string
    sql: ${TABLE}."SALESPERSON_TYPE" ;;
  }

  dimension: salesperson_user_key {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_KEY" ;;
    hidden: yes
  }

  measure: count {
    type: count
  }
}
