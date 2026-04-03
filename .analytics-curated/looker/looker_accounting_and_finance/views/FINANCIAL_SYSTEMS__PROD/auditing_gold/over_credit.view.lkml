view: over_credit {
  derived_table: {
    sql: select PK_CUSTOMER_ID as CUSTOMER_ID,
      CUSTOMER_NAME,
      AMOUNT_CREDIT_LIMIT AS CREDIT_LIMIT,
      CURRENT_RECEIVABLE,
      OVER_LIMIT_AMOUNT,
      OVER_LIMIT_FLAG
      from financial_systems.auditing_gold.over_credit_limit_customers
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

  dimension: CREDIT_LIMIT {
    type: number
    sql: ${TABLE}.CREDIT_LIMIT;;
  }

  dimension: CURRENT_RECEIVABLE {
    type: number
    sql: ${TABLE}.CURRENT_RECEIVABLE ;;
  }

  dimension: OVER_LIMIT_AMOUNT {
    type: number
    sql: ${TABLE}.OVER_LIMIT_AMOUNT ;;
  }


  dimension: OVER_LIMIT_FLAG {
    type: string
    sql: ${TABLE}.OVER_LIMIT_FLAG ;;
  }

}
