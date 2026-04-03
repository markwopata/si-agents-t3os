view: retail_sales_invoice_detail {
    derived_table: {
      sql:
with retail_sales_app_invoices as(
select distinct invoice_id
 from analytics.retail_sales.retail_sales_quotes)

select (case when rm.retail_territory is not null then rm.retail_territory else 'Other' end) as retail_territory
     , m.region_name
     , m.district
     , li.market_id
     , li.market_name
     , li.invoice_id
     , li.invoice_number
     , li.credit_note_id
     , li.credit_note_number
     , (case when li.credit_note_id is not null then 'credit' else 'sale' end) as transaction_type
     , li.line_item_type_id
     , li.line_item_type_name
     , li.billing_approved_date::date as gl_date
     , li.company_id
     , li.customer_name
     , li.invoice_memo
     , li.line_item_description
     , li.amount
     , li.asset_id
     , a.make
     , a.model
     , a.category
     , a.equipment_class
     , (case when a.category ilike '%attachment%' then 'Attachment' else 'Main Mover' end) as asset_type
     , (case when c.name = 'IES - Fleet Trade In' then 'Yes' else 'No' end) as trade_in_asset
     , (case when rsa.invoice_id is not null then 'Yes' else 'No' end) as in_retail_sales_app
 from analytics.intacct_models.int_admin_invoice_and_credit_line_detail as li
 left join retail_sales_app_invoices rsa on li.invoice_id = rsa.invoice_id
 join analytics.branch_earnings.market m on li.market_id = m.child_market_id
 left join analytics.dbt_seeds.seed_retail_market_map rm on m.market_id = rm.market_id
 left join analytics.assets.int_assets a on li.asset_id = a.asset_id
 left join es_warehouse.public.companies c on a.asset_company_id = c.company_id
 where li.line_item_type_id in(80,141,145,146,152,153)
  and ((li.credit_note_memo not ilike '%trade in%' and li.credit_note_memo not ilike '%trade-in%') or li.credit_note_memo is null)
  and li.AMOUNT <> 0
  and li.is_billing_approved = TRUE;;
    }

    dimension: retail_territory {
      type: string
      sql: ${TABLE}."RETAIL_TERRITORY" ;;
    }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension_group: gl_date{
    label: "GL Date"
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: asset_category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: trade_in_asset {
    label: "Trade-In Asset?"
    type: string
    sql: ${TABLE}."TRADE_IN_ASSET" ;;
  }

  dimension: in_retail_sales_app {
    type: string
    sql: ${TABLE}."IN_RETAIL_SALES_APP" ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: assets_sold {
    type: count_distinct
    sql: ${TABLE}."ASSET_ID" ;;
  }
}
