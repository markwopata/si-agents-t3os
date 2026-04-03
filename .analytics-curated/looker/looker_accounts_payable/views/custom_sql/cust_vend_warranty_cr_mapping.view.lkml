view: cust_vend_warranty_cr_mapping {
  derived_table: {
    sql: SELECT c.CUSTOMERID,
       c.NAME AS CUSTOMER_NAME,
       c.STATUS AS CUSTOMER_STATUS,
       c.VENDOR_ID_REF AS ASSIGNED_VENDOR_ID,
       v.NAME AS VENDOR_NAME,
       v.STATUS AS VENDOR_STATUS
FROM ANALYTICS.INTACCT.CUSTOMER c
LEFT JOIN ANALYTICS.INTACCT.VENDOR v ON c.VENDOR_ID_REF = v.VENDORID
WHERE c.VENDOR_ID_REF IS NOT NULL;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMERID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_status {
    type: string
    sql: ${TABLE}."CUSTOMER_STATUS" ;;
  }

  dimension: assigned_vendor_id {
    type: string
    sql: ${TABLE}."ASSIGNED_VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_status {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }


  set: detail {
    fields: [
    customer_id,
    customer_name,
    customer_status,
    assigned_vendor_id,
    vendor_name,
    vendor_status
    ]
  }
}
