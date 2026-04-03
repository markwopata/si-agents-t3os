view: t3_purchase_order_details {
  derived_table: {
    sql: WITH PO_APPROVERS AS (
    SELECT
        PURCHASE_ORDER_ID,
        MIN_BY(CREATED_BY_ID, DATE_CREATED) AS INITIAL_APPROVER_ID,
        MAX_BY(CREATED_BY_ID, DATE_CREATED) AS LAST_APPROVER_ID
    FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_EVENT_LOGS"
    WHERE EVENT_TYPE = 'APPROVED'
    GROUP BY PURCHASE_ORDER_ID
)

SELECT
    VEND.EXTERNAL_ERP_VENDOR_REF AS "Vendor_ID",
    VENDINT.NAME,
    COALESCE(POH.PURCHASE_ORDER_NUMBER::STRING, 'NO PO NUMBER') AS "PO_Number",
    POH.PURCHASE_ORDER_ID AS "PO_ID",
    POH.DATE_CREATED AS "PO_Date",
    CONCAT(BERP1.INTACCT_DEPARTMENT_ID,' - ',BRCH1.NAME) AS "Requesting_Branch",
    CONCAT(BERP2.INTACCT_DEPARTMENT_ID,' - ',BRCH2.NAME) AS "Deliver_To_Branch",
    BRCH2.MARKET_ID AS "Deliver_To_Branch_ID",
    CONCAT(POH.CREATED_BY_ID,' - ', USER1.FIRST_NAME,' ',USER1.LAST_NAME) AS "Created_By",
    USER1.EMAIL_ADDRESS AS "Email_Address",
    CONCAT(U_INIT.FIRST_NAME, ' ', U_INIT.LAST_NAME) AS "Initial_Approver",
    CONCAT(U_LAST.FIRST_NAME, ' ', U_LAST.LAST_NAME) AS "Final_Approver",
    ITM.ITEM_TYPE AS "Item_Type",
    NII.NAME AS "Item_Name",
    PA.PART_ID AS "Part_ID",
    PA.PART_NUMBER AS "Part_Number",
    PT.DESCRIPTION AS "Part_Description",
    PR.NAME AS "Provider",
    POL.DESCRIPTION AS "Description",
    POL.MEMO AS "Memo",
    POL.QUANTITY AS "Quantity_Ordered",
    PORL.ACCEPTED_QUANTITY AS "Accepted_Quantity",
    PORL.REJECTED_QUANTITY AS "Rejected_Quantity",
    POL.PRICE_PER_UNIT AS "Price_Per_Unit",
    POH.STATUS AS "PO_Status",
    POH.AMOUNT_APPROVED AS "Amount",
    POH.DATE_ARCHIVED,
    POL.ALLOCATION_ID,
    POL.ALLOCATION_TYPE

FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH
LEFT JOIN PO_APPROVERS APP ON POH.PURCHASE_ORDER_ID = APP.PURCHASE_ORDER_ID
LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER1 ON POH.CREATED_BY_ID = USER1.USER_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" U_INIT ON APP.INITIAL_APPROVER_ID = U_INIT.USER_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" U_LAST ON APP.LAST_APPROVER_ID = U_LAST.USER_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP1 ON POH.REQUESTING_BRANCH_ID = BERP1.BRANCH_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERP2 ON POH.DELIVER_TO_ID = BERP2.BRANCH_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH1 ON POH.REQUESTING_BRANCH_ID = BRCH1.MARKET_ID
LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" BRCH2 ON POH.DELIVER_TO_ID = BRCH2.MARKET_ID
LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POL ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" ITM ON POL.ITEM_ID = ITM.ITEM_ID
LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PARTS" PA ON POL.ITEM_ID = PA.ITEM_ID
LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" PR ON PA.PROVIDER_ID=PR.PROVIDER_ID
LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PART_TYPES" PT ON PA.PART_TYPE_ID=PT.PART_TYPE_ID
LEFT JOIN "PROCUREMENT"."PUBLIC"."NON_INVENTORY_ITEMS" NII ON POL.ITEM_ID = NII.ITEM_ID
LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" PORL ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PORL.PURCHASE_ORDER_LINE_ITEM_ID

WHERE POH.COMPANY_ID = '1854'
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_Number" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PO_ID" ;;
  }

  dimension_group: po_date {
    type: time
    sql: ${TABLE}."PO_Date" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension: requesting_branch {
    type: string
    sql: ${TABLE}."Requesting_Branch" ;;
  }

  dimension: deliver_to_branch {
    type: string
    sql: ${TABLE}."Deliver_To_Branch" ;;
  }
  dimension: deliver_to_branch_id {
    type: string
    sql: ${TABLE}."Deliver_To_Branch_ID" ;;
  }
  dimension: created_by {
    type: string
    sql: ${TABLE}."Created_By" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."Email_Address" ;;
  }

  dimension: initial_approver {
    type: string
    sql: ${TABLE}."Initial_Approver" ;;
  }

  dimension: final_approver {
    type: string
    sql: ${TABLE}."Final_Approver" ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}."Item_Type" ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}."Item_Name" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."Part_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."Part_Number" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."Part_Description" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."Provider" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."Memo" ;;
  }
dimension: allocation_id {
  type: string
  sql: ${TABLE}."ALLOCATION_ID" ;;
}
dimension: allocation_type {
  type: string
  sql: ${TABLE}."ALLOCATION_TYPE" ;;
}
  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."Quantity_Ordered" ;;
  }

  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."Accepted_Quantity" ;;
  }

  dimension: rejected_quantity {
    type: number
    sql: ${TABLE}."Rejected_Quantity" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."Price_Per_Unit" ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_Status" ;;
  }

  dimension: po_number_with_link_to_po_edit {
    type: string
    sql: ${TABLE}."PO_Number" ;;
    html:<font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="_blank">{{ po_number._value }}</a></font></u>;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }
 dimension: procurement_alert { #procurement team wants to investigate high parts purchases based on total PO amount or part price
   type: yesno
  sql: (${amount}>=15000 or ${price_per_unit}>=5000) and ${part_number} is not null;;
 }
  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${TABLE}."PO_Date" <= current_date AND ${TABLE}."PO_Date" >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  30_60_days{
    type: yesno
    sql:  ${TABLE}."PO_Date" <= (current_date - INTERVAL '30 days') AND ${TABLE}."PO_Date" >= (current_date - INTERVAL '60 days')
      ;;
  }

  measure: 30_day_cost {
    type: sum
    filters: [last_30_days: "Yes"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}."Amount" ;;
  }

  measure: 30_60_day_cost {
    type: sum
    filters: [30_60_days: "Yes"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}."Amount" ;;
  }

  # -------------------- end rolling 30 days section --------------------

  set: detail {
    fields: [
      vendor_id,
      name,
      po_number,
      po_date_time,
      requesting_branch,
      deliver_to_branch,
      created_by,
      email_address,
      initial_approver,
      final_approver,
      item_type,
      item_name,
      part_number,
      description,
      memo,
      quantity_ordered,
      accepted_quantity,
      rejected_quantity,
      price_per_unit,
      po_status,
      amount
    ]
  }
}
