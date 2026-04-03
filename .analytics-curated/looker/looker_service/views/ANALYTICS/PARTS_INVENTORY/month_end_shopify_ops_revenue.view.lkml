view: month_end_shopify_ops_revenue {
  derived_table: {
    sql:
    select oh.created_timestamp::date as date
     , '#'||oh.order_number as order_names
     , oh.email
     , iff(oh.email ilike '%equipmentshare.com', 'es transfer', 'external customer') as customer_type
     , null as current_or_accrual
     , oh.source_name -- this has been miscategorizing certain orders sourced from ebay and amazon due to api failures from either vendor to shopify
     , case
         when oh.source_name  = 'shopify_draft_order' and (o.note ilike '%ebay%' or ot.tag_list ilike '%ebay%') then 'shopify_draft_order - ebay indicated'
         when oh.source_name  = 'shopify_draft_order' and (o.note ilike '%amazon%' or ot.tag_list ilike '%amazon%') then 'shopify_draft_order - amazon indicated'
       else oh.source_name end as updated_source_name
     , iff(customer_type = 'es transfer', 'es transfer', oh.sales_channel) as payout_vendor -- added per ethan request
     , case
         when customer_type = 'es transfer' then 'es transfer'
         when updated_source_name ilike '%amazon%' then 'Amazon'
         when updated_source_name ilike '%ebay%' then 'eBay'
        else oh.SALES_CHANNEL end as updated_payout_vendor -- expanded due to api failures indicated for source_name
     , ol.type
     , ol.order_line_id
     , ol.name
     , ol.sku
     , ol.price_per_unit
     , ol.quantity
     , iff(ol.type ilike 'product', pre_discount_total_line_amount, 0) as gross_sales
     , zeroifnull(-ol.discount_total) as discounts
     , iff(ol.type ilike '%refund%', pre_discount_total_line_amount, 0) as returns
     , iff(ol.type ilike '%ship%', pre_discount_total_line_amount, 0) as shipping
     , zeroifnull(ol.order_line_tax) as taxes
     , gross_sales + discounts + returns + shipping + taxes as total_sales
     , ol.order_id
     , ol.product_id
     , ol.variant_id
     , ol.inventory_item_id
     , zeroifnull(isc.product_cost) as productcost
     , iff(ol.type ilike '%return%', -(quantity * productcost), quantity * productcost) as line_item_cogs
    from fleet_optimization.GOLD.DIM_SHOPIFY_ORDER_LINE ol
    join FLEET_OPTIMIZATION.GOLD.DIM_SHOPIFY_ORDER_HEADER oh
        on ol.match_id = oh.match_id
join analytics.SHOPIFY."ORDER" o on oh.ORDER_ID = o.ID
    left join (select order_id
                , listagg(value, ', ') as tag_list
           from analytics.SHOPIFY.ORDER_TAG
           where value ilike '%ebay%'
              or value ilike '%amazon%'
           group by order_id) ot on oh.ORDER_ID = ot.ORDER_ID
    left join FLEET_OPTIMIZATION.GOLD.INT_SHOPIFY_COST isc
        on ol.inventory_item_id = isc.inventory_item_id
        and date_trunc(month, date) = isc.snapshot_month
    where oh.created_timestamp::date > '2025-04-30'
      ;;
  }


  dimension_group: order_date {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: order_name {
    type: string
    sql: ${TABLE}."ORDER_NAMES" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: customer_type {
    type: string
    sql: ${TABLE}."CUSTOMER_TYPE" ;;
  }

  dimension: current_or_accrual {
    type: string
    sql: ${TABLE}."CURRENT_OR_ACCRUAL" ;;
  }

  dimension: source_namee {
    type: string
    sql: ${TABLE}."UPDATED_SOURCE_NAME" ;;
  }

  dimension: payout_vendor {
    type: string
    sql: ${TABLE}."UPDATED_PAYOUT_VENDOR" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: order_line_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_LINE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  dimension: price_per_unit {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: gross_sales {
    type: number
    value_format_name: usd
    sql: ${TABLE}."GROSS_SALES" ;;
  }

  dimension: discounts {
    type: number
    value_format_name: usd
    sql: ${TABLE}."DISCOUNTS" ;;
  }

  dimension: returns {
    type: number
    value_format_name: usd
    sql: ${TABLE}."RETURNS" ;;
  }

  dimension: shipping {
    type: number
    value_format_name: usd
    sql: ${TABLE}."SHIPPING" ;;
  }

  dimension: taxes {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TAXES" ;;
  }

  dimension: total_sales {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_SALES" ;;
  }

  dimension: order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: product_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: variant_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."VARIANT_ID" ;;
  }

  dimension: inventory_item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: product_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PRODUCTCOST" ;;
  }

  dimension: line_item_cogs {
    type: number
    value_format_name: usd
    sql: case
          when ${type} = 'product refund' then -${TABLE}."LINE_ITEM_COGS"
          when ${gross_sales}+${discounts}=0 and ${gross_sales}<>0 then 0
          else ${TABLE}."LINE_ITEM_COGS"
         end ;;
  }

  # dimension: line_item_cogs_old { #modified per request from ethan g 10/28/25 - ka
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}."LINE_ITEM_COGS" ;;
  # }

}
