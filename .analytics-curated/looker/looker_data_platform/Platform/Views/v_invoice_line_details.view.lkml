view: v_invoice_line_details {
  view_label: "Invoice Line Details"
  sql_table_name: "GOLD"."V_INVOICE_LINE_DETAILS" ;;

  dimension: invoice_line_details_amount {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_AMOUNT" ;;
  }
  dimension: invoice_line_details_asset_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ASSET_KEY" ;;
  }
  dimension: invoice_line_details_company_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_COMPANY_KEY" ;;
  }
  dimension: invoice_line_details_gl_billing_approved_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_GL_BILLING_APPROVED_DATE_KEY" ;;
  }
  dimension: invoice_line_details_invoice_due_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_INVOICE_DUE_DATE_KEY" ;;
  }
  dimension: invoice_line_details_invoice_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_INVOICE_KEY" ;;
  }
  dimension: invoice_line_details_item_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ITEM_KEY" ;;
  }
  dimension: invoice_line_details_key {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_KEY" ;;
  }
  dimension: invoice_line_details_market_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_MARKET_KEY" ;;
  }
  dimension: invoice_line_details_number_of_units {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_NUMBER_OF_UNITS" ;;
  }
  dimension: invoice_line_details_order_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_ORDER_KEY" ;;
  }
  dimension: invoice_line_details_part_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_PART_KEY" ;;
  }
  dimension: invoice_line_details_price_per_unit {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_PRICE_PER_UNIT" ;;
  }
  dimension: invoice_line_details_recordtimestamp {
    type: date
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RECORDTIMESTAMP" ;;
  }
  dimension: invoice_line_details_rental_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_RENTAL_KEY" ;;
  }
  dimension: invoice_line_details_salesperson_key {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_SALESPERSON_KEY" ;;
  }
  dimension: invoice_line_details_tax_amount {
    type: number
    hidden: yes
    sql: ${TABLE}."INVOICE_LINE_DETAILS_TAX_AMOUNT" ;;
  }
  measure: count {
    type: count
  }
  measure: total_amount {
    type: sum
    label: "Total Amount"
    value_format: "$#,##0.00;($#,##0.00)"
    sql:  ${TABLE}."INVOICE_LINE_DETAILS_AMOUNT" ;;
  }
  measure: total_tax_amount {
    type: sum
    label: "Total Tax Amount"
    value_format: "$#,##0.00;($#,##0.00)"
    sql:  ${TABLE}."INVOICE_LINE_DETAILS_TAX_AMOUNT" ;;
  }
  measure: avg_price_per_unit {
    type: average
    label: "Average Price Per Unit"
    value_format: "$#,##0.00;($#,##0.00)"
    sql:  ${TABLE}."INVOICE_LINE_DETAILS_PRICE_PER_UNIT" ;;
  }
  measure: avg_number_of_units {
    type: average
    label: "Average Number of Units"
    value_format: "#,##0.00"
    sql:  ${TABLE}."INVOICE_LINE_DETAILS_NUMBER_OF_UNITS" ;;
  }
  measure: total_number_of_units {
    type: sum
    label: "Total Number of Units"
    value_format: "#,##0"
    sql:  ${TABLE}."INVOICE_LINE_DETAILS_NUMBER_OF_UNITS" ;;
  }
}
