view: customers_no_address_matches_market {
  sql_table_name: "ANALYTICS"."TREASURY"."CUSTOMERS_NO_ADDRESS_MATCHES_MARKET" ;;

##### DIMENSIONS #####

  dimension: billing_address {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS" ;;
  }

  dimension: customer_id {
    label: "Customer ID"
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ customers_no_address_matches_market.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: market_id {
    label: "Market ID"
    value_format_name: id
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }


}
