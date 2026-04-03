view: customer_class {
  derived_table: {
    sql: select PK_CUSTOMER_ID as CUSTOMER_ID,
      CUSTOMER_NAME,
      ADMIN_TERM,
      AMOUNT_CREDIT_LIMIT,
      CUSTOMER_CLASSIFICATION
      from financial_systems.auditing_gold.customer_classification
      ;;
  }
  dimension: CUSTOMER_ID {
    type: string
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: CUSTOMER_NAME {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: ADMIN_TERM {
    type: string
    sql: ${TABLE}.ADMIN_TERM;;
  }

  dimension: AMOUNT_CREDIT_LIMIT {
    type: number
    sql: ${TABLE}.AMOUNT_CREDIT_LIMIT ;;
  }

  dimension: CUSTOMER_CLASSIFICATION {
    type: string
    sql: ${TABLE}.CUSTOMER_CLASSIFICATION ;;
  }

}
