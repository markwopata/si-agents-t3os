view: sales_rep_company_access_pl {
  derived_table: {
    sql:SELECT DISTINCT SALESPERSON_USER_ID , COMPANY_ID, EMAIL_ADDRESS
FROM (
SELECT CS.USER_ID AS SALESPERSON_USER_ID, U.COMPANY_ID AS COMPANY_ID, U2.EMAIL_ADDRESS
FROM COMMISSION_CLAWBACKS.COMMISSION_SPLIT CS
INNER JOIN ES_WAREHOUSE.PUBLIC.INVOICES AS I ON CS.INVOICE_ID = I.INVOICE_ID
INNER JOIN ES_WAREHOUSE.PUBLIC.ORDERS AS O ON I.ORDER_ID = O.ORDER_ID
INNER JOIN ES_WAREHOUSE.PUBLIC.USERS AS U ON O.USER_ID = U.USER_ID
INNER JOIN ES_WAREHOUSE.PUBLIC.USERS AS U2 ON CS.USER_ID = U2.USER_ID
) AS X ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}.SALESPERSON_USER_ID ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_id_string {
    type: number
    sql: ${company_id}::VARCHAR(15000) ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.EMAIL_ADDRESS ;;
  }


  }
