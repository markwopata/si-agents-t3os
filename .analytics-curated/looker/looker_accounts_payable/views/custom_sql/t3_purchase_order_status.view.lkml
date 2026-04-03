view: t3_purchase_order_status {
  derived_table: {
    sql: SELECT
    VEND.EXTERNAL_ERP_VENDOR_REF AS "Vendor_ID",
    VENDINT.NAME AS "Vendor_Name",
    POH.PURCHASE_ORDER_NUMBER AS "PO_Number",
    POH.PURCHASE_ORDER_ID AS "PURCHASE_ORDER_ID",
    CAST(CONVERT_TIMEZONE('America/Chicago',POH.DATE_CREATED) AS DATE) AS "Date",
    CONCAT(BERP1.INTACCT_DEPARTMENT_ID,' - ',BRCH1.NAME) AS "Requesting_Branch",
    CONCAT(BERP2.INTACCT_DEPARTMENT_ID,' - ',BRCH2.NAME) AS "Deliver_To_Branch",
    CONCAT(POH.CREATED_BY_ID,' - ', USER1.FIRST_NAME,' ',USER1.LAST_NAME) AS "Created_By",
    USER1.EMAIL_ADDRESS AS "Email_Address",
    POH.STATUS AS "PO_Status",
    POD.PO_TOTAL_QTY AS "TOTAL_QTY_Ordered",
    PRD.PR_TOTAL_QTY AS "TOTAL_QTY_Received",
    PRD.PR_TOTAL_REJECTED_QTY AS "TOTAL_QTY_Rejected",
    INTPOL.QTY_RECEIVED AS "Intacct_Total_QTY_Received",
    INTPOL.QTY_CONVERTED AS "Intacct_Total_QTY_Converted",
    POD1.DESCRIPTION  AS "PARTS_DESCRIPTION",
    POD1.PRICE_PER_UNIT AS "PRICE_PER_UNIT",
    ITM.ITEM_TYPE AS "ITEM_TYPE"
FROM
    "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER1 ON POH.CREATED_BY_ID = USER1.USER_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP1 ON POH.REQUESTING_BRANCH_ID = BERP1.BRANCH_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP2 ON POH.DELIVER_TO_ID = BERP2.BRANCH_ID
    LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH1 ON POH.REQUESTING_BRANCH_ID = BRCH1.MARKET_ID
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH2 ON POH.DELIVER_TO_ID = BRCH2.MARKET_ID
    LEFT JOIN
        (SELECT
            PURCHASE_ORDER_ID,
            SUM(QUANTITY) AS "PO_TOTAL_QTY"
         FROM
            "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS"
         GROUP BY
            PURCHASE_ORDER_ID) POD ON POH.PURCHASE_ORDER_ID = POD.PURCHASE_ORDER_ID
    LEFT JOIN (SELECT
            PURCHASE_ORDER_ID,
            ITEM_ID,
            DESCRIPTION,
            PRICE_PER_UNIT
          FROM
            "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS") POD1 ON POH.PURCHASE_ORDER_ID = POD1.PURCHASE_ORDER_ID
    LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" ITM ON POD1.ITEM_ID = ITM.ITEM_ID
    LEFT JOIN
        (SELECT
            PRH1.PURCHASE_ORDER_ID,
            --SUM(PRD1.PACKINGLIST_QUANTITY) AS "PR_TOTAL_QTY"
            SUM(PRD1.ACCEPTED_QUANTITY + PRD1.REJECTED_QUANTITY) AS "PR_TOTAL_QTY",
            SUM(PRD1.REJECTED_QUANTITY) AS "PR_TOTAL_REJECTED_QTY"
         FROM
            "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PRD1
            LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" PRH1 ON PRD1.PURCHASE_ORDER_RECEIVER_ID = PRH1.PURCHASE_ORDER_RECEIVER_ID
         GROUP BY
            PRH1.PURCHASE_ORDER_ID) PRD ON POH.PURCHASE_ORDER_ID = PRD.PURCHASE_ORDER_ID
    LEFT JOIN --ADD THIS SECTION
        (SELECT
            SPLIT_PART(SPLIT_PART(POH1.DOCNO,'-',1),'_',1) AS "PO_NUMBER",
            SUM(POL1.QUANTITY) AS "QTY_RECEIVED",
            SUM(POL1.QTY_CONVERTED) AS "QTY_CONVERTED"
        FROM
            "ANALYTICS"."INTACCT"."PODOCUMENT" POH1
            LEFT JOIN "ANALYTICS"."INTACCT"."PODOCUMENTENTRY" POL1 ON POH1.DOCID = POL1.DOCHDRID
            LEFT JOIN
              (SELECT DISTINCT
                  POH1A.DOCNO
              FROM
                  "ANALYTICS"."INTACCT"."PODOCUMENT" POH1A
                  LEFT JOIN "ANALYTICS"."INTACCT"."PODOCUMENT" POH1B ON CONCAT(CAST(POH1A.DOCNO AS VARCHAR),'_C') = POH1B.DOCNO
              WHERE
                  POH1B.DOCNO IS NOT NULL) POH1C ON POH1.DOCNO = POH1C.DOCNO
        WHERE
            POH1.DOCPARID = 'Purchase Order' AND
            POH1C.DOCNO IS NULL
            --CAST(POH1.WHENCREATED AS DATE) >= '2021-01-01'
        GROUP BY
            SPLIT_PART(SPLIT_PART(POH1.DOCNO,'-',1),'_',1)) INTPOL ON CAST(POH.PURCHASE_ORDER_NUMBER AS VARCHAR) = INTPOL.PO_NUMBER
WHERE
    POH.COMPANY_ID = 1854
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_Number" ;;
  }

  dimension: date {
    convert_tz: no
    type: date
    sql: ${TABLE}."Date" ;;
  }

  dimension: requesting_branch {
    type: string
    sql: ${TABLE}."Requesting_Branch" ;;
  }

  dimension: deliver_to_branch {
    type: string
    sql: ${TABLE}."Deliver_To_Branch" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."Created_By" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."Email_Address" ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_Status" ;;
  }

  dimension: total_qty_ordered {
    type: number
    sql: ${TABLE}."TOTAL_QTY_Ordered" ;;
  }

  dimension: total_qty_received {
    type: number
    sql: ${TABLE}."TOTAL_QTY_Received" ;;
  }

  dimension: intacct_total_qty_received {
    type: number
    sql: ${TABLE}."Intacct_Total_QTY_Received" ;;
  }

  dimension: intacct_total_qty_converted {
    type: number
    sql: ${TABLE}."Intacct_Total_QTY_Converted" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: po_number_with_link_to_po_edit {
    type: number
    sql: ${TABLE}."PO_Number" ;;
    html:<font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="_blank">{{ po_number._value }}</a></font></u>;;
  }

  dimension: total_qty_rejected {
    type: number
    sql: ${TABLE}."TOTAL_QTY_Rejected" ;;
  }

  dimension: parts_description {
    type: string
    label: "Parts Description"
    sql: ${TABLE}."PARTS_DESCRIPTION" ;;
  }

  dimension: price_per_unit {
    type: number
    label: "Price per Unit"
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: item_type {
    type: string
    label: "Item Type"
    sql: ${TABLE}."ITEM_TYPE" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      po_number,
      date,
      requesting_branch,
      deliver_to_branch,
      created_by,
      email_address,
      po_status,
      total_qty_ordered,
      total_qty_received,
      intacct_total_qty_received,
      intacct_total_qty_converted,
      total_qty_rejected
    ]
  }
}
