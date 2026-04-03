view: retail_sales_quote_detail {
  derived_table: {
    sql:
    select qd.*
         , i.billing_approved_date
         , split_part(i.invoice_no,'-',1) as invoice_no
         , date_trunc(month,qd.quote_completed_at::date) as quote_completed_month
         , TO_CHAR(qd.quote_completed_at, 'MON-YY') AS month_year
     from analytics.retail_sales.retail_sales_quotes qd
     left join es_warehouse.public.invoices i on qd.invoice_id = i.invoice_id;;
  }

  dimension: quote_id{
    type: number
    value_format_name: id
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: quote_id_with_link {
    type: number
    html: <font color="blue "><u><a href="https://equipmentshare.retool-hosted.com/app/retail-sales/existingQuotes?quote_id={{quote_id}}" target="_blank">{{ quote_id._value }}</a></font></u> ;;
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: salesperson_user_id{
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_name{
    label: "Salesperson"
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_email{
    label: "Salesperson Email"
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL" ;;
  }

  dimension: parent_market_id{
    label: "MarketID"
    type: number
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: grouping{
    type: string
    sql: ${TABLE}."GROUPING" ;;
  }

  dimension: status{
    label: "Status"
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: open_closed_lost {
    label: "Quote Status"
    type: string
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 'Complete'
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing', 'denied') then 'Open'
          when ${TABLE}."STATUS" in('lost sale') then 'Lost'
          else 'Check'
         end;;
  }

  measure: complete_quote {
    label: "Complete Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 1
          else 0
         end;;
  }

  measure: lost_quote {
    label: "Lost Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" = 'lost sale' then 1
          else 0
         end;;
  }

  measure: open_complete_quote {
    label: "Open or Complete Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 1
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing', 'denied') then 1
          else 0
         end;;
  }

  measure: open_quote {
    label: "Open Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing', 'denied') then 1
          else 0
         end;;
  }

  dimension_group: quote_created_at{
    label: "Quote Created At"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."QUOTE_CREATED_AT" ;;
  }

  dimension_group: quote_completed_at{
    label: "Quote Completed At"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."QUOTE_COMPLETED_AT" ;;
  }

  dimension_group: billing_approved_date{
    label: "GL Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: quote_completed_month {
    label: "Quote Completed Month"
    type: date
    sql: ${TABLE}."QUOTE_COMPLETED_MONTH" ;;
  }

  dimension: month_year {
    label: "Month"
    type: string
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: quote_date_filter {
    label: "Quote Date Filter"
    type: date
    sql: case
          when ${TABLE}."QUOTE_COMPLETED_AT" is not null then date_trunc(month,${TABLE}."QUOTE_COMPLETED_AT"::date)
          when ${TABLE}."STATUS" in ('denied','lost sale') then date_trunc(month,${TABLE}."QUOTE_CREATED_AT"::date)
          else date_trunc(month,CURRENT_DATE)
         end ;;
  }

  dimension: billing_provider {
    label: "Billing Provider"
    type: string
    sql: ${TABLE}."BILLING_PROVIDER" ;;
  }

  dimension: retail_territory {
    label: "Retail Territory"
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: invoice_id {
    type: number
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: number
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_id_with_BE_link {
    type: number
    description: "Link to Branch Earnings - Dealership Sales Margin dashboard to see margin and profit details"
    html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards/1109?Market+Name=&Invoice+Number={{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: secondary_salesperson_user_id {
    type: number
    sql: ${TABLE}."SECONDARY_SALESPERSON_USER_ID" ;;
  }

  dimension: type_of_sale {
    type: string
    sql: ${TABLE}."TYPE_OF_SALE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }

  dimension: secondary_salesperson_name {
    label: "Secondary Salesperson"
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_NAME" ;;
  }

  dimension: secondary_salesperson_email {
    label: "Secondary Salesperson Email"
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_EMAIL" ;;
  }

  measure: quote_completion_days {
    label: "Days to Complete Quote"
    type: average
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."DAYS_TO_COMPLETE" ;;
  }

  measure: quote_completion_hours{
    label: "Hours to Complete Quote"
    type: average
    value_format_name: "decimal_2"
    drill_fields: [drill_fields*]
    sql: TIMESTAMPDIFF(hour,${TABLE}."QUOTE_CREATED_AT",${TABLE}."QUOTE_COMPLETED_AT");;
  }

  measure: asset_count{
    label: "Asset Count"
    type: sum
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  measure: row_count {
    label: "Sales Count"
    type: count
    drill_fields: [drill_fields*]
  }

  measure: completed_sales {
    label: "Completed Sales"
    type: count
    filters: [open_closed_lost: "Complete"]
    drill_fields: [drill_fields*]
  }

  measure: open_quotes {
    label: "Open Quotes"
    type: count
    filters: [open_closed_lost: "Open"]
    drill_fields: [drill_fields*]
  }

  measure: lost_quotes {
    label: "Lost Quotes"
    type: count
    filters: [open_closed_lost: "Lost"]
    drill_fields: [drill_fields*]
  }

  measure: total_price{
    label: "Sales Revenue"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUOTE_REVENUE" ;;
  }

  measure: total_cost{
    label: "Sales Expense"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUOTE_COST" ;;
  }

  measure: total_margin{
    label: "Sales Margin"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUOTE_MARGIN" ;;
  }

  measure: total_margin_pct{
    label: "Sales Margin Percent"
    type: number
    value_format_name: percent_1
    drill_fields: [drill_fields*]
    sql:
    CASE
      WHEN NULLIF(SUM(${TABLE}."QUOTE_REVENUE"), 0) IS NOT NULL
        THEN SUM(${TABLE}."QUOTEL_MARGIN") / NULLIF(SUM(${TABLE}."QUOTE_REVENUE"), 0)
    END ;;
  }

  measure: sales_expense_net_rebates {
    label: "Sales Expense (Net Rebates)"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUOTE_REVENUE" - ${TABLE}."QUOTE_REBATE" ;;
  }

  measure: quote_close_rate {
    label: "Quote Close Rate"
    type: number
    value_format_name: percent_1
    drill_fields: [drill_fields*]
    sql: sum(case
          when ${TABLE}."STATUS" = 'complete' then 1
          else 0
         end)
         /
        nullif(sum(case
          when ${TABLE}."STATUS" = 'complete' then 1
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing', 'denied') then 1
          else 0
         end),0)
        ;;
  }

  set: drill_fields {
    fields: [
      market_region_xwalk.market_name,
      quote_id_with_link,
      invoice_id,
      billing_approved_date_date,
      quote_completed_at_date,
      salesperson_name,
      v_dim_salesperson_enhanced.employee_title_hist,
      v_dim_salesperson_enhanced.market_name_hist,
      status,
      dim_invoices.invoice_paid,
      asset_count,
      total_price,
      sales_expense_net_rebates,
      total_margin,
      total_margin_pct
    ]
  }

  parameter: geo_granularity {
    description: "Group data in this dashboard at a geographic granularity"
    allowed_value: {
      label: "Retail Territory"
      value: "Retail Territory"
    }
    allowed_value: {
      label: "Region"
      value: "Region"
    }
    allowed_value: {
      label: "District"
      value: "District"
    }

    allowed_value: {
      label: "Market"
      value: "Market"
    }
  }
}
