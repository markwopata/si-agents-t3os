view: market_region_salesperson_email {

  derived_table: {
    sql:
       SELECT MRS.SALESPERSON_USER_ID AS USER_ID, MRS.MARKET_ID AS MARKET_ID , U.EMAIL_ADDRESS AS EMAIL_ADDRESS
FROM ANALYTICS.PUBLIC.MARKET_REGION_SALESPERSON AS MRS
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
ON MRS.SALESPERSON_USER_ID = U.USER_ID
    ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.EMAIL_ADDRESS ;;
  }
  }
