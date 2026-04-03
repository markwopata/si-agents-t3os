view: part_demand {
   derived_table: {
     sql: /*Works as an aggregate transaction log for parts. NOTE: The total on hand and value on hand must be summed distinctly because each line containing that specific store and partcombination will have the same current inventory. Sum distinct based on store part id for currently on hand. */
with inventory_on_hand as ( --These fields will appear as duplicates on every transaction for each store-part combination.
    select il.branch_id
         , dm.MARKET_ID
         , dm.MARKET_NAME
         , sp.STORE_ID as inventory_location_id
         , sp.PART_ID
         , sp.store_part_id
         , p.MASTER_PART_ID
         , sp.QUANTITY
         , sp.max
    from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
             left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                       on il.inventory_location_id = sp.store_id
             left join ANALYTICS.PARTS_INVENTORY.PARTS p
                       on p.part_id = sp.part_id
             left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
                       on il.branch_id = dm.MARKET_ID
    where sp.store_id not in (432, 6004, 9814) --Ecomm and backorder stores
)
   -- NEW, replaced source with intaact_models, modeled after the suggested_min_max_view
   , total_sold as (
    select pit.transaction_id
         , pit.transaction_item_id
         , market_id
         , market_name
         , pit.part_id
         , p.master_part_id as the_part_id
         , pit.TRANSACTION_TYPE_ID
         , pit.transaction_type
         , pit.FROM_ID as inventory_location_id
         , (pit.quantity * -1) as quantity_sold
         , pit.date_completed
         , pit.store_part_id
         , avg(li.price_per_unit) as invoice_price
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    left join es_warehouse.public.line_items li
        on pit.to_id = li.invoice_id
            and li.extended_data:part_id = pit.part_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
         on p.part_id = pit.part_id
    where pit.TRANSACTION_TYPE_ID in (3, -- Store to Retail Sale
                                      13) -- Store to Rental Retail Sale
      and pit.DATE_CANCELLED is null
      and pit.store_id not in (432, 6004, 9814)
      and pit.date_completed is not null
    group by 1,2,3,4,5,6,7,8,9,10,11,12
)
-- New, replaced source with intaact_models, modeled after the suggested_min_max_view
   , total_to_wo as (
    select
        pit.transaction_id
         , pit.transaction_item_id
         , pit.market_id
         , pit.market_name
         , pit.PART_ID
         , p.MASTER_PART_ID as the_part_id
         , pit.TRANSACTION_TYPE_ID
         , pit.transaction_type
    -- , iff(pit.TRANSACTION_TYPE_ID = 7, from_id, to_id) as inventory_location_id
    -- , iff(pit.TRANSACTION_TYPE_ID = 7, pit.quantity, 0 - pit.quantity) as wo_quantity
    -- , iff(pit.TRANSACTION_TYPE_ID = 7, pit.to_id, pit.from_id) as wo_id
         , pit.store_id as inventory_location_id
         , pit.quantity * -1 as wo_quantity
         , pit.work_order_id as wo_id
         , asset_id
         , pit.date_completed
         , pit.store_part_id
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
             left join ANALYTICS.PARTS_INVENTORY.PARTS p
                       on p.part_id = pit.part_id
             left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                       on wo.work_order_id = pit.work_order_id
                           and wo.description not ilike '%Cycle Count%'
            left join (
        select distinct wo.work_order_id
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
                join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
                      on ct.company_tag_id = woct.company_tag_id
                join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                      on wo.work_order_id = woct.work_order_id
        where ct.name ilike any ('%Inventory%','%Cycle Count%','%Adjustment%') and wo.asset_id is null
        and woct.deleted_on is null
    ) ct
                      on ct.work_order_id = wo.work_order_id
    where pit.TRANSACTION_TYPE_ID in (7,9) -- Store to Work Order
      and DATE_CANCELLED is null
      and iff(pit.TRANSACTION_TYPE_ID = 7, pit.from_id, pit.to_id) not in (432, 6004, 9814)
      and pit.date_completed is not null
    -- and wo.asset_id is not null
)
-- New, replaced source with intaact_models, modeled after the suggested_min_max_view
   , po_to_store as (
    select pit.transaction_id
         , pit.transaction_item_id
         , pit.MARKET_ID
         , pit.MARKET_NAME
         , pit.PART_ID
         , p.master_part_id as the_part_id
         , pit.TRANSACTION_TYPE_ID
         , pit.transaction_type
         , pit.to_id as inventory_location_id
         , pit.quantity as quantity_bought
         , pit.date_completed
         , pit.store_id
         , pit.store_part_id
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
             left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
                       on po.purchase_order_id = pit.purchase_order_id
             left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
                       on evs.entity_id = po.vendor_id
             left join ANALYTICS.PARTS_INVENTORY.PARTS p
                  on p.part_id = pit.part_id
             left join ANALYTICS.INTACCT.VENDOR v
                       on v.vendorid = evs.external_erp_vendor_ref
    where pit.TRANSACTION_TYPE_ID in (21, 23) -- Purchase to store
      and pit.DATE_CANCELLED is null
      and pit.store_id not in (432, 6004, 9814)
      and pit.date_completed is not null
)
   -- suggested_min_max calls the next CTE market_demand, and has a different level of detail
   , final_prep as (
    select transaction_id
         , transaction_item_id
         , MARKET_ID
         , MARKET_NAME
         , inventory_location_id
         , TRANSACTION_TYPE_ID
         , transaction_type
         , part_id
         , the_part_id
         , 'CONSUMPTION' as demand
         , quantity_sold as quantity
         , date_completed
         , null as asset_id
         , store_part_id
         , invoice_price
    from total_sold

    union

    select transaction_id
         , transaction_item_id
         , MARKET_ID
         , MARKET_NAME
         , inventory_location_id
         , TRANSACTION_TYPE_ID
         , transaction_type
         , part_id
         , the_part_id
         , 'CONSUMPTION' as demand
         , wo_quantity as quantity
         , date_completed
         , asset_id
         , store_part_id
         , null as invoice_price
    from total_to_wo

    union

    select transaction_id
         , transaction_item_id
         , MARKET_ID
         , MARKET_NAME
         , inventory_location_id
         , TRANSACTION_TYPE_ID
         , transaction_type
         , part_id
         , the_part_id
         , 'PURCHASE' as demand
         , quantity_bought as quantity
         , date_completed
         , null as asset_id
         , store_part_id
         , null as invoice_price
    from po_to_store
)
-- , final as (
--Each line is an individual transaction, Value on hand is always current (as of run)
select fp.transaction_id, fp.transaction_item_id
     , i.inventory_location_id
     , fp.MARKET_ID
     , fp.MARKET_NAME
     , i.MASTER_PART_ID as the_part_id
     , i.store_part_id
     , i.max as listed_max_for_store
     , wac.weighted_average_cost as wac
     , i.QUANTITY as quantity_on_hand
     , i.quantity * wac as value_on_hand
     , fp.quantity
     , fp.quantity * wac as value
     , il.name as store_name
     , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
     , coalesce(xw.DISTRICT, d.name)                       as the_district_name
     , coalesce(xw.REGION_NAME, r.name)                    as the_region_name
     , fp.TRANSACTION_TYPE_ID
     , fp.transaction_type
     , fp.date_completed
     , asset_id
     , invoice_price as sales_price_per_unit
     , iff(fc.part_id is null, true, fc_stockable) fc_stockable -- , iff(fc.part_id is null,true,false) fc_stockable
from inventory_on_hand i
         left join final_prep fp
                   on i.store_part_id = fp.store_part_id
         left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                   on il.inventory_location_id = i.inventory_location_id
         left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wac
                   on wac.inventory_location_id = i.inventory_location_id
                       and wac.product_id = i.part_id
         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                   on i.BRANCH_ID = xw.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.MARKETS ma
                   on i.BRANCH_ID = ma.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
                   on ma.DISTRICT_ID = d.DISTRICT_ID
         left join ES_WAREHOUSE.PUBLIC.REGIONS r
                   on d.REGION_ID = r.REGION_ID
         left join ANALYTICS.PARTS_INVENTORY.FULFILLMENT_PARTS_ATTRIBUTES fc
                   on i.part_id=fc.part_id and fc.end_date = '2999-01-01'
where wac.is_current = true
  and the_region_name is not null
  and i.MASTER_PART_ID is not null
  and il.inventory_location_id in (select il.inventory_location_id -- this is the accounting JE suppression piece
                                   from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                                            join ES_WAREHOUSE.PUBLIC.MARKETS m
                                                 on il.BRANCH_ID = m.MARKET_ID
                                   where il.company_id = 1854
                                     and il.date_archived is null -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                                     and m.ACTIVE = TRUE) ;;
   }

  # dimension: transaction_id {
  #   type: number
  #   primary_key: yes
  #   value_format_name: id
  #   sql: ${TABLE}."transaction_id" ;;
  #}

  dimension: inventory_location_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."THE_PART_ID" ;;
  }

  dimension: store_part_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_PART_ID" ;;
  }
 dimension: fc_stockable {
   type: yesno
  sql: ${TABLE}."FC_STOCKABLE" ;;
 }

  dimension: fc_stockable_adjusted {
    type: yesno
    sql:
    CASE
      WHEN
        (
          (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Buckets' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Hammers & Breakers' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} = 'Other Batteries')
          OR (${part_categorization_structure.category} = 'Maintenance' AND ${part_categorization_structure.subcategory} = 'Battery Maintenance' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Safety & Compliance' AND ${part_categorization_structure.subcategory} = 'Fire Suppression Systems' AND ${part_categorization_structure.part_containers} IN ('Fire Extinguishers', 'Automatic Fire Suppression'))
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} = '')
          OR (${part_categorization_structure.category} = 'Maintenance' AND ${part_categorization_structure.subcategory} = 'Fluids & Lubricants' AND ${part_categorization_structure.part_containers} IN ('Hydraulic Lubricants', 'Transmission Lubricants', 'DEF', 'Fuel', 'Coolants', 'Differential Lubricants'))
          OR (${part_categorization_structure.category} = 'Pneumatics & Air Systems' AND ${part_categorization_structure.subcategory} = 'Air Tanks' AND ${part_categorization_structure.part_containers} IN ('Standard Air Tanks', 'High-Pressure Air Tanks'))
          OR (${part_categorization_structure.category} = 'Undercarriage' AND ${part_categorization_structure.subcategory} = 'Tracks' AND ${part_categorization_structure.part_containers} = 'Rubber Tracks')
          OR (${part_categorization_structure.category} = 'Undercarriage' AND ${part_categorization_structure.subcategory} = 'Wear Parts' AND ${part_categorization_structure.part_containers} = 'Cleats')
          OR (${part_categorization_structure.category} = 'Frames & Chassis' AND ${part_categorization_structure.subcategory} = 'Frames' AND ${part_categorization_structure.part_containers} = 'Fork Carriages')
          OR (${part_categorization_structure.category} = 'Frames & Chassis' AND ${part_categorization_structure.subcategory} = 'Counterweights' AND ${part_categorization_structure.part_containers} = 'Rear Counterweights')
          OR (${part_categorization_structure.category} = 'Materials' AND ${part_categorization_structure.subcategory} = 'Concrete Accessories' AND ${part_categorization_structure.part_containers} = 'Rebar Chairs')
          OR (${part_categorization_structure.category} = 'Materials' AND ${part_categorization_structure.subcategory} = 'Concrete Reinforcement' AND ${part_categorization_structure.part_containers} = 'Dowels')
          OR (${part_categorization_structure.category} = 'Attachments & Implements' AND ${part_categorization_structure.subcategory} = 'Buckets' AND ${part_categorization_structure.part_containers} IN ('Excavator Buckets', 'Loader Buckets'))
          OR (${part_categorization_structure.category} = 'Cabin & Operator Controls' AND ${part_categorization_structure.subcategory} = 'Cabin Safety Systems' AND ${part_categorization_structure.part_containers} = 'Rollover Protection (ROPS)')
          OR (${part_categorization_structure.category} = 'Electrical & Lighting' AND ${part_categorization_structure.subcategory} = 'Batteries' AND ${part_categorization_structure.part_containers} IN ('Starter Batteries', 'Deep Cycle Batteries'))
          OR (${part_categorization_structure.category} = 'Security Systems' AND ${part_categorization_structure.subcategory} = 'Access Control' AND ${part_categorization_structure.part_containers} = 'Trackers')
          OR (${part_categorization_structure.subcategory} IN ('Concrete Formwork','Beverages'))
        )
      THEN FALSE
      ELSE ${fc_stockable}
    END ;;
  }


  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
    value_format: "0"
  }

  dimension: max_quantity_per_store {
    type: number
    sql: ${TABLE}."LISTED_MAX_FOR_STORE" ;;
  }

  dimension: transaction_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: wac {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WAC" ;;
  }

  dimension: quantity_on_hand {
    type: number
    sql: ${TABLE}."QUANTITY_ON_HAND" ;;
  }

  dimension: value_on_hand {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."VALUE_ON_HAND" ;;
  }

  dimension: quantity{
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."VALUE" ;;
  }

  measure: quantity_sold {
    type: sum
    sql: ${quantity} ;;
    filters: [transaction_type_id: "3,13"]
    drill_fields: [detail*]
  }

  measure: cogs {
    type: sum
    value_format_name: usd_0
    sql: ${value} ;;
    filters: [transaction_type_id: "3,13"]
    drill_fields: [detail*]
  }

  measure: quantity_to_wo {
    type: sum
    sql: ${quantity} ;;
    filters: [transaction_type_id: "7,9"]
    drill_fields: [detail*]
  }

  measure: value_to_wo {
    type: sum
    value_format_name: usd_0
    sql: ${value} ;;
    filters: [transaction_type_id: "7,9"]
    drill_fields: [detail*]
  }

  measure: total_bought {
    type: sum
    sql: ${quantity} ;;
    filters: [transaction_type_id: "21,23"]
    drill_fields: [detail*]
  }

  measure: total_spend {
    type: sum
    value_format_name: usd_0
    sql: ${value} ;;
    filters: [transaction_type_id: "21,23"]
    drill_fields: [drill*]
  }

  measure: total_spend_region_detail {
    label: "Total Spend"
    type: sum
    value_format_name: usd_0
    sql: ${value} ;;
    filters: [transaction_type_id: "21,23"]
    drill_fields: [
                  market_region_xwalk.market_id,
                  market_region_xwalk.market_name,
                  total_spend
                  ]
  }

  measure: total_on_hand {
    type: sum_distinct
    sql_distinct_key: ${store_part_id} ;;
    sql: coalesce(${quantity_on_hand},0) ;;
  }

  measure: total_value_on_hand {
    type: sum_distinct
    value_format_name: usd_0
    sql_distinct_key: ${store_part_id} ;;
    sql: coalesce(${value_on_hand},0) ;;
  }

  measure: consumption {
    type: sum
    value_format_name: usd_0
    sql:${value} ;;
    filters: [transaction_type_id: "3,13,7,9"]
    drill_fields: [drill*]
  }

