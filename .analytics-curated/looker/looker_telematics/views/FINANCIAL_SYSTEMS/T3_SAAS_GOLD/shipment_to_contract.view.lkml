view: shipment_to_contract {
  sql_table_name: "FINANCIAL_SYSTEMS"."T3_SAAS_GOLD"."SHIPMENT_TO_CONTRACT" ;;

  dimension: SHIPPED_SERIAL_FORMATTED {
    type: string
    sql: ${TABLE}."SHIPPED_SERIAL_FORMATTED" ;;
  }
  dimension: SALES_REF_ID {
    type: string
    sql: ${TABLE}."FK_SALES_REF_ID" ;;
  }
  dimension: CONTRACT_NAME {
    type: string
    sql: ${TABLE}."CONTRACT_NAME" ;;
  }
  dimension: LINKED_DEVICE_TYPE {
    type: string
    sql: ${TABLE}."LINKED_DEVICE_TYPE" ;;
  }
}
