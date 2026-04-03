view: fleet_status {
  derived_table: {
    sql:
      select
        cpoli.market_id,
        m.name as market_name,
        cpoli.company_purchase_order_id,
        cpoli.company_purchase_order_line_item_id,
        cpoli.invoice_date,
        cpoli.asset_id,
        cpoli.order_status,
        --cpot.name as vendor_name,
        model,
        cpoli.factory_build_specifications as descr,
        cpoli.quantity,
        cpoli.net_price,
        cpoli.sales_tax,
        cpoli.rebate,
        cpoli.freight_cost,
        asg.owner,
        u.email_address,
        afp.VENDOR_NAME,
        afp.po_make,
        cpoli.invoice_number,
        inv.invoice_no as sales_invoice_number,
        inv.date_created as sales_invoice_date,
        aph.PURCHASE_ORDER_URL AS spo_number
    from es_warehouse.public.company_purchase_order_line_items cpoli
    join es_warehouse.public.company_purchase_orders cpo
      on cpoli.company_purchase_order_id = cpo.company_purchase_order_id
    left join analytics.anaplan.ANAPLAN_FLEET_PURCHASING afp
        on cpoli.COMPANY_PURCHASE_ORDER_ID = afp.PURCHASE_ORDER_ID
        and cpoli.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER = afp.line_item_number
    join es_warehouse.public.company_purchase_order_types cpot
      on cpo.company_purchase_order_type_id = cpot.company_purchase_order_type_id
    left join es_warehouse.public.users u
      on cpo.approved_by_user_id = u.user_id
    left join es_warehouse.public.markets m
      on cpoli.market_id = m.market_id
    left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE asg
      on cpoli.ASSET_ID = asg.ASSET_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY AS aph
      ON asg.ASSET_ID = aph.ASSET_ID
          left join ES_WAREHOUSE.public.INVOICES inv
      on cpoli.COMPANY_PURCHASE_ORDER_LINE_ITEM_ID = inv.INVOICE_ID;;
  }

  dimension: vendor_name {
    description: "Vendor Name"
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: invoice_number {
    description: "invoice number"
    type: string
    sql: ${TABLE}.invoice_number ;;
  }

  dimension: sales_invoice_number {
    description: "invoice number"
    type: string
    sql: ${TABLE}.sales_invoice_number ;;
  }

  dimension: spo_number {
    description: "spo_number"
    type: string
    sql: ${TABLE}.spo_number ;;
  }

  dimension: sales_invoice_date {
    description: "invoice date"
    type: date
    sql: ${TABLE}.sales_invoice_date ;;
  }

  dimension: owner {
    description: "owner"
    type: string
    sql: ${TABLE}.owner ;;
  }

  dimension: model {
    description: "model"
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: po_make {
    description: "po make"
    type: string
    sql: ${TABLE}.po_make ;;
  }

  dimension: market_id {
    description: "Market ID"
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    description: "Market Name"
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: company_purchase_order_id {
    description: "company purchase order id"
    type: string
    sql: ${TABLE}.company_purchase_order_id ;;
  }

  dimension: company_purchase_order_line_item_id {
    description: "company purchase order line item id"
    type: string
    sql: ${TABLE}.company_purchase_order_line_item_id ;;
  }

  dimension: invoice_date {
    description: "invoice date"
    type: date
    sql: ${TABLE}.invoice_date ;;
  }

  dimension: asset_id {
    description: "asset id"
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: order_status {
    description: "order status"
    type: string
    sql: ${TABLE}.order_status ;;
  }

  dimension: descr {
    description: "Description"
    type: string
    sql: ${TABLE}.descr ;;
  }

  measure: quantity {
    description: "quantity"
    type: sum
    sql: ${TABLE}.quantity ;;
  }

  measure: net_price {
    description: "net price"
    type: sum
    sql: ${TABLE}.net_price ;;
  }

  measure: sales_tax {
    description: "sales tax"
    type: sum
    sql: ${TABLE}.sales_tax ;;
  }

  measure: rebate {
    description: "rebate"
    type: sum
    sql: ${TABLE}.rebate ;;
  }

  measure: freight_cost {
    description: "frieght cost"
    type: sum
    sql: ${TABLE}.freight_cost ;;
  }

  dimension: email_address {
    description: "email"
    type: string
    sql: ${TABLE}.email_address ;;
  }

}
