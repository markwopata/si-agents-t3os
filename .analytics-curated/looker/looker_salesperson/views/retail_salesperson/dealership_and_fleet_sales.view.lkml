view: dealership_and_fleet_sales {
  sql_table_name: "ANALYTICS"."RETAIL_SALES"."RETAIL_AND_FLEET_EQUIPMENT_SALES" ;;

  parameter: exclude_trade_in_value {
    type: yesno
    default_value: "no"
    description: "Exclude Trade-In Value from Revenue?"
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: credit_note_line_item_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: invoice_id {
    label: "InvoiceID"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_number {
    label: "InvoiceNo"
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: credit_note_id {
    label: "CreditNoteID"
    type: string
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension_group: gl_date{
    label: "GL Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: billing_approved_date{
    label: "Invoice Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: line_item_type_id {
    label: "Line Item Type ID"
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type_name {
    label: "Line Item Type"
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: sale_type {
    type: string
    sql: ${TABLE}."SALE_TYPE" ;;
  }

  dimension: dealership_sale {
    type: string
    sql: ${TABLE}."DEALERSHIP_SALE" ;;
  }

  dimension: in_retail_sales_app {
    type: string
    sql: ${TABLE}."IN_RETAIL_SALES_APP" ;;
  }

  dimension: line_item_description {
    label: "Line Item Description"
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}."ASSET_MAKE" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."ASSET_MODEL" ;;
  }

  dimension: asset_year {
    type: string
    sql: ${TABLE}."ASSET_YEAR" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: company_id {
    label: "CompanyID"
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: salesperson_id {
    label: "SalespersonID"
    type: string
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }

  dimension: sales_rep{
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: sales_cogs_source {
    type: string
    sql: ${TABLE}."SALES_COGS_SOURCE" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  measure: assets_sold {
    label: "Equipment Sold"
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSETS_SOLD" ;;
  }

  measure: attachments_sold {
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ATTACHMENTS_SOLD" ;;
  }

  measure: revenue_raw {
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: CASE
          WHEN {% parameter exclude_trade_in_value %} = 'yes' THEN ${TABLE}."REVENUE"
          WHEN ${TABLE}."TRANSACTION_TYPE" != 'Trade-In Credit' THEN ${TABLE}."REVENUE"
          ELSE 0
         END ;;
  }

  measure: revenue_less_trade_ins {
    label: "Revenue (Less Trade-In Value)"
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: sales_cogs {
    label: "Sales COGS"
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."SALES_COGS" ;;
  }

  measure: sales_margin {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: (case when ${TABLE}."TRANSACTION_TYPE" in('Revenue','Credit') then ${TABLE}."REVENUE" else 0 end) + ${TABLE}."SALES_COGS" ;;
  }

  measure: sales_margin_pct {
    label: "Sales Margin %"
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum((case when ${TABLE}."TRANSACTION_TYPE" in('Revenue','Credit') then ${TABLE}."REVENUE" else 0 end) + ${TABLE}."SALES_COGS")/nullifzero(sum(case when ${TABLE}."TRANSACTION_TYPE" in('Revenue','Credit') then ${TABLE}."REVENUE" else 0 end)) ;;
  }

  dimension: current_month {
    type: yesno
    sql: date_trunc('month',${TABLE}."BILLING_APPROVED_DATE"::date) = date_trunc('month',current_date);;
  }

  dimension: prior_month {
    type: yesno
    sql: date_trunc('month',${TABLE}."BILLING_APPROVED_DATE"::date) = dateadd('month',-1,date_trunc('month',current_date));;
  }

  measure: prior_month_assets_sold {
    type: sum
    value_format_name: decimal_2
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSETS_SOLD" ;;
  }

  measure: prior_month_revenue {
    type: sum
    value_format_name: decimal_2
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: CASE
          WHEN {% parameter exclude_trade_in_value %} = 'yes' THEN ${TABLE}."REVENUE"
          WHEN ${TABLE}."TRANSACTION_TYPE" != 'Trade-in Credit' THEN ${TABLE}."REVENUE"
          ELSE 0
         END ;;
  }

  measure: prior_month_revenue_less_trade_ins {
    label: "Prior Month Revenue (Less Trade-In Value)"
    type: sum
    value_format_name: decimal_2
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: prior_month_sales_cogs {
    label: "Prior Month Sales COGS"
    type: sum
    value_format_name: decimal_2
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."SALES_COGS" ;;
  }

  measure: prior_month_sales_margin {
    type: sum
    value_format_name: decimal_2
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: (case when ${TABLE}."TRANSACTION_TYPE" in('Revenue','Credit') then ${TABLE}."REVENUE" else 0 end) + ${TABLE}."SALES_COGS" ;;
  }

  measure: current_month_assets_sold {
    type: sum
    value_format_name: decimal_2
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSETS_SOLD" ;;
  }

  measure: current_month_revenue {
    type: sum
    value_format_name: decimal_2
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: CASE
          WHEN {% parameter exclude_trade_in_value %} = 'yes' THEN ${TABLE}."REVENUE"
          WHEN ${TABLE}."TRANSACTION_TYPE" != 'Trade-in Credit' THEN ${TABLE}."REVENUE"
          ELSE 0
         END ;;
  }

  measure: current_month_revenue_less_trade_ins {
    label: "Current Month Revenue (Less Trade-In Value)"
    type: sum
    value_format_name: decimal_2
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: current_month_sales_cogs {
    label: "Current Month Sales COGS"
    type: sum
    value_format_name: decimal_2
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."SALES_COGS" ;;
  }

  measure: current_month_sales_margin {
    type: sum
    value_format_name: decimal_2
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: (case when ${TABLE}."TRANSACTION_TYPE" in('Revenue','Credit') then ${TABLE}."REVENUE" else 0 end) + ${TABLE}."SALES_COGS" ;;
  }

  set: drill_fields {
    fields: [
      market_region_xwalk.market_name,
      invoice_id,
      invoice_number,
      billing_approved_date_raw,
      line_item_type_name,
      line_item_description,
      asset_id,
      asset_type,
      asset_make,
      asset_model,
      asset_year,
      equipment_category,
      equipment_class,
      sales_rep,
      revenue,
      revenue_less_trade_ins,
      sales_cogs,
      sales_margin,
      sales_margin_pct
    ]
  }
}
