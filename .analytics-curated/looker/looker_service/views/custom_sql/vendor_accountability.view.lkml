view: vendor_accountability {
  derived_table: {
    sql: with final as (select distinct p.PART_ID
                             , pr.name                                           as provider_name
                             , p.PART_NUMBER
                             , p.SEARCH
                             , p.provider_id
                             , p.msrp
                             , po.EXTERNAL_ERP_VENDOR_REF                        as vendor
                             , po.purchase_order_number
                             , po.purchase_order_id
                             , po.REQUESTING_BRANCH_ID                           as market_id -- subject to change
                             , np.NET_PRICE
                             , poli.PURCHASE_ORDER_LINE_ITEM_ID
                             , poli.PRICE_PER_UNIT                               as po_ppu
                             , poli.QUANTITY
                             , pori.PURCHASE_ORDER_RECEIVER_ITEM_ID
                             , pori.PRICE_PER_UNIT                               as por_ppu
                             , pori.ACCEPTED_QUANTITY
                             , abd.DEBIT_OR_CREDIT
                             , abd.LINE_ITEM_DESCRIPTION
                             , abd.LINE_ITEM_UNIT_PRICE                          as concur_invoice_ppu
                             , abd.LINE_ITEM_QUANTITY                            as concur_invoice_qty
                             , abd.LINE_ITEM_UNIT_PRICE * abd.LINE_ITEM_QUANTITY as concur_line_item_total
                             , abd.VENDOR_INVOICE_NUMBER
                             , abd.invoice_date
                             , pode.PRICE                                        as sage_po_ppu
                             , CONCAT('https://api.equipmentshare.com/skunkworks/invoices/request-image/',
                                      ABD.REQUEST_ID,
                                      '?redirect=1')                             as invoice_url

               from ES_WAREHOUSE.INVENTORY.PARTS p -- get item_id
                        left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
                                  on p.PROVIDER_ID = pr.PROVIDER_ID
                        join ANALYTICS.PUBLIC.ES_COMPANIES ec
                             on p.COMPANY_ID = ec.COMPANY_ID and ec.owned -- only es accessible parts data
                        join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli -- points me to correct receiver info --27 rows
                             on p.ITEM_ID = poli.ITEM_ID
                        join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS pori -- needed to match t3_line_item_id --18 rows
                             on poli.PURCHASE_ORDER_LINE_ITEM_ID = pori.PURCHASE_ORDER_LINE_ITEM_ID
                        join (select *, po.COMPANY_ID as huh
                              from PROCUREMENT.PUBLIC.PURCHASE_ORDERS po --18 rows

                                       left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
                                                 on po.vendor_ID = e.entity_ID
                                       left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
                                                 on e.entity_ID = evs.entity_ID) po
                             on po.purchase_order_id = poli.purchase_order_id

                        left join ANALYTICS.INTACCT.PODOCUMENTENTRY pode
                                  on pori.PURCHASE_ORDER_RECEIVER_ITEM_ID = pode.T3_LINE_ITEM_ID
                        left join ANALYTICS.CONCUR.APPROVED_BILL_DETAIL abd
                                  ON (ABD.ASSOCIATED_PO_LINE_ITEM_EXTERNAL_ID = pode.RECORDNO
                                      AND pode.DOCPARID = 'Purchase Order'
                                      )
                        left join (select v.mapped_vendor_name
                                        , v.vendor_name
                                        , v.vendorid
                                        , v.primary_vendor
                                        , v.primary_vendor_pricing
                                        , iff(primary_vendor_pricing = 'YES',
                                              max(iff(primary_vendor = 'YES', vendorid, null))
                                                  over (partition by mapped_vendor_name), vendorid) pricing_vendor_id
                                   from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING v) pv
                                  on po.EXTERNAL_ERP_VENDOR_REF = pv.vendorid
                        left join analytics.parts_inventory.net_price np
                            on p.part_id = np.part_id -- Switching back to part ID -- TA 12/9/25
                                  -- on p.part_number = np.part_number --procurement requested we switch this to join on part number not id to capture 3rd party better, i did warn this could lead to false matches. HL 4.25.25
                                      and po.date_created between np.start_date and np.end_date
                                      and coalesce(pv.pricing_vendor_id, po.EXTERNAL_ERP_VENDOR_REF) = np.vendor_id
                                      and poli._ES_UPDATE_TIMESTAMP between np.start_date and np.end_date)

     -- , test as (
select inv.PURCHASE_ORDER_NUMBER
     , inv.purchase_order_id
     , inv.market_id
     , inv.vendor
     , ven.name                                              as vendor_name
     , inv.VENDOR_INVOICE_NUMBER                             as invoice_number
     , inv.provider_name
     , inv.provider_id
     , inv.part_id
     , inv.PART_NUMBER
     , inv.T3_part_description
     , inv.invoice_line_item_desc
     , inv.net_price
     , inv.msrp
     , inv.po_ppu
     , inv.invoice_ppu
     , abs(inv.NET_PRICE - inv.invoice_ppu)                  as abs_net_vs_inv_diff
     , inv.invoice_url
     , inv.invoice_date
     , apd.URL_INVOICE                                       as sage_link -- not 100% populated
     , inv.invoice_qty
     , inv.invoice_ppu * inv.invoice_qty                     as invoice_line_item_total
     --  credit memo info for select
--      , cm.PURCHASE_ORDER_NUMBER as cm_po
--      , cm.VENDOR_INVOICE_NUMBER as credit_memo_number
--      , cm.credit_memo_line_item_desc
--      , cm.credit_memo_ppu
--      , cm.credit_memo_qty
     , cm.credit_memo_ppu * cm.credit_memo_qty               as credit_memo_line_item_total
     , invoice_line_item_total + credit_memo_line_item_total as leftover_line_item_amount
     , pcs.category
     , pcs.subcategory
from (select PURCHASE_ORDER_NUMBER
           , purchase_order_id
           , vendor
           , vendor_invoice_number
           , provider_name
           , provider_id
           , part_id
           , PART_NUMBER
           , search                  as T3_part_description
           , PURCHASE_ORDER_LINE_ITEM_ID
           , LINE_ITEM_DESCRIPTION   as invoice_line_item_desc
           , net_price
           , msrp
           , po_ppu
           , concur_invoice_ppu      as invoice_ppu
           , sum(concur_invoice_qty) as invoice_qty
           , invoice_url
           , invoice_date
           , market_id
      from final
      where DEBIT_OR_CREDIT = 'DR'
      group by PURCHASE_ORDER_NUMBER
             , purchase_order_id
             , vendor
             , VENDOR_INVOICE_NUMBER
             , provider_name
             , provider_id
             , part_id
             , PART_NUMBER
             , search
             , PURCHASE_ORDER_LINE_ITEM_ID
             , LINE_ITEM_DESCRIPTION
             , NET_PRICE
             , msrp
             , po_ppu
             , concur_invoice_ppu
             , invoice_url
             , invoice_date
             , market_id) inv
         left join (select PURCHASE_ORDER_NUMBER
                         , VENDOR_INVOICE_NUMBER
                         , PART_NUMBER
                         , PURCHASE_ORDER_LINE_ITEM_ID
                         , LINE_ITEM_DESCRIPTION   as credit_memo_line_item_desc
                         , concur_invoice_ppu      as credit_memo_ppu
                         , sum(concur_invoice_qty) as credit_memo_qty
                    from final
                    where DEBIT_OR_CREDIT = 'CR'
                    group by PURCHASE_ORDER_NUMBER, VENDOR_INVOICE_NUMBER, PART_NUMBER,
                             PURCHASE_ORDER_LINE_ITEM_ID,
                             LINE_ITEM_DESCRIPTION, concur_invoice_ppu) cm
                   on inv.PURCHASE_ORDER_NUMBER = cm.PURCHASE_ORDER_NUMBER
                       and inv.PART_NUMBER = cm.PART_NUMBER
                       and inv.invoice_ppu = abs(cm.credit_memo_ppu)
         left join (select distinct vendor_id, invoice_number, url_invoice
                    from "ANALYTICS"."INTACCT_MODELS"."AP_DETAIL") apd
                   on inv.VENDOR_INVOICE_NUMBER = apd.INVOICE_NUMBER and inv.vendor = apd.VENDOR_ID
         left join analytics.intacct.vendor ven on inv.vendor = ven.vendorid
         left join "ANALYTICS"."PARTS_INVENTORY"."PARTS_ATTRIBUTES" pa
            on pa.part_id = inv.part_id
                and pa.END_DATE::date = '2999-01-01'
                and pa.part_categorization_id is not null
         left join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE pcs
            on pcs.part_categorization_id = pa.part_categorization_id
-- below gets rid of charges that have been credited off and core charges that have been offset
where (leftover_line_item_amount > 0 or leftover_line_item_amount is null)
 ;;
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${purchase_order_id}, ${part_id}) ;;
  }
  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    html: <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id }}/detail" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: vendor_invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    html: <font color="blue "><u><a href="{{ invoice_url }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }
  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."T3_PART_DESCRIPTION" ;;
  }
  dimension: invoice_line_item {
    type: string
    sql: ${TABLE}."INVOICE_LINE_ITEM" ;;
  }
  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
    value_format: "$0.00"
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
    value_format: "$0.00"
  }
  dimension: net_price_msrp {
    type: number
    sql: case
          when ${net_price} is null then ${msrp}
          when ${net_price} = 0 then ${msrp}
          else ${net_price}
          end;;
    value_format: "$0.00"
  }
  dimension: purchase_order_ppu {
    type: number
    sql: ${TABLE}."PO_PPU" ;;
    value_format: "$0.00"
  }
  dimension: invoice_ppu {
    type: number
    sql: ${TABLE}."INVOICE_PPU" ;;
    value_format: "$0.00"
  }
  measure: avg_ppu {
    type: number
    value_format_name: usd
    sql: ${total_spend} / ${total_invoice_qty} ;;
    drill_fields: [
      part_subcategory
      , avg_ppu_part_drill
      , total_spend
      , total_invoice_qty_part_drill
    ]
  }
  measure: avg_ppu_part_drill {
    type: number
    value_format_name: usd
    sql: ${total_spend} / ${total_invoice_qty} ;;
    drill_fields: [
      part_number
      , part_description
      , avg_ppu_vendor_drill
      , total_spend_vendor_drill
      , total_invoice_qty_vendor_drill
    ]
  }
  measure: avg_ppu_vendor_drill {
    type: number
    value_format_name: usd
    sql: ${total_spend} / ${total_invoice_qty} ;;
    drill_fields: [
      vendor
      , vendor_name
      , avg_ppu
      , total_spend
      , total_invoice_qty
    ]
  }
  dimension: net_price_vs_po_ppu {
    type: number
    sql: ${purchase_order_ppu} - ${net_price_msrp} ;;
    value_format: "$0.00"
  }
  dimension: net_price_vs_invoice_ppu {
    type: number
    sql: ${invoice_ppu} - ${net_price_msrp} ;;
    value_format: "$0.00"
  }
  dimension: invoice_url {
    type: string
    sql: ${TABLE}."INVOICE_URL" ;;
    html: <font color="blue "><u><a href="{{ invoice_url }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: invoice_qty {
    type: number
    sql: ${TABLE}."INVOICE_QTY" ;;
  }
  measure: total_invoice_qty {
    type: sum
    sql: ${invoice_qty} ;;
    value_format_name: decimal_0
    drill_fields: [
      part_subcategory
      , total_invoice_qty_part_drill
      , total_spend
      , avg_ppu_part_drill
    ]
  }
  measure: total_invoice_qty_part_drill {
    type: sum
    sql: ${invoice_qty} ;;
    value_format_name: decimal_0
    drill_fields: [
      part_number
      , part_description
      , total_invoice_qty_vendor_drill
      , total_spend_vendor_drill
      , avg_ppu_vendor_drill
    ]
  }
  measure: total_invoice_qty_vendor_drill {
    type: sum
    sql: ${invoice_qty} ;;
    value_format_name: decimal_0
    drill_fields: [
      vendor
      , vendor_name
      , total_invoice_qty
      , total_spend
      , avg_ppu
    ]
  }
  dimension: invoice_line_item_total {
    type: number
    value_format_name: usd
    sql: ${TABLE}.invoice_line_item_total ;;
  }
  measure: total_spend {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_line_item_total};;
    drill_fields: [
      part_number
      , part_description
      , total_spend_vendor_drill
      , total_invoice_qty_vendor_drill
      , avg_ppu_vendor_drill
    ]
  }

  measure: total_spend_ppu_html {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_line_item_total};;
    html: <p style="font-size:12px"> {{total_spend_ppu_html._rendered_value}} on {{total_invoice_qty._rendered_value}} units at {{avg_ppu._rendered_value}} per unit </p>;;
    drill_fields: [
      part_subcategory
      , total_spend
      , total_invoice_qty_part_drill
      , avg_ppu_part_drill
    ]
    }
  measure: total_spend_vendor_drill {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_line_item_total};;
    drill_fields: [
      vendor
      , vendor_name
      , total_spend
      , total_invoice_qty
      , avg_ppu
    ]
  }

  measure: total_spend_subcat_drill_no_html {
    type: sum
    value_format_name: usd_0
    sql: ${invoice_line_item_total};;
    drill_fields: [
      part_subcategory
      , total_spend
      , total_invoice_qty_part_drill
      , avg_ppu_part_drill
    ]
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME";;
  }
  dimension: line_item_varience {
    type: number
    sql: ${invoice_qty} * ${net_price_vs_invoice_ppu} ;;
    value_format: "$0.00"
  }
  dimension_group: invoice_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  measure: sum_varience {
    type: sum
    value_format_name: usd_0
    sql: ${line_item_varience} ;;
  }

  dimension: true_net_price_vs_invoice_ppu {
    type: number
    sql: ${invoice_ppu} - ${net_price} ;;
    value_format: "$0.00"
  }

  dimension: line_item_net_price_variance {
    type: number
    sql: ${invoice_qty} * ${true_net_price_vs_invoice_ppu} ;;
    value_format: "$0.00"
  }

  measure: sum_net_price_variance {
    type: sum
    value_format_name: usd_0
    sql: ${line_item_net_price_variance} ;;
  }

  dimension: part_category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: part_subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }

  dimension: full_vendor_name {
    type: string
    sql: concat(${vendor}, ' ', ${vendor_name}) ;;
  }

  dimension: vendor_or_category_dynamic_axis {
    type: string
    sql:{% if part_category._in_query %}
      ${full_vendor_name}
        {% else %}
      ${part_category}
      {% endif %};;
  }

  dimension: category_or_subcategory_dynamic_axis {
    type: string
    sql:{% if part_category._in_query %}
      ${part_subcategory}
        {% else %}
      ${part_category}
      {% endif %};;
  }
}

