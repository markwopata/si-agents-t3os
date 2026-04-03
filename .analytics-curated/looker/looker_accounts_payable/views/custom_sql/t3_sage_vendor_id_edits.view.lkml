view: t3_sage_vendor_id_edits {
  derived_table: {
    sql: SELECT
          T3PO.PURCHASE_ORDER_NUMBER,
          T3PO.DATE_CREATED,
          T3PO.STATUS,
          ENS.EXTERNAL_ERP_VENDOR_REF,
          E.NAME,
          SPO.CUSTVENDID,
          SPO.CUSTVENDNAME,
          CONCAT(USERS.FIRST_NAME, ' ', USERS.LAST_NAME) AS CREATED_BY,
          USERS.EMAIL_ADDRESS AS "EMAIL"

      FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" T3PO

      LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."PO_DOCUMENT" SPO

      ON to_varchar(T3PO.PURCHASE_ORDER_NUMBER) = to_varchar(LEFT(SPO.DOCNO,6))

      LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" ENS

      ON T3PO.VENDOR_ID = ENS.ENTITY_ID

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS

      ON T3PO.CREATED_BY_ID = USERS.USER_ID

      LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" E

      ON ENS.ENTITY_ID = E.ENTITY_ID

      WHERE ENS.EXTERNAL_ERP_VENDOR_REF != SPO.CUSTVENDID

      AND T3PO.COMPANY_ID = '1854'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: external_erp_vendor_ref {
    type: string
    sql: ${TABLE}."EXTERNAL_ERP_VENDOR_REF" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: custvendid {
    type: string
    sql: ${TABLE}."CUSTVENDID" ;;
  }

  dimension: custvendname {
    type: string
    sql: ${TABLE}."CUSTVENDNAME" ;;
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
      purchase_order_number,
      date_created_time,
      status,
      external_erp_vendor_ref,
      name,
      custvendid,
      custvendname,
      created_by,
      email
    ]
  }
}
