view: t3_saas_customer_master {
  derived_table: {
    sql:


select
    PK_COMPANY_ID::TEXT as COMPANY_ID,
    COMPANY_NAME,
    DATE_INVOICED as INVOICE_DATE,
    PO_REFERENCE,
    CHARGE_TYPE,
    QTY,
    INVOICE_LINE_TOTAL,
    CUSTOMER_BILLING_DESIGNATION,
    CUSTOMER_BILLING_STATUS,
    DATE_VALIDATED,
    AUTO_BILLING_STATUS,
    REGION,
    FK_SHIP_TO_LOCATION_ID as SHIP_TO_LOCATION_ID,
    SHIP_TO_ADDRESS,
    STATE,
    LATITUDE,
    LONGITUDE
from
    financial_systems.t3_saas_gold.customer_master

      ;;}

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
    primary_key: yes
  }

  dimension: COMPANY_NAME {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: PO_REFERENCE {
    type: string
    sql: ${TABLE}.PO_REFERENCE ;;
  }

  dimension: CHARGE_TYPE {
    type: string
    sql: ${TABLE}.CHARGE_TYPE ;;
  }

  dimension: QTY {
    type: number
    sql: ${TABLE}.QTY ;;
  }

  dimension: INVOICE_LINE_TOTAL {
    type: number
    sql: ${TABLE}.INVOICE_LINE_TOTAL ;;
  }

  dimension: CUSTOMER_BILLING_DESIGNATION {
    type: string
    sql: ${TABLE}.CUSTOMER_BILLING_DESIGNATION ;;
  }

  dimension: CUSTOMER_BILLING_STATUS {
    type: string
    sql: ${TABLE}.CUSTOMER_BILLING_STATUS ;;
  }

  dimension: DATE_VALIDATED {
    type: date
    sql: ${TABLE}.DATE_VALIDATED ;;
  }

  dimension: AUTO_BILLING_STATUS {
    type: string
    sql: ${TABLE}.AUTO_BILLING_STATUS ;;
  }

  dimension: REGION {
    type: string
    sql: ${TABLE}.REGION ;;
  }

  dimension: SHIP_TO_LOCATION_ID {
    type: string
    sql: ${TABLE}.SHIP_TO_LOCATION_ID ;;
  }

  dimension: SHIP_TO_ADDRESS {
    type: string
    sql: ${TABLE}.SHIP_TO_ADDRESS ;;
  }

  dimension: STATE {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: LATITUDE {
    type: string
    sql: ${TABLE}.LATITUDE ;;
  }

  dimension: LONGITUDE {
    type: string
    sql: ${TABLE}.LONGITUDE ;;
  }

  dimension: SHIP_TO_ADDRESS_LOC {
    type: location
    sql_latitude:${TABLE}.LATITUDE ;;
    sql_longitude:${TABLE}.LONGITUDE ;;
  }

}
