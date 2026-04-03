view: t3_purchase_order_exceptions {
  derived_table: {
    sql: SELECT
    PO.PURCHASE_ORDER_NUMBER AS "PO NUMBER",
    PO.DATE_CREATED AS "T3_CREATED_DATE",
    VEND.EXTERNAL_ERP_VENDOR_REF AS VENDORID,
    VENDINT.NAME AS "VENDOR_NAME",
    PO.REQUESTING_BRANCH_ID AS "BRANCH_ID",
    M.NAME AS "BRANCH_NAME",
    PO.STATUS,
    CONCAT(USERS.FIRST_NAME, ' ', USERS.LAST_NAME) AS CREATED_BY,
    USERS.EMAIL_ADDRESS AS "EMAIL"
FROM
    "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" PO
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" M ON M.MARKET_ID = PO.REQUESTING_BRANCH_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS ON PO.CREATED_BY_ID = USERS.USER_ID
    LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND ON PO.VENDOR_ID = VEND.ENTITY_ID
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
WHERE
    PO.DATE_CREATED > TO_TIMESTAMP('2021-10-22')
    AND VENDORID IN ('V27665','V28104','V26722') AND BRANCH_ID NOT IN ('23627','23626','13574','15977','55495')

    OR

    PO.DATE_CREATED > TO_TIMESTAMP('2021-10-22')
    AND
    VENDORID IN ('V11785','V21986','V12588') AND BRANCH_ID IN ('23627','23626','13574','15977','55495')

    OR

    PO.DATE_CREATED > TO_TIMESTAMP('2021-10-22')
    AND
    VENDORID IN ('V12892','V12893','V20902')
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: number
    label: "PO NUMBER"
    sql: ${TABLE}."PO NUMBER" ;;
  }

  dimension_group: t3_created_date {
    type: time
    sql: ${TABLE}."T3_CREATED_DATE" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  set: detail {
    fields: [
      po_number,
      t3_created_date_time,
      vendorid,
      vendor_name,
      branch_id,
      branch_name,
      status,
      created_by,
      email
    ]
  }
}
