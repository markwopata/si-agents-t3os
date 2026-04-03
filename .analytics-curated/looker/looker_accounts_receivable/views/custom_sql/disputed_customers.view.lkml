view: disputed_customers {
  derived_table: {
    sql: SELECT DISTINCT I.COMPANY_ID AS CUSTOMER_ID,'Yes' AS DISPUTED_INVOICES
FROM ES_WAREHOUSE.PUBLIC.INVOICES AS I
LEFT JOIN ES_WAREHOUSE.PUBLIC.DISPUTES AS D ON I.INVOICE_ID = D.INVOICE_ID
WHERE D.INVOICE_ID IS NOT NULL
AND D.DATE_RESOLVED IS NULL ;;
  }

 dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.CUSTOMER_ID ;;
  }

  dimension: disputed_invoices {
    type: string
    value_format_name: id
    sql: ifnull(${TABLE}.DISPUTED_INVOICES,'No') ;;
  }

  }