view: vendor_category_spend_12mo {
  derived_table: {
    sql:
with subcat_total as (
select va.vendor as vendorid
    , va.vendor_name
    , tvm.mapped_vendor_name
    , tvm.vendor_type
    , tvm.sage_vendor_category
    , tvm.tier
    , va.category
    , va.subcategory
    , sum(va.invoice_line_item_total) as spend
    , sum(va.invoice_qty) as quantity
from ${vendor_accountability.SQL_TABLE_NAME} va
left join (
    select v.vendorid
      , coalesce(tvm.vendor_name, v.name) as vendor_name
      , tvm.mapped_vendor_name
      , iff(tvm.mapped_vendor_name is not null, true, false) MAPPED
      , tvm.primary_vendor
      , tvm.tier
      , tvm.PREFERRED
      , tvm.vendor_type
      , v.vendor_category as sage_vendor_category
    from "ANALYTICS"."INTACCT"."VENDOR" v
    left join "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" tvm
      on tvm.vendorid = v.vendorid
    ) tvm
    on tvm.vendorid = va.vendor
where ((( invoice_date  ) >= ((DATEADD('month', -11, DATE_TRUNC('month', CURRENT_DATE())))) AND ( invoice_date  ) < ((DATEADD('month', 12, DATEADD('month', -11, DATE_TRUNC('month', CURRENT_DATE()))))))) --Matching looker "in last 12 months" formatting
group by 1,2,3,4,5,6,7,8
)

, cat_rank as (
    select vendorid
        , category
        , sum(spend) as tspend
        , row_number() over (partition by category order by tspend desc) category_spend_rank
    from subcat_total
    group by 1,2
)

select sct.*
    , cr.category_spend_rank
from subcat_total sct
left join cat_rank cr
    on cr.vendorid = sct.vendorid
        and coalesce(cr.category, '1') = coalesce(sct.category, '1');;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendor_type ;;
  }
  dimension: sage_vendor_category {
    type: string
    sql: ${TABLE}.sage_vendor_category ;;
  }
  dimension: tier {
    type: string
    sql: ${TABLE}.tier ;;
  }
  dimension: full_vendor_name {
    type: string
    sql: concat(${vendorid}, ' ', ${vendor_name}) ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }
  dimension: spend {
    type: number
    value_format_name: usd
    sql: ${TABLE}.spend ;;
  }
  measure: total_spend {
    type: sum
    value_format_name: usd_0
    sql: ${spend} ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }
  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
  }
  measure: price_per_unit {
    type: number
    value_format_name: usd
    sql: ${total_spend} / ${total_quantity} ;;
  }
  dimension: category_spend_rank {
    type: number
    sql: ${TABLE}.category_spend_rank ;;
  }

  dimension: category_or_subcategory_dynamic_axis {
    type: string
    sql:{% if category._in_query %}
      ${subcategory}
        {% else %}
      ${category}
      {% endif %};;
  }

  dimension: vendors_to_show {
    type: number
    sql: {% if vendorid._in_query %}
      100000
      {% elsif vendor_name._in_query %}
      100000
      {% elsif mapped_vendor_name._in_query %}
      100000
      {% elsif vendor_type._in_query %}
      100000
      {% elsif sage_vendor_category._in_query %}
      100000
      {% else %}
      10
      {% endif %};;
  }
}
