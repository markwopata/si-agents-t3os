view: fact_invoice_line_details {
  sql_table_name: "PLATFORM"."GOLD"."FACT_INVOICE_LINE_DETAILS" ;;

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
    primary_key: yes
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
  dimension: in_out_of_home_market {
    type: string
    sql: CASE WHEN ${dim_markets.market_id} = ${v_dim_salesperson_enhanced.market_id_hist} THEN 'In home market' ELSE 'Not in home market' END ;;
  }
  measure: invoice_line_details_amount {
    type: sum
    label: "Revenue"
    value_format_name: usd
    drill_fields: [sale_drill*]
    sql: ${TABLE}."INVOICE_LINE_DETAILS_AMOUNT" ;;
  }
  measure: invoice_line_details_tax_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."INVOICE_LINE_DETAILS_TAX_AMOUNT" ;;
  }
  measure: count {
    type: count
    drill_fields: [sale_drill*]
  }
  parameter: metric_toggle {
    type: string
    allowed_value: { label: "Revenue" value: "rev" }
    allowed_value: { label: "Count"   value: "cnt" }
    default_value: "cnt"
  }
  measure: count_rev_toggle {
    type: number
    label: "Revenue or Count"
    sql:
    {% if metric_toggle._parameter_value == "'rev'" %}
      ${invoice_line_details_amount}
    {% else %}
      ${count}
    {% endif %};;
    drill_fields: [sale_drill*]
    }
  set: sale_drill {
    fields: [
    dim_assets.asset_id_with_t3_link,
    dim_assets.asset_equipment_make,
    dim_assets.asset_equipment_model_name,
    dim_assets.asset_serial_number,
    dim_companies.company_name,
    dim_markets.market_name,
    dim_users.user_full_name,
    v_dim_salesperson_enhanced.employee_title_hist,
    v_dim_dates_bi.date_date,
    dim_invoices.invoice_id_with_admin_link,
    dim_invoices.invoice_no,
    dim_line_items.line_item_type_id,
    dim_line_items.line_item_type_name,
    dim_line_items.line_item_category,
    fact_invoice_line_details.invoice_line_details_amount
    ]
  }
}
