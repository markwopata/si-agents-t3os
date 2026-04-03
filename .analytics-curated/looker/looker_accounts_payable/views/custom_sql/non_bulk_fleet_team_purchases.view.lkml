view: non_bulk_fleet_team_purchases {
  derived_table: {
    sql: SELECT
          PO.PURCHASE_ORDER_NUMBER AS "PO_NUMBER",
          CAST(CONVERT_TIMEZONE('America/Chicago',PO.DATE_CREATED) AS DATE) AS "CREATED_DATE",
          VEND.EXTERNAL_ERP_VENDOR_REF AS "VENDORID",
          VENDINT.NAME AS "Vendor_Name",
          NII.NAME AS "NAME",
          POLI.DESCRIPTION AS "DESCRIPTION",
          PO.REFERENCE AS "REFERENCE",
          POLI.QUANTITY AS "QUANTITY",
          POLI.PRICE_PER_UNIT AS "PRICE/UNIT",
          PO.REQUESTING_BRANCH_ID AS "MARKET_ID",
          M.NAME AS "MARKET",
          USERS.USERNAME AS "USER",
          PO.STATUS AS "STATUS"

          FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POLI

      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" PO
          ON POLI.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID

      LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" I
          ON POLI.ITEM_ID = I.ITEM_ID

      LEFT JOIN "PROCUREMENT"."PUBLIC"."NON_INVENTORY_ITEMS" NII
          ON I.ITEM_ID = NII.ITEM_ID

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS
          ON PO.CREATED_BY_ID = USERS.USER_ID

      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" M

      ON M.MARKET_ID = PO.REQUESTING_BRANCH_ID

      LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND

      ON PO.VENDOR_ID = VEND.ENTITY_ID

      LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT

      ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID

      WHERE I.ITEM_TYPE != 'INVENTORY'
      AND USERS.USERNAME IN ('ryan.bernhard@equipmentshare.com','alyssa.quinlan@equipmentshare.com')

      OR
      LEFT(NII.NAME,4) = '2001' AND VEND.EXTERNAL_ERP_VENDOR_REF = 'V24024'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: priceunit {
    type: number
    sql: ${TABLE}."PRICE/UNIT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}."USER" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  set: detail {
    fields: [
      po_number,
      created_date,
      vendorid,
      vendor_name,
      name,
      description,
      reference,
      quantity,
      priceunit,
      market_id,
      market,
      user,
      status
    ]
  }
}
