view: open_rerent_purchase_orders {
  derived_table: {
    sql: SELECT
          PO.PURCHASE_ORDER_NUMBER AS "PO#",
          CAST(CONVERT_TIMEZONE('America/Chicago',PO.DATE_CREATED) AS DATE) AS "Date",
          datediff(day, "Date", CURRENT_DATE) AS "DAYS_OLD",
          VEND.EXTERNAL_ERP_VENDOR_REF AS "VENDORID",
          VENDINT.NAME AS "Vendor_Name",
          PO.REFERENCE AS "REF",
          PO.REQUESTING_BRANCH_ID AS "BRANCH_ID",
          M.NAME,
          CONCAT(USERS.FIRST_NAME, ' ', USERS.LAST_NAME) AS CREATED_BY,
          USERS.EMAIL_ADDRESS AS "EMAIL",
          PO.STATUS,
          POLI.DESCRIPTION,
          POLI.QUANTITY,
          ROUND(POLI.PRICE_PER_UNIT,2) AS "PRICE/UNIT",
          PORI.PACKINGLIST_QUANTITY,
          PORI.ACCEPTED_QUANTITY,
          PORI.REJECTED_QUANTITY

      FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" PO

      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POLI

      ON PO.PURCHASE_ORDER_ID = POLI.PURCHASE_ORDER_ID

      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PORI

      ON POLI.PURCHASE_ORDER_LINE_ITEM_ID = PORI.PURCHASE_ORDER_LINE_ITEM_ID

      LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND

      ON PO.VENDOR_ID = VEND.ENTITY_ID

      LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT

      ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" M

      ON M.MARKET_ID = PO.REQUESTING_BRANCH_ID

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS

      ON PO.CREATED_BY_ID = USERS.USER_ID

      WHERE POLI.ITEM_ID = '21d03683-19ea-4b4e-ad7e-f0418c3d8fb5'

      AND PURCHASE_ORDER_NUMBER != '300149'

      AND PO.STATUS != 'CLOSED'

      ORDER BY "DAYS_OLD" DESC, PO.PURCHASE_ORDER_NUMBER
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po {
    type: number
    sql: ${TABLE}."PO#" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."Date" ;;
  }

  dimension: days_old {
    type: number
    sql: ${TABLE}."DAYS_OLD" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: ref {
    type: string
    sql: ${TABLE}."REF" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: priceunit {
    type: number
    sql: ${TABLE}."PRICE/UNIT" ;;
  }

  dimension: packinglist_quantity {
    type: number
    sql: ${TABLE}."PACKINGLIST_QUANTITY" ;;
  }

  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."ACCEPTED_QUANTITY" ;;
  }

  dimension: rejected_quantity {
    type: number
    sql: ${TABLE}."REJECTED_QUANTITY" ;;
  }

  set: detail {
    fields: [
      po,
      date,
      days_old,
      vendorid,
      vendor_name,
      ref,
      branch_id,
      name,
      created_by,
      email,
      status,
      description,
      quantity,
      priceunit,
      packinglist_quantity,
      accepted_quantity,
      rejected_quantity
    ]
  }
}
