view: fact_quote_customer_conversion {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_QUOTE_CUSTOMER_CONVERSION" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
    hidden: yes
  }

  dimension: converted_date_key {
    type: string
    sql: ${TABLE}."CONVERTED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: converted_time_key {
    type: string
    sql: ${TABLE}."CONVERTED_TIME_KEY" ;;
    hidden: yes
  }

  dimension: quote_customer_key {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
    hidden: yes
  }

  dimension: quote_key {
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
    hidden: yes
  }

  measure: count {
    type: count
  }
}
