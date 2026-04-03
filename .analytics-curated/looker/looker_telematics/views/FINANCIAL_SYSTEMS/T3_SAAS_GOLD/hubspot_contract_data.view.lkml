view: hubspot_contract_data {
  sql_table_name: "FINANCIAL_SYSTEMS"."T3_SAAS_GOLD"."HUBSPOT_CONTRACT_DATA" ;;

  dimension: LI_ID {
    type: string
    sql: ${TABLE}."PK_LINE_ITEM_ID" ;;
    primary_key: yes
  }
  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: COMPANY_NAME {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: SALES_REF_ID {
    type: string
    sql: ${TABLE}."FK_SALES_REF_ID" ;;
  }
  dimension: PRODUCT_ID {
    type: string
    sql: ${TABLE}."FK_PRODUCT_ID" ;;
  }
  dimension: CONTRACT_NAME {
    type: string
    sql: ${TABLE}."CONTRACT_NAME" ;;
  }
  dimension: LINKED_DEVICE_TYPE {
    type: string
    sql: ${TABLE}."LINKED_DEVICE_TYPE" ;;
  }
  dimension: CONTRACT_QUANTITY {
    type: number
    sql: ${TABLE}."QTY_CONTRACTED" ;;
  }
  dimension: CONTRACT_MRR {
    type: number
    sql: ${TABLE}."MRR_CONTRACTED" ;;
  }
  dimension: CONTRACT_UNIT_COST {
    type: number
    sql: ${TABLE}."UNIT_COST_CONTRACTED" ;;
  }
  dimension: CONTRACT_CLOSE_DATE {
    type: date
    sql: ${TABLE}."DATE_CONTRACT_CLOSE" ;;
  }
  dimension: CONTRACT_TERMS_IN_MONTHS {
    type: number
    sql: ${TABLE}."CONTRACT_TERMS_IN_MONTHS" ;;
  }
  dimension: CONTRACT_TERMS_END_DATE {
    type: date
    sql: ${TABLE}."DATE_CONTRACT_TERMS_END" ;;
  }
  dimension: CONTRACT_INSTALL_TYPE {
    type: string
    sql: ${TABLE}."CONTRACT_INSTALL_TYPE" ;;
  }
  dimension: CONTRACT_BUNDLE_INSTALL_STATUS {
    type: string
    sql: ${TABLE}."CONTRACT_BUNDLE_INSTALL_STATUS" ;;
  }
  dimension: ACCT_EXEC_HS_ID {
    type: string
    sql: ${TABLE}."FK_ACCT_EXEC_ID" ;;
  }
  dimension: ACCT_EXEC_NAME {
    type: string
    sql: ${TABLE}."ACCT_EXEC_NAME_FULL" ;;
  }
  dimension: ACCT_EXEC_EMAIL {
    type: string
    sql: ${TABLE}."ACCT_EXEC_EMAIL" ;;
  }
}
