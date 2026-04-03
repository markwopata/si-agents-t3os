view: fleet_status_new {

  derived_table: {
    sql:
      select
        cpoli.ASSET_ID                           as asset_id,
        cpoli.MARKET_ID                          as market_id,
        cpoli.ORDER_STATUS                       as order_status,
        cpoli.INVOICE_DATE                       as cpoli_invoice_date,
        cpoli.sales_tax                          as sales_tax,
        cpoli.REBATE                             as rebate,
        cpoli.NET_PRICE                          as net_price,
        cpoli.FREIGHT_COST                       as freight_cost,
        cpoli.INVOICE_NUMBER                     as cpoli_invoice_number,
        u.email_address                          as approved_by_email_address,
        cpoli.FINANCE_STATUS                     as finance_status,
        cpoli.RECONCILIATION_STATUS              as reconciliation_status,
        aph.PURCHASE_ORDER_URL                   as spo_number,
        aph.OEC                                  as oec,
        asg.make                                 as make,
        asg.model                                as model,
        asg.class                                as asset_class,
        asg.year                                 as year,
        aph.company_id                           as company_id,
        asg.owner                                as owner,
        i.INVOICE_NO                             as invoice_no,
        i.INVOICE_DATE                           as invoice_date,
        m.name                            as market_name
      from es_warehouse.public.company_purchase_order_line_items cpoli
      join es_warehouse.public.company_purchase_orders cpo
        on cpoli.company_purchase_order_id = cpo.company_purchase_order_id
      left join es_warehouse.public.users u
        on cpo.approved_by_user_id = u.user_id
      left join es_warehouse.public.assets_aggregate asg
        on cpoli.ASSET_ID = asg.ASSET_ID
      left join es_warehouse.public.ASSET_PURCHASE_HISTORY aph
        on asg.asset_id = aph.asset_id
      left join ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        on asg.ASSET_ID = li.ASSET_ID
      left join es_warehouse.public.INVOICES i
        on li.INVOICE_ID = i.INVOICE_ID
      left join es_warehouse.public.markets m
        on cpoli.market_id = m.market_id;;
  }

  # -------------------------
  # Keys / IDs
  # -------------------------
  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }


  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }

  # -------------------------
  # Status fields
  # -------------------------
  dimension: order_status {
    type: string
    sql: ${TABLE}.order_status ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}.finance_status ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}.reconciliation_status ;;
  }

  # -------------------------
  # Invoice / PO fields
  # -------------------------
  dimension: cpoli_invoice_number {
    type: string
    sql: ${TABLE}.cpoli_invoice_number ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: spo_number {
    type: string
    sql: ${TABLE}.spo_number ;;
  }

  dimension: oec {
    type: string
    sql: ${TABLE}.oec ;;
  }

  # -------------------------
  # People / ownership
  # -------------------------
  dimension: approved_by_email_address {
    type: string
    sql: ${TABLE}.approved_by_email_address ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}.owner ;;
  }

  # -------------------------
  # Asset attributes
  # -------------------------
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }

  # -------------------------
  # Money fields
  # -------------------------
  dimension: sales_tax {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sales_tax ;;
  }

  dimension: rebate {
    type: number
    value_format_name: usd
    sql: ${TABLE}.rebate ;;
  }

  dimension: net_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.net_price ;;
  }

  dimension: freight_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.freight_cost ;;
  }

  # -------------------------
  # Dates (dimension_groups)
  # -------------------------
  dimension_group: cpoli_invoice_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.cpoli_invoice_date ;;
  }

  dimension_group: invoice_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.invoice_date ;;
  }
}
