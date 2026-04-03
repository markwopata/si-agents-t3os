view: customer_master {
  sql_table_name: "FINANCIAL_SYSTEMS"."T3_SAAS_GOLD"."CUSTOMER_MASTER" ;;

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}."PK_COMPANY_ID" ;;
  }
  dimension: COMPANY_NAME {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}."DATE_INVOICED" ;;
  }
  dimension: PO_REFERENCE {
    type: string
    sql: ${TABLE}."PO_REFERENCE" ;;
  }
  dimension: CHARGE_TYPE {
    type: string
    sql: ${TABLE}."CHARGE_TYPE" ;;
  }
  dimension: QTY {
    type: number
    sql: ${TABLE}."QTY" ;;
  }
  dimension: INVOICE_LINE_TOTAL {
    type: number
    sql: ${TABLE}."INVOICE_LINE_TOTAL" ;;
  }
  dimension: CUSTOMER_BILLING_DESIGNATION {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_DESIGNATION" ;;
  }
  dimension: CUSTOMER_BILLING_STATUS {
    type: string
    sql: ${TABLE}."CUSTOMER_BILLING_STATUS" ;;
  }
  dimension: DATE_VALIDATED {
    type: date
    sql: ${TABLE}."DATE_VALIDATED" ;;
  }
  dimension: AUTO_BILLING_STATUS {
    type: string
    sql: ${TABLE}."AUTO_BILLING_STATUS" ;;
  }
  dimension: REGION {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: SHIP_TO_LOCATION_ID {
    type: string
    sql: ${TABLE}."FK_SHIP_TO_LOCATION_ID" ;;
  }
  dimension: SHIP_TO_ADDRESS {
    type: string
    sql: ${TABLE}."SHIP_TO_ADDRESS" ;;
  }
  ##uncomment this once dbt model updated
  ##dimension: state {
    ##type: string
    ##sql: ${TABLE}."STATE" ;;
  ##}
  dimension: LATITUDE {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }
  dimension: LONGITUDE {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }
  dimension: SHIP_TO_ADDRESS_LOC {
    type: location
    sql_latitude:${TABLE}.LATITUDE ;;
    sql_longitude:${TABLE}.LONGITUDE ;;
  }
}
