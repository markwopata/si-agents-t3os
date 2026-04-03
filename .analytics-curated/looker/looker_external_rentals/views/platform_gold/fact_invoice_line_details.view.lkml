view: fact_invoice_line_details {
  sql_table_name: "PLATFORM"."GOLD"."V_INVOICE_LINE_DETAILS" ;;

  dimension: invoice_line_details_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_KEY" ;;
    hidden: yes
  }

  dimension: invoice_line_details_line_item_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_LINE_ITEM_KEY" ;;
    hidden: yes
  }

  dimension: invoice_line_details_invoice_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_INVOICE_KEY" ;;
    hidden: yes
  }

  dimension: invoice_line_details_order_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ORDER_KEY" ;;
    hidden: yes
  }

  dimension: invoice_line_details_rental_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RENTAL_KEY" ;;
    description: "FK to dim_rentals"
  }

  dimension: invoice_line_details_asset_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: invoice_line_details_company_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_COMPANY_KEY" ;;
    description: "FK to dim_companies"
  }

  dimension: invoice_line_details_gl_billing_approved_date_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_GL_BILLING_APPROVED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: invoice_line_details_market_key {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_MARKET_KEY" ;;
    hidden: yes
  }

  measure: invoice_line_details_number_of_units {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_NUMBER_OF_UNITS" ;;
    value_format_name: decimal_2
  }

  measure: invoice_line_details_price_per_unit {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_PRICE_PER_UNIT" ;;
    value_format_name: usd
  }

  measure: invoice_line_details_amount {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_AMOUNT" ;;
    value_format_name: usd
  }

  measure: invoice_line_details_tax_amount {
    type: number
    sql: ${TABLE}."INVOICE_LINE_DETAILS_TAX_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: invoice_line_details_recordtimestamp {
    type: string
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    hidden: yes
  }
}
