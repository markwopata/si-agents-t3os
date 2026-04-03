
view: t3_invoice_detail {
  derived_table: {
    sql: SELECT INV._ES_UPDATE_TIMESTAMP, 
      INV.ORDER_ID, 
      INV.INVOICE_NO, 
      INV.INVOICE_ID, 
      INV.LINE_ITEM_AMOUNT, 
      INV.BILLED_AMOUNT, 
      INV.SHIP_FROM, 
      INV.SHIP_TO, 
      INV.PURCHASE_ORDER_ID, 
      INV.COMPANY_ID,
      LI.LINE_ITEM_ID,
      LI.LINE_ITEM_TYPE_ID,
      LI.BRANCH_ID,
      LI.ASSET_ID,
      LI.NUMBER_OF_UNITS,
      LI.PRICE_PER_UNIT,
      LI.AMOUNT,
      LI.TAX_RATE_PERCENTAGE,
      LI.TAX_AMOUNT
      FROM ES_WAREHOUSE.PUBLIC.INVOICES as INV
      RIGHT JOIN ES_WAREHOUSE.PUBLIC.LINE_ITEMS as LI ON LI.INVOICE_ID = INV.INVOICE_ID
      WHERE LI.BRANCH_ID = 79502
      LIMIT 10 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: ship_from {
    type: string
    sql: ${TABLE}."SHIP_FROM" ;;
  }

  dimension: ship_to {
    type: string
    sql: ${TABLE}."SHIP_TO" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: tax_rate_percentage {
    type: number
    sql: ${TABLE}."TAX_RATE_PERCENTAGE" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  set: detail {
    fields: [
        _es_update_timestamp_time,
	order_id,
	invoice_no,
	invoice_id,
	line_item_amount,
	billed_amount,
	ship_from,
	ship_to,
	purchase_order_id,
	company_id,
	line_item_id,
	line_item_type_id,
	branch_id,
	asset_id,
	number_of_units,
	price_per_unit,
	amount,
	tax_rate_percentage,
	tax_amount
    ]
  }
}