measure: consumption_region_detail {
  label: "Consumption"
  type: sum
  value_format_name: usd_0
  sql:${value} ;;
  filters: [transaction_type_id: "3,13,7,9"]
  drill_fields: [
                market_region_xwalk.market_id,
                market_region_xwalk.market_name,
                consumption
                ]
}
  measure: total_consumed {
    type: sum
    sql: ${quantity}  ;;
    filters: [transaction_type_id: "3,13,7,9"]
  }

  measure: aggregate_max {
    type: sum
    sql: ${max_quantity_per_store} ;;

  }

  set: drill {
    fields: [
      selected_hierarchy_dimension
      , parts.part_number
      , providers.name
      , aggregate_max
      , total_on_hand
      , total_value_on_hand
      , total_bought
      , total_spend
      , quantity_sold
      , cogs
      , quantity_to_wo
      , value_to_wo
    ]
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."THE_MARKET_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."THE_DISTRICT_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."THE_REGION_NAME" ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: sales_price_per_unit {
    type: number
    sql: ${TABLE}."SALES_PRICE_PER_UNIT" ;;
    value_format: "$0.00"
  }

  measure: average_sales_price {
    type: average
    sql: ${sales_price_per_unit} ;;
    value_format: "$0.00"
  }
  measure: average_margin {
    type: average
    sql: (${sales_price_per_unit} / nullif(${parts.msrp},0))-1 ;;
    value_format: "0.00%"
  }
  measure: average_margin_wac {
    type: average
    sql: (${sales_price_per_unit} / nullif(${wac},0))-1 ;;
    value_format: "0.00%"
  }
  measure: min_sales_price {
    type: min
    sql: ${sales_price_per_unit} ;;
    value_format: "$0.00"
  }
  measure: max_sales_price {
    type: max
    sql: ${sales_price_per_unit} ;;
    value_format: "$0.00"
  }
  measure: min_margin {
    type: min
    sql: (${sales_price_per_unit} / nullif(${parts.msrp},0))-1 ;;
    value_format: "0.00%"
  }
  measure: max_margin {
    type: max
    sql: (${sales_price_per_unit} / nullif(${parts.msrp},0))-1 ;;
    value_format: "0.00%"
  }

  dimension: selected_hierarchy_dimension {
    label: "Filtered Location"
    type: string
    sql: {% if market_name._in_query %}
          ${store_name}
        {% elsif district_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  measure: trailing_12_mth_consumption {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND ${date_completed_date} >= DATEADD('month', -12, CURRENT_DATE)
             AND ${date_completed_date} < DATE_TRUNC('month', CURRENT_DATE)
            THEN ${quantity}
            ELSE 0
         END ;;
    value_format_name: decimal_0
    label: "Trailing 12-Month Consumption"
  }

  measure: trailing_month_12 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 1
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 12"
  }

  measure: trailing_month_11 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 2
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 11"
  }

  measure: trailing_month_10 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 3
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 10"
  }

  measure: trailing_month_9 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 4
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 9"
  }

  measure: trailing_month_8 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 5
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 8"
  }

  measure: trailing_month_7 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 6
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 7"
  }

  measure: trailing_month_6 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 7
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 6"
  }

  measure: trailing_month_5 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 8
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 5"
  }

  measure: trailing_month_4 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 9
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 4"
  }

  measure: trailing_month_3 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 10
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 3"
  }

  measure: trailing_month_2 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 11
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 2"
  }

  measure: trailing_month_1 {
    type: sum
    sql: CASE
            WHEN ${transaction_type_id} IN (3,7,9,13)
             AND DATEDIFF('month', ${date_completed_date}, DATE_TRUNC('month', CURRENT_DATE)) = 12
            THEN ${quantity}
            ELSE 0
         END ;;
    label: "Trailing Month 1"
  }

  set: detail {
    fields: [market_name
      , transaction_type
      , date_completed_date
      , asset_id
      , assets_aggregate.make
      , assets_aggregate.model
      , parts.part_number
      , providers.name
      , quantity
      , value
    ]
  }
}
