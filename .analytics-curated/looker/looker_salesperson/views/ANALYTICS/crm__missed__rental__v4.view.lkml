view: crm__missed__rental__v4 {
  sql_table_name: "ANALYTICS"."WEBAPPS"."CRM__MISSED__RENTAL__V4"
    ;;

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: deal_length {
    type: string
    sql: ${TABLE}."DEAL_LENGTH" ;;
  }

  dimension: deal_lost_reason {
    type: string
    sql: ${TABLE}."DEAL_LOST_REASON" ;;
  }

  dimension: equipment_missed {
    type: string
    sql: ${TABLE}."EQUIPMENT_MISSED" ;;
  }

  dimension: market_lost {
    type: string
    # suggest_persist_for: "5 minutes"
    sql: ${TABLE}."MARKET_LOST" ;;
  }

  dimension: missed_rental_id {
    type: number
    sql: ${TABLE}."MISSED_RENTAL_ID" ;;
  }

  dimension: daily_rates {
    type: string
    sql: ${TABLE}."DAILY_RATES" ;;
  }

  dimension: weekly_rates {
    type: string
    sql: ${TABLE}."WEEKLY_RATES" ;;
  }

  dimension: monthly_rates {
    type: string
    sql: ${TABLE}."MONTHLY_RATES" ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}."SALES_REPRESENTATIVE_EMAIL_ADDRESS" ;;
  }

  dimension_group: timestamp {
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
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_name]
  }
}
