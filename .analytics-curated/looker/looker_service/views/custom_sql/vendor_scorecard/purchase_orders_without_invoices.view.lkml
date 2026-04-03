view: purchase_orders_without_invoices {
  derived_table: {
    sql:
SELECT VEND.EXTERNAL_ERP_VENDOR_REF as vendorid,
        VENDINT.NAME as vendor_name,
        POH.PURCHASE_ORDER_NUMBER,
        POH.STATUS,
        POL.PURCHASE_ORDER_LINE_ITEM_ID,
        POH.DATE_CREATED,
        PA.PART_NUMBER,
        POL.DESCRIPTION,
        pr.name as provider,
        POL.MEMO,
        POL.QUANTITY AS Quantity_Ordered,
        POL.PRICE_PER_UNIT,
        POL.PRICE_PER_UNIT * POL.QUANTITY as line_item_amount
FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH
    LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND
        ON POH.VENDOR_ID = VEND.ENTITY_ID
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT
        ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
    LEFT JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" POL
        ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
    left join ES_WAREHOUSE.INVENTORY.PARTS p1
        on pol.item_id = p1.item_id
    left join ANALYTICS.PARTS_INVENTORY.PARTS pa
        on p1.part_id = pa.part_id
    left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
        on pr.provider_id = pa.provider_id
    left join (
            select distinct document_number
            from "ANALYTICS"."INTACCT_MODELS"."AP_DETAIL"
            where ap_header_type = 'apbill'
            ) apd
        on apd.document_number::STRING = poh.purchase_order_number::STRING
WHERE vendorid is NOT NULL
    and poh.date_archived is null
    and pol.date_archived is null
    and apd.document_number is null
    and poh.status = 'CLOSED';;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: purchase_order_number {
    type: number
    value_format_name: id
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: purchase_order_line_item_id {
    type: string
    sql: ${TABLE}.purchase_order_line_item_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.date_created ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: part_description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}.provider ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}.memo ;;
  }

  dimension: part_quantity_ordered {
    type: number
    sql: ${TABLE}.quantity_ordered ;;
  }

  measure: quantity_ordered {
    type: sum
    sql: ${part_quantity_ordered} ;;
  }

  dimension: price_per_unit {
    type: number
    value_format_name: usd
    sql: ${TABLE}.price_per_unit ;;
  }

  dimension: line_item_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.line_item_amount ;;
  }

  measure: amount {
    type: sum
    value_format_name: usd_0
    sql: ${line_item_amount} ;;
    drill_fields: [
      vendorid,
      vendor_name,
      purchase_order_number,
      purchase_order_line_item_id,
      status,
      created_date,
      provider,
      part_number,
      part_description,
      part_quantity_ordered,
      price_per_unit,
      line_item_amount
    ]
  }
}
