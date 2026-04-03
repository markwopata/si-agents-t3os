view: credit_app_master_list {
  sql_table_name: "ANALYTICS"."GS"."CREDIT_APP_MASTER_LIST"
    ;;

  dimension: app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."customer" ;;
  }

  dimension: credit_specialist {
    type: string
    sql: ${TABLE}."CREDIT_SPECIALIST" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }



  dimension_group: date_completed {
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
    sql: ${TABLE}."DATE_COMPLETED"::date;;
  }

  dimension: customer_name_with_link_to_customer_dashboard {
    type: string
    sql: ${customer} ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ customer._filterable_value | url_encode }}&Company%20ID="
    }

  }

  dimension: date_received {
    type: string
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: duns_ {
    type: string
    sql: ${TABLE}."DUNS_#" ;;
  }

  dimension: es_admin_setup {
    type: string
    sql: ${TABLE}."ES_ADMIN_SETUP" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: naics_1 {
    type: string
    sql: ${TABLE}."NAICS_1" ;;
  }

  dimension: naics_2 {
    type: string
    sql: ${TABLE}."NAICS_2" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: ofac {
    type: string
    sql: ${TABLE}."OFAC" ;;
  }

  dimension: sales_person {
    type: string
    sql: ${TABLE}."SALES_PERSON" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sic {
    type: string
    sql: ${TABLE}."SIC" ;;
  }

  dimension: tin {
    type: string
    sql: ${TABLE}."TIN" ;;
  }

  dimension: welcome_letter {
    type: string
    sql: ${TABLE}."WELCOME_LETTER" ;;
  }

  dimension: xero_setup {
    type: string
    sql: ${TABLE}."XERO_SETUP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
