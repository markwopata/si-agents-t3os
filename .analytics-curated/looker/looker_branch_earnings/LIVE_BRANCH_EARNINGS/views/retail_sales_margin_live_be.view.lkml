view: retail_sales_margin_live_be {
  derived_table: {
    sql:
select be.region_name
     , be.district
     , be.market_id
     , be.market_name
     , be.account_number
     , be.account_name
     , be.gl_date::date as gl_date
     , be.gl_month
     , be.filter_month
     , be.additional_data:invoice_id as invoice_id
     , i.invoice_no
     , be.additional_data:asset_id as asset_id
     , be.description
     , be.amount
     , (case when be.revenue_expense = 'revenue' then be.amount else 0 end) as revenue_amount
     , (case when be.revenue_expense = 'expense' then be.amount else 0 end) as expense_amount
     , 'https://admin.equipmentshare.com/#/home/transactions/invoices/' || be.additional_data:invoice_id as invoice_url
     , be.url_admin as admin_url
     , be.admin_only_data
 from analytics.branch_earnings.INT_LIVE_BRANCH_EARNINGS_LOOKER be
 join analytics.branch_earnings.market m on be.market_id = m.child_market_id
 left join es_warehouse.public.invoices i on be.additional_data:invoice_id = i.invoice_id
 where be.account_number in('FBAA','FBBA','GBAA','GBBA','6101')
        ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }

  dimension: district{
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: account_number {
    label: "AccountNo"
    type: string
    sql: ${TABLE}.ACCOUNT_NUMBER ;;
  }

  dimension: account_name {
    label: "Account"
    type: string
    sql: ${TABLE}.ACCOUNT_NAME ;;
  }

  dimension: gl_date {
    label: "GL Date"
    type: date
    sql: ${TABLE}.GL_DATE ;;
  }

  dimension: gl_month{
    type: date
    sql: ${TABLE}.GL_MONTH ;;
  }

  dimension: filter_month{
    label: "GL Month"
    type: string
    sql: ${TABLE}.FILTER_MONTH ;;
  }

  dimension: invoice_id {
    label: "InvoiceID"
    type: number
    sql: ${TABLE}.INVOICE_ID ;;
  }

  dimension: invoice_no {
    label: "Invoice No"
    type: string
    sql: ${TABLE}.INVOICE_NO ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: description {
    label: "Description"
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  measure: amount {
    label: "Amount"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: revenue {
    label: "Revenue"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE_AMOUNT" ;;
  }

  measure: expense {
    label: "Expense"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."EXPENSE_AMOUNT" ;;
  }

  measure: margin {
    label: "Margin"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE_AMOUNT" + ${TABLE}."EXPENSE_AMOUNT" ;;
  }

  measure: margin_pct {
    label: "Margin %"
    type: number
    value_format_name: percent_2
    sql: CASE
          WHEN NULLIF(SUM(${TABLE}."REVENUE_AMOUNT"),0) IS NOT NULL THEN
           (SUM(${TABLE}."REVENUE_AMOUNT") + SUM(${TABLE}."EXPENSE_AMOUNT"))/NULLIF(SUM(${TABLE}."REVENUE_AMOUNT"),0)
         END;;
  }

  dimension: invoice_url {
    label: "Invoice Link"
    type: string
    html: {% if value != null %}
          <a href = "{{ value }}" target="_blank">
          <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
          &nbsp;
          {% endif %};;
    sql: ${TABLE}.invoice_url;;
  }

  dimension: admin_url {
    label: "Admin Link"
    type: string
    html: {% if value != null %}
          <a href = "{{ value }}" target="_blank">
          <img src="https://assets-global.website-files.com/60cb2013a506c737cfeddf74/615b728bc86ddc3555605abc_EquipmentShare-Favicon.png" width="16" height="16"> Admin</a>
          &nbsp;
          {% endif %};;
    sql: ${TABLE}.admin_url;;
  }

  dimension: admin_only_data {
    type: yesno
    sql: ${TABLE}."ADMIN_ONLY_DATA" ;;
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${TABLE}.district in ({{ _user_attributes['district'] }}) OR ${TABLE}.region_name in ({{ _user_attributes['region'] }}) OR ${TABLE}.market_id in ({{ _user_attributes['market_id'] }}) ;;
  }

}
