view: fact_invoice_line_details {
  sql_table_name: "PLATFORM"."GOLD"."FACT_INVOICE_LINE_DETAILS" ;;

  dimension: invoice_line_details_amount {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_AMOUNT" ;;
  }
  dimension: invoice_line_details_asset_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ASSET_KEY" ;;
  }
  dimension: invoice_line_details_company_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_COMPANY_KEY" ;;
  }
  dimension: invoice_line_details_gl_billing_approved_date_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_GL_BILLING_APPROVED_DATE_KEY" ;;
  }
  dimension: invoice_line_details_invoice_due_date_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_INVOICE_DUE_DATE_KEY" ;;
  }
  dimension: invoice_line_details_invoice_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_INVOICE_KEY" ;;
  }
  dimension: invoice_line_details_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_KEY" ;;
  }
  dimension: invoice_line_details_line_item_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_LINE_ITEM_KEY" ;;
  }
  dimension: invoice_line_details_market_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_MARKET_KEY" ;;
  }
  dimension: invoice_line_details_number_of_units {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_NUMBER_OF_UNITS" ;;
  }
  dimension: invoice_line_details_order_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ORDER_KEY" ;;
  }
  dimension: invoice_line_details_part_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_PART_KEY" ;;
  }
  dimension: invoice_line_details_price_per_unit {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_PRICE_PER_UNIT" ;;
  }
  dimension_group: invoice_line_details_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RECORDTIMESTAMP" ;;
  }
  dimension: invoice_line_details_rental_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RENTAL_KEY" ;;
  }
  dimension: invoice_line_details_salesperson_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_SALESPERSON_KEY" ;;
  }
  dimension: invoice_line_details_tax_amount {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_TAX_AMOUNT" ;;
  }
  measure: count {
    type: count
  }
}
