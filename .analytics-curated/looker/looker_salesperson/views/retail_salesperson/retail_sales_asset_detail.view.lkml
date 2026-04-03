view: retail_sales_asset_detail {
  derived_table: {
    sql:
    with invoiced_revenue as(
    select ld.invoice_id
         , ld.invoice_number
         , ld.invoice_memo
         , ld.billing_approved_date::date as billing_approved_date
         , ld.company_id
         , ld.customer_name
         , ld.asset_id
         , ld.primary_salesperson_id
         , u.first_name || ' ' || u.last_name as sales_rep
         , (case
             when ld.line_item_type_id in(80,153,145) then 'New Dealership Sales'
             when ld.line_item_type_id in(141,152,146) then 'Used Dealership Sales'
            end) as sale_type
         , sum(ld.amount) as invoiced_revenue
     from analytics.intacct_models.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL ld
     left join es_warehouse.public.users u on ld.primary_salesperson_id = u.user_id
     where line_item_type_id in(80,141,145,146,152,153)
      and is_billing_approved = TRUE
     group by all)

      select ad.asset_pk_id as pk_id
      , ad.quote_created_at
      , ad.quote_completed_at
      , ad.status
      , ad.quote_id
      , ad.invoice_id
      , ad.billing_provider
      , coalesce(i.company_id,ad.company_id) as company_id
      , coalesce(i.customer_name,ad.company_name) as company_name
      , ad.type_of_sale
      , ad.market_id
      , ad.asset_pk_id
      , (case
      when ia.category ilike '%attachment%' then 'Attachment'
      when ia.category is not null then 'Equipment'
      when ad.asset_type = 'attachment' then 'Attachment'
      when ad.asset_type = 'asset' then 'Equipment'
      else 'Equipment'
      end) as asset_type
      , ad.asset_id
      , coalesce(ia.serial_number,ad.serial_number) as serial_number
      , coalesce(ia.make,ad.asset_make) as make
      , coalesce(ia.model,ad.asset_model) as model
      , ad.asset_description as description
      , ad.asset_oec as asset_oec
      , ad.asset_additional_item_revenue
      , ad.asset_additional_item_cost
      , ad.asset_trade_in_cost
      , ad.asset_revenue
      , ad.asset_cost
      , ad.asset_rebate
      , ad.asset_margin
      , coalesce(ia.equipment_class_id,ad.equipment_class_id) as equipment_class_id
      , coalesce(ia.equipment_class,ad.equipment_class) as equipment_class
      , coalesce(ia.category_id,ad.category_id) as category_id
      , coalesce(ia.category,ad.category) as category
      , coalesce(i.primary_salesperson_id,qd.salesperson_user_id) as salesperson_user_id
      , coalesce(i.sales_rep,qd.salesperson_name) as salesperson_name
      , qd.salesperson_email
      , qd.parent_market_id
      , qd.payment_method
      , i.billing_approved_date
      , i.invoice_number as invoice_no
      , i.invoice_memo
      , i.sale_type
      , i.invoiced_revenue
      , date_trunc(month,ad.quote_completed_at::date) as quote_completed_month
      , TO_CHAR(ad.quote_completed_at, 'MON-YY') AS month_year
      from analytics.retail_sales.retail_sales_assets ad
      left join analytics.retail_sales.retail_sales_quotes qd on ad.quote_id = qd.quote_id
      left join invoiced_revenue i on ad.invoice_id = i.invoice_id and ad.asset_id = i.asset_id
      left join analytics.assets.int_assets ia on ad.asset_id = ia.asset_id
      ;;
  }

  dimension: pk_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_ID" ;;
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
    label: "Invoice Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: status{
    label: "Status"
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: quote_id{
    type: number
    value_format_name: id
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: invoice_id{
    type: number
    value_format_name: id
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id}}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }

  dimension: invoice_id_with_BE_link {
    type: number
    description: "Link to Branch Earnings - Dealership Sales Margin dashboard to see margin and profit details"
    html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards/1109?Market+Name=&Invoice+Number={{invoice_no}}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: billing_provider {
    type: string
    sql: ${TABLE}."BILLING_PROVIDER" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: type_of_sale {
    type: string
    sql: ${TABLE}."TYPE_OF_SALE" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: parent_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD" ;;
  }

  dimension: asset_pk_id {
    type: string
    sql: ${TABLE}."ASSET_PK_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: quote_id_with_link {
    type: number
    html: <font color="blue "><u><a href="https://equipmentshare-dev.retool-hosted.com/app/retail-sales/existingQuotes?quote_id={{quote_id}}" target="_blank">{{ quote_id._value }}</a></font></u> ;;
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

  measure: open_complete_quote {
    label: "Open or Complete Quote"
    type: sum
    sql: case
          when ${TABLE}."STATUS" = 'complete' then 1
          when ${TABLE}."STATUS" in('customer approved','draft','gm approved','pending gm approval', 'submitted for invoicing','denied') then 1
          else 0
         end;;
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

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: category {
    label: "Equipment Category"
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: current_month {
    type: yesno
    sql: date_trunc('month',${TABLE}."BILLING_APPROVED_DATE"::date) = date_trunc('month',current_date);;
  }

  dimension: prior_month {
    type: yesno
    sql: date_trunc('month',${TABLE}."BILLING_APPROVED_DATE"::date) = dateadd('month',-1,date_trunc('month',current_date));;
  }

  dimension: current_quarter {
    type: yesno
    sql: date_trunc('quarter',${TABLE}."BILLING_APPROVED_DATE"::date) = date_trunc('quarter',current_date) ;;
  }

  dimension: prior_quarter {
    type: yesno
    sql: date_trunc('quarter',${TABLE}."BILLING_APPROVED_DATE"::date) = dateadd('quarter',-1,date_trunc('quarter',current_date)) ;;
  }

  dimension: current_year {
    type: yesno
    sql: year(${TABLE}."BILLING_APPROVED_DATE"::date) = year(current_date) ;;
  }

  dimension: prior_year {
    type: yesno
    sql: year(${TABLE}."BILLING_APPROVED_DATE"::date) = year(current_date) - 1 ;;
  }

  dimension: prior_month_mtd {
    type: yesno
    sql: date_trunc('month',${TABLE}."BILLING_APPROVED_DATE"::date) = dateadd('month',-1,date_trunc('month',current_date))
      and date_part(day,${TABLE}."BILLING_APPROVED_DATE"::date) <= date_part(day,current_date);;
  }

  measure: quote_completetion_days {
    label: "Days to Complete Quote"
    type: average
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."DAYS_TO_COMPLETE" ;;
  }

  measure: sale_count{
    label: "Sale Count"
    type: count_distinct
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  measure: asset_count {
    label: "Asset Count"
    type: count
    drill_fields: [drill_fields*]
  }

  measure: quote_count {
    label: "Quote Count"
    type: number
    sql: count(distinct ${TABLE}."QUOTE_ID");;
    drill_fields: [drill_fields*]
  }

  measure: equipment_asset_count {
    label: "Equipment Asset Count"
    type: sum
    sql: CASE WHEN ${asset_type} = 'Equipment' THEN 1 ELSE 0 END ;;
    drill_fields: [drill_fields*]
  }

  measure: avg_asset_count {
    label: "Avg Assets per Quote"
    type: number
    value_format_name: decimal_2
    sql: sum(CASE WHEN ${TABLE}."ASSET_TYPE" = 'Equipment' THEN 1 ELSE 0 END)
      / count(distinct ${TABLE}."QUOTE_ID") ;;
  }

  measure: avg_quote_value {
    label: "Avg Value per Quote"
    type: number
    value_format_name: decimal_2
    sql: sum(${TABLE}."ASSET_REVENUE")
      / count(distinct ${TABLE}."QUOTE_ID") ;;
  }

  measure: total_asset_price{
    label: "Quoted Sales Revenue"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_REVENUE" ;;
  }

  measure: asset_cost{
    label: "Sales Expense"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_COST" ;;
  }

  measure: total_rebate{
    label: "Sales Rebates"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_REBATE" ;;
  }

  measure: total_margin{
    label: "Sales Margin"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_MARGIN" ;;
  }

  measure: total_margin_pct{
    label: "Sales Margin Percent"
    type: number
    value_format_name: percent_1
    drill_fields: [drill_fields*]
    sql:
    CASE
      WHEN NULLIF(SUM(${TABLE}."ASSET_REVENUE"), 0) IS NOT NULL
        THEN SUM(${TABLE}."ASSET_MARGIN") / NULLIF(SUM(${TABLE}."ASSET_REVENUE"), 0)
    END ;;
  }

  measure: sales_expense_net_rebates {
    label: "Sales Expense (Net Rebates)"
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_COST" - ${TABLE}."ASSET_REBATE" ;;
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

  measure: current_month_asset_count {
    label: "Current Month Asset Count"
    type: count
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
  }

  measure: prior_month_asset_count {
    label: "Prior Month Asset Count"
    type: count
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
  }

  measure: prior_month_mtd_asset_count {
    label: "Prior Month MTD Asset Count"
    type: count
    filters: [prior_month_mtd: "Yes"]
    drill_fields: [drill_fields*]
  }

  measure: current_month_asset_price {
    label: "Current Month Sales Revenue"
    type: sum
    value_format_name: usd
    filters: [current_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_REVENUE" ;;
  }

  measure: prior_month_asset_price {
    label: "Prior Month Sales Revenue"
    type: sum
    value_format_name: usd
    filters: [prior_month: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_REVENUE" ;;
  }

  measure: prior_month_mtd_asset_price {
    label: "Prior Month MTD Sales Revenue"
    type: sum
    value_format_name: usd
    filters: [prior_month_mtd: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."ASSET_REVENUE" ;;
  }

  measure: invoiced_revenue {
    type: sum
    value_format_name: usd
    drill_fields: [drill_fields*]
    sql: ${TABLE}."INVOICED_REVENUE" ;;
  }

  measure: current_quarter_invoiced_revenue {
    label: "Current Quarter Revenue"
    type: sum
    value_format_name: usd
    filters: [current_quarter: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."INVOICED_REVENUE" ;;
  }

  measure: prior_quarter_invoiced_revenue {
    label: "Prior Quarter Revenue"
    type: sum
    value_format_name: usd
    filters: [prior_quarter: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."INVOICED_REVENUE" ;;
  }

  measure: current_year_invoiced_revenue {
    label: "Current Year Revenue"
    type: sum
    value_format_name: usd
    filters: [current_year: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."INVOICED_REVENUE" ;;
  }

  measure: prior_year_invoiced_revenue {
    label: "Prior Year Revenue"
    type: sum
    value_format_name: usd
    filters: [prior_year: "Yes"]
    drill_fields: [drill_fields*]
    sql: ${TABLE}."INVOICED_REVENUE" ;;
  }

  #measure: current_month_total_margin_pct{
  #  label: "Current Month Sales Margin Percent"
  #  type: number
  #  value_format_name: percent_1
  #  filters: [current_month: "Yes"]
  #  drill_fields: [drill_fields*]
  #  sql:
  #  CASE
  #    WHEN NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0) IS NOT NULL
  #      THEN SUM(${TABLE}."TOTAL_MARGIN") / NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0)
  #  END ;;
  #}
  #
  #measure: prior_month_total_margin_pct{
  #  label: "Prior Month Sales Margin Percent"
  #  type: number
  #  value_format_name: percent_1
  #  filters: [prior_month: "Yes"]
  #  drill_fields: [drill_fields*]
  #  sql:
  #  CASE
  #    WHEN NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0) IS NOT NULL
  #      THEN SUM(${TABLE}."TOTAL_MARGIN") / NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0)
  #  END ;;
  #}
  #
  #measure: prior_month_mtd_total_margin_pct{
  #  label: "Prior Month MTD Sales Margin Percent"
  #  type: number
  #  value_format_name: percent_1
  #  filters: [prior_month_mtd: "Yes"]
  #  drill_fields: [drill_fields*]
  #  sql:
  #  CASE
  #    WHEN NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0) IS NOT NULL
  #      THEN SUM(${TABLE}."TOTAL_MARGIN") / NULLIF(SUM(${TABLE}."TOTAL_ASSET_PRICE"), 0)
  #  END ;;
  #}

  set: drill_fields {
    fields: [
      market_region_xwalk.market_name,
      quote_id_with_link,
      invoice_id_with_BE_link,
      asset_id,
      make,
      model,
      equipment_class,
      category,
      billing_approved_date_date,
      quote_completed_at_date,
      salesperson_name,
      status,
      invoiced_revenue,
      total_asset_price,
      sales_expense_net_rebates,
      total_margin,
      total_margin_pct
    ]
  }
}
