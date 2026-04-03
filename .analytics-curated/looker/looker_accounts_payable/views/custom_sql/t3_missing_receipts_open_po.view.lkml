view: t3_missing_receipts_open_po {
  derived_table: {
    sql: SELECT
          PO.PURCHASE_ORDER_NUMBER AS "PO Number",
          PO.REQUESTING_BRANCH_ID AS "Market ID",
          M.NAME AS "Market",
          PO.STATUS AS "PO Status",
          PO.CREATED_BY_ID AS "Created By User ID",
          CONCAT(USERS.FIRST_NAME, ' ', USERS.LAST_NAME) AS "Created By",
          USERS.EMAIL_ADDRESS AS "Email",
          YMR.VENDOR_ID AS "Vendor ID",
          YMR.VENDOR_NAME AS "Vendor Name",
          CONCAT(YMR.VENDOR_ID,'-',YMR.VENDOR_NAME) AS "Vendor",
          YMR.AMOUNT AS "Invoice Amount",
          YMR.DOCUMENT_NO AS "YOOZ Doc Num",
          YMR.DOCUMENT_DATE AS "YOOZ Doc Date",
          YMR.CAPTURE_DATE AS "YOOZ Capture Date",
          YMR.STATUS AS "YOOZ Status",
          TIMESTAMPDIFF(day,YMR.CAPTURE_DATE,CURRENT_TIMESTAMP) AS "Days Missing"
      FROM
          "ANALYTICS"."GS"."YOOZ_MISSING_RECEIPTS" YMR
          LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" PO ON YMR.RECEIPT_IF_MISSING = PO.PURCHASE_ORDER_NUMBER
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" M ON PO.REQUESTING_BRANCH_ID = M.MARKET_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USERS ON PO.CREATED_BY_ID = USERS.USER_ID
      WHERE
          M.COMPANY_ID = 1854
      AND
          TIMESTAMPDIFF(day,YMR.CAPTURE_DATE,CURRENT_TIMESTAMP)>1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: number
    label: "PO Number"
    sql: ${TABLE}."PO Number" ;;
  }

  dimension: market_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."Market ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."Market" ;;
  }

  dimension: po_status {
    type: string
    label: "PO Status"
    sql: ${TABLE}."PO Status" ;;
  }

  dimension: created_by_user_id {
    type: number
    label: "Created By User ID"
    sql: ${TABLE}."Created By User ID" ;;
  }

  dimension: created_by {
    type: string
    label: "Created By"
    sql: ${TABLE}."Created By" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."Email" ;;
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."Vendor ID" ;;
  }

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."Vendor Name" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."Vendor" ;;
  }

  dimension: invoice_amount {
    type: number
    label: "Invoice Amount"
    sql: ${TABLE}."Invoice Amount" ;;
  }

  dimension: yooz_doc_num {
    type: number
    label: "YOOZ Doc Num"
    sql: ${TABLE}."YOOZ Doc Num" ;;
  }

  dimension: yooz_doc_date {
    type: string
    label: "YOOZ Doc Date"
    sql: ${TABLE}."YOOZ Doc Date" ;;
  }

  dimension: yooz_capture_date {
    type: string
    label: "YOOZ Capture Date"
    sql: ${TABLE}."YOOZ Capture Date" ;;
  }

  dimension: yooz_status {
    type: string
    label: "YOOZ Status"
    sql: ${TABLE}."YOOZ Status" ;;
  }

  dimension: days_missing {
    type: number
    label: "Days Missing"
    sql: ${TABLE}."Days Missing" ;;
  }

  set: detail {
    fields: [
      po_number,
      market_id,
      market,
      po_status,
      created_by_user_id,
      created_by,
      email,
      vendor_id,
      vendor_name,
      vendor,
      invoice_amount,
      yooz_doc_num,
      yooz_doc_date,
      yooz_capture_date,
      yooz_status,
      days_missing
    ]
  }
}
