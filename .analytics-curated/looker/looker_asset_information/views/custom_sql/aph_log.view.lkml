view: aph_log {
  derived_table: {
    sql:
   SELECT APHL.PURCHASE_HISTORY_ID AS PURCHASE_HISTORY_ID, APHL.DATE_GENERATED, APHL.PENDING_SCHEDULE,
APHL.GENERATED_BY_USER_ID AS USER_ID, U.FIRST_NAME ||', ' || U.LAST_NAME AS GENERATED_BY,
APH.ASSET_ID AS ASSET_ID, COALESCE(A.SERIAL_NUMBER,A.VIN) AS SERIAL_VIN,
SCD.COMPANY_ID AS SCD_COMPANY_ID,A.COMPANY_ID AS CURRENT_COMPANY_ID, SCDC.NAME AS SCD_OWNERSHIP,CURRC.NAME AS CURRENT_OWNERSHIP ,APHL.FINANCIAL_SCHEDULE_ID AS FINANCIAL_SCHEDULE_ID, FS.CURRENT_SCHEDULE_NUMBER AS SCHEDULE,
FL.FINANCIAL_LENDER_ID AS FINANCIAL_LENDER_ID, FL."NAME" AS LENDER,
APHL.FINANCE_STATUS AS FINANCE_STATUS,
COALESCE(APHL.OEC, A.PURCHASE_PRICE) AS OEC, APHL.PURCHASE_ORDER_URL AS ORDER_NUMBER , APHL.ASSET_INVOICE_URL AS INVOICE_NUMBER
FROM  ES_WAREHOUSE."PUBLIC".ASSET_PURCHASE_HISTORY_LOGS AS APHL
LEFT JOIN ES_WAREHOUSE."PUBLIC".ASSET_PURCHASE_HISTORY AS APH
ON APHL.PURCHASE_HISTORY_ID = APH.PURCHASE_HISTORY_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".ASSETS AS A
ON APH.ASSET_ID = A.ASSET_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".FINANCIAL_SCHEDULES AS FS
ON APHL.FINANCIAL_SCHEDULE_ID = FS.FINANCIAL_SCHEDULE_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".FINANCIAL_LENDERS AS FL
ON FL.FINANCIAL_LENDER_ID = FS.ORIGINATING_LENDER_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".USERS AS U
ON APHL.GENERATED_BY_USER_ID = U.USER_ID
LEFT JOIN ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY AS SCD
ON (SCD.ASSET_ID = APH.ASSET_ID) AND (APHL.DATE_GENERATED BETWEEN SCD.DATE_START AND SCD.DATE_END)
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS SCDC
ON SCD.COMPANY_ID = SCDC.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS CURRC
ON A.COMPANY_ID = CURRC.COMPANY_ID
ORDER BY APHL.DATE_GENERATED DESC
    ;;
  }

  dimension: purchase_history_id {
    type: number
    sql: ${TABLE}.PURCHASE_HISTORY_ID ;;
  }

  dimension: date_generated {
    type: date_time
    sql: ${TABLE}.DATE_GENERATED ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: generated_by {
    type: string
    sql: ${TABLE}.GENERATED_BY ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}.ORDER_NUMBER ;;
  }


  dimension: historical_ownership {
    type: string
    sql: ${TABLE}.SCD_OWNERSHIP ;;
  }

  dimension: current_ownership {
    type: string
    sql: ${TABLE}.CURRENT_OWNERSHIP ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.SERIAL_VIN ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}.PENDING_SCHEDULE ;;
  }



  dimension: historical_company_id {
    type: number
    sql: ${TABLE}.SCD_COMPANY_ID ;;
  }

  dimension: current_company_id {
    type: number
    sql: ${TABLE}.CURRENT_COMPANY_ID ;;
  }

  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.FINANCIAL_SCHEDULE_ID ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}.SCHEDULE ;;
  }

  dimension: financial_lender_id {
    type: number
    sql: ${TABLE}.FINANCIAL_LENDER_ID ;;
  }

  dimension: lender {
    type: string
    sql: ${TABLE}.LENDER ;;
  }

  dimension: finance_status{
    type: string
    sql: ${TABLE}.FINANCE_STATUS ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}.OEC ;;
  }

  }
