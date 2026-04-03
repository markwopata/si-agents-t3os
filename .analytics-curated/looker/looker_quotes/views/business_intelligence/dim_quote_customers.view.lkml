view: dim_quote_customers {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_QUOTE_CUSTOMERS" ;;

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

  dimension: quote_company_id {
    type: number
    sql: ${TABLE}."QUOTE_COMPANY_ID" ;;
  }

  dimension: quote_company_key {
    type: string
    sql: ${TABLE}."QUOTE_COMPANY_KEY" ;;
    hidden: yes
  }

  dimension: quote_company_name {
    type: string
    sql: ${TABLE}."QUOTE_COMPANY_NAME" ;;
  }

  dimension: quote_customer_id {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_ID" ;;
  }

  dimension: quote_customer_is_archived {
    type: yesno
    sql: ${TABLE}."QUOTE_CUSTOMER_IS_ARCHIVED" ;;
  }

  dimension: quote_customer_key {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: quote_customer_source {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_SOURCE" ;;
  }

  measure: count {
    type: count
  }
}
