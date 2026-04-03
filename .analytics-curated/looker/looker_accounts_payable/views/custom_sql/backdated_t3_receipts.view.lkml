view: backdated_t3_receipts {
  derived_table: {
    sql: SELECT
          PO.PURCHASE_ORDER_NUMBER,
          CAST(POR.DATE_CREATED AS DATE) AS "CREATED_DATE",
          CAST(POR.DATE_RECEIVED AS DATE) AS "RECEIVED_DATE",
          datediff(day, "CREATED_DATE", "RECEIVED_DATE") AS "BACKDATED_DAYS",
          POR.DATE_CREATED,
          POR.PURCHASE_ORDER_RECEIVER_ID,
          PO.REQUESTING_BRANCH_ID AS "BRANCH_ID",
          M.NAME,
          CONCAT(USERS.FIRST_NAME, ' ', USERS.LAST_NAME) AS CREATED_BY,
          USERS.EMAIL_ADDRESS AS "EMAIL"
      FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" POR
      LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" PO
      ON POR.PURCHASE_ORDER_ID = PO.PURCHASE_ORDER_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" M
      ON M.MARKET_ID = PO.REQUESTING_BRANCH_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS
      ON POR.CREATED_BY_ID = USERS.USER_ID
      WHERE LEFT(CREATED_DATE,7) != LEFT(RECEIVED_DATE,7)
      ORDER BY "BACKDATED_DAYS" ASC
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

  dimension: created_date {
    type: date
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: received_date {
    type: date
    sql: ${TABLE}."RECEIVED_DATE" ;;
  }

  dimension: backdated_days {
    type: number
    sql: ${TABLE}."BACKDATED_DAYS" ;;
  }

  dimension: purchase_order_receiver_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ID" ;;
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

  set: detail {
    fields: [
      purchase_order_number,
      created_date,
      received_date,
      backdated_days,
      purchase_order_receiver_id,
      branch_id,
      name,
      created_by,
      email
    ]
  }
}
