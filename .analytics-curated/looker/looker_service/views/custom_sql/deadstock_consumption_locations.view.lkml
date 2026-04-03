view: deadstock_consumption_locations {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
      with inventory_on_hand as ( --These fields will appear as duplicates on every transaction for each store-part combination.
        select il.branch_id
             , sp.STORE_ID                                                               as inventory_location_id
             , sp.PART_ID
             , sp.store_part_id
             ,  p.master_part_id
             , sp.QUANTITY
             , sp.AVAILABLE_QUANTITY
             , sp.max
        from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
        join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
            on il.inventory_location_id = sp.store_id
        join ANALYTICS.PARTS_INVENTORY.PARTS p
            on p.part_id = sp.part_id
        where sp.store_id not in (432, 6004, 9814) --Ecomm and backorder stores
      )
      , inventory_agg as (
          select branch_id
               , master_part_id
               , sum(zeroifnull(available_quantity))                                      as total_inventory
          from inventory_on_hand
          group by 1,2
      )
      --Needs to be by transaction line now
      , total_sold as (
          select t.transaction_id
              , ti.transaction_item_id
              , ti.PART_ID
              ,  p.master_part_id as the_part_id
              , tt.TRANSACTION_TYPE_ID
              , tt.name as transaction_type
              ,  t.FROM_ID as inventory_location_id
              , ti.quantity_received as quantity_sold
              ,  t.date_completed
              , sp.store_part_id
              , li.price_per_unit as invoice_price
          from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
          join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
              on ti.TRANSACTION_ID = t.TRANSACTION_ID
          join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
              on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
          join ANALYTICS.PARTS_INVENTORY.PARTS p
              on p.part_id = ti.part_id
          left join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
              on sp.store_id = t.from_id
                  and ti.part_id = sp.part_id
          left join es_warehouse.public.line_items li
              on t.to_id = li.invoice_id
              and li.extended_data:part_id = ti.part_id
          where tt.TRANSACTION_TYPE_ID in (3, -- Store to Retail Sale
                                           13) -- Store to Rental Retail Sale
              and DATE_CANCELLED is null
              and t.from_id not in (432, 6004, 9814)
              and t.date_completed is not null
      )
      , total_to_wo as (
          select t.transaction_id
              , ti.transaction_item_id
              , ti.PART_ID
              ,  p.master_part_id as the_part_id
              , tt.TRANSACTION_TYPE_ID
              , tt.name as transaction_type
              , iff(tt.TRANSACTION_TYPE_ID = 7, from_id, to_id) as inventory_location_id
              , iff(tt.TRANSACTION_TYPE_ID = 7, ti.quantity_received, 0 - ti.quantity_received) as wo_quantity
              , iff(tt.TRANSACTION_TYPE_ID = 7, t.to_id, t.from_id) as wo_id
              , wo.asset_id
              ,  t.date_completed
              , sp.store_part_id
          from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
          join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
              on ti.TRANSACTION_ID = t.TRANSACTION_ID
          join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
              on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
          join ANALYTICS.PARTS_INVENTORY.PARTS p
              on p.part_id = ti.part_id
          left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
              on wo.work_order_id = iff(tt.TRANSACTION_TYPE_ID = 7, t.to_id, t.from_id)
          left join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
              on sp.store_id = iff(tt.TRANSACTION_TYPE_ID = 7, from_id, to_id)
                  and ti.part_id = sp.part_id
          where tt.TRANSACTION_TYPE_ID in (7,9) -- Store to Work Order
              and DATE_CANCELLED is null
              and iff(tt.TRANSACTION_TYPE_ID = 7, from_id, to_id) not in (432, 6004, 9814)
              and t.date_completed is not null
              and wo.asset_id is not null
      )
      , final_prep as (
          select transaction_id
              , transaction_item_id
              , inventory_location_id
              , TRANSACTION_TYPE_ID
              , transaction_type
              , part_id
              , the_part_id
              , quantity_sold as quantity
              , date_completed
              , null as asset_id
              , store_part_id
              , invoice_price
          from total_sold

          union

          select transaction_id
              , transaction_item_id
              , inventory_location_id
              , TRANSACTION_TYPE_ID
              , transaction_type
              , part_id
              , the_part_id
              , wo_quantity as quantity
              , date_completed
              , asset_id
              , store_part_id
              , null as invoice_price
          from total_to_wo
      )
      , final_transaction_list as (
      --Each line is an individual transaction, Value on hand is always current (as of run)
          select fp.transaction_id
               , fp.transaction_item_id
               , i.inventory_location_id
               , i.master_part_id as the_part_id
               , i.store_part_id
               , i.max                                                        as listed_max_for_store
               , wac.weighted_average_cost                                    as wac
               , i.QUANTITY                                                   as quantity_on_hand
               , i.AVAILABLE_QUANTITY
               , i.quantity * wac                                             as value_on_hand
               , fp.quantity
               , iff(fp.date_completed >= dateadd(month, -6, date_trunc(month, current_date)), fp.quantity, 0)    as last_6mo_flag
               , iff(fp.date_completed >= dateadd(month, -12, date_trunc(month, current_date)), fp.quantity, 0)   as last_12mo_flag
               , fp.quantity * wac                                            as value
               , il.name                                                      as store_name
               , coalesce(xw.MARKET_ID,ma.MARKET_ID)                          as the_market_id
               , coalesce(xw.MARKET_NAME, ma.NAME)                            as the_market_name
               , coalesce(xw.DISTRICT, d.name)                                as the_district_name
               , coalesce(xw.REGION_NAME, r.name)                             as the_region_name
               , fp.TRANSACTION_TYPE_ID
               , fp.transaction_type
               , fp.date_completed
               , asset_id
               , invoice_price                                                as sales_price_per_unit
          from final_prep                                                     as fp
          left join inventory_on_hand                                         as i
              on i.store_part_id = fp.store_part_id
          left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                as il
              on il.inventory_location_id = i.inventory_location_id
          join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS         as wac
              on wac.inventory_location_id = i.inventory_location_id
                  and wac.product_id = i.master_part_id
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK                      as xw
              on i.BRANCH_ID = xw.MARKET_ID
          left join ES_WAREHOUSE.PUBLIC.MARKETS                               as ma
              on i.BRANCH_ID = ma.MARKET_ID
          left join ES_WAREHOUSE.PUBLIC.DISTRICTS                             as d
              on ma.DISTRICT_ID = d.DISTRICT_ID
          left join ES_WAREHOUSE.PUBLIC.REGIONS                               as r
              on d.REGION_ID = r.REGION_ID
          where wac.is_current = true
            and the_region_name is not null
            and il.inventory_location_id in (select il.inventory_location_id -- this is the accounting JE suppression piece
                                             from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                                             join ES_WAREHOUSE.PUBLIC.MARKETS m
                                                  on il.BRANCH_ID = m.MARKET_ID
                                             where il.company_id = 1854
                                               and il.date_archived is null -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                                               and m.ACTIVE = TRUE) -- inactive store & market suppression
      )
      --select sum(last_6mo_flag) from final_transaction_list where inventory_location_id=357 and the_market_id=9 and the_part_id=4028468;
      , consumption_agg as (
          select the_market_id consuming_market_id
               , the_market_name consuming_market_name
               , the_part_id
               , sum(last_6mo_flag) last_6mo_qty
               , max(date_completed) last_consumed
      --          , sum(last_12mo_flag) last_12mo_qty
          from final_transaction_list
          group by 1,2,3
          having last_6mo_qty > 0
      )
      , current_dead as (
          select market_id
               , market_name
               , part_id
               , part_number
               , description
               , provider
               , sum(total_in_inventory) dead_qty
               , sum(dead_stock) dead_value
          from ANALYTICS.PARTS_INVENTORY.DEADSTOCK_SNAPSHOT
          where SNAP_DATE = dateadd(day,-1,current_date())
          group by 1,2,3,4,5,6
      )
      , on_order as ( --All open purchase orders by requesting market. We don't know who is going to receive them based off the data.
          select coalesce(xw.MARKET_ID, ma.market_id)                  as the_market_id
               , p.master_part_id                                      as the_part_id
               , sum(li.quantity - li.total_accepted - total_rejected) as total_on_order
          from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
          join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
              on po.PURCHASE_ORDER_ID = li.PURCHASE_ORDER_ID
          left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
              on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
          left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
              on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
          join ANALYTICS.PARTS_INVENTORY.PARTS p
              on li.item_id = p.item_id
          join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
              on p.part_type_id = pt.PART_TYPE_ID
          left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
              on p.provider_id = pr.provider_id
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
              on po.REQUESTING_BRANCH_ID = xw.MARKET_ID
          left join ES_WAREHOUSE.PUBLIC.MARKETS ma
              on po.REQUESTING_BRANCH_ID = ma.MARKET_ID
          where po.status = 'OPEN'
      --AND DATE_RECEIVED IS NULL
            and li.date_archived is null
            and po.date_archived is null
            and ma.company_id = 1854
            and ma.ACTIVE = TRUE
          group by the_market_id, the_part_id
          having total_on_order > 0
      )
      select region_name
           , district
           , d.market_id
           , d.market_name
           , d.part_id
           , d.part_number
           , d.description
           , d.provider
           , d.dead_qty
           , d.dead_value
           , consuming_market_id
           , consuming_market_name
           , last_6mo_qty
           , last_consumed
           , i.total_inventory
           , o.total_on_order
           , listagg(consuming_market_name, ',') over (partition by d.part_id,d.market_id)    as consuming_markets
      from current_dead                                                                       as d
      left join consumption_agg                                                               as c
          on d.part_id = c.the_part_id
      left join inventory_agg                                                                 as i
          on c.the_part_id = i.master_part_id
         and c.consuming_market_id = i.branch_id
      left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK                                          as m
          on d.market_id = m.market_id
      left join on_order                                                                      as o
          on c.the_part_id=o.the_part_id
         and c.consuming_market_id=o.the_market_id
      -- where region_name = 'Midwest'
      --   and part_number = '70013283Q' --this is an example part where it is dead somewhere in pasadena, and being consumed elsewhere in pasadena. added the next line to address these situations
      -- qualify not contains(consuming_markets, d.market_name)
      order by d.market_id, d.part_id, last_6mo_qty desc
      ;;
  }
  dimension: region_name {
    sql: ${TABLE}.region_name ;;
  }
  dimension: district {
    sql: ${TABLE}.district ;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }
  dimension: market_name {
    sql: ${TABLE}.market_name ;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }
  dimension: part_number {
    type: string
    value_format_name: id
    sql: ${TABLE}.part_number ;;
  }
  dimension: description {
    sql: ${TABLE}.description ;;
  }
  dimension: provider {
    sql: ${TABLE}.provider ;;
  }
  dimension: dead_quantity {
    sql: ${TABLE}.dead_qty ;;
  }
  dimension: dead_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.dead_value ;;
  }
  dimension: consuming_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.consuming_market_id ;;
  }
  dimension: consuming_market_name {
    sql: ${TABLE}.consuming_market_name ;;
  }
  dimension: last_6mo_quantity {
    sql: ${TABLE}.last_6mo_qty ;;
  }
  dimension: last_consumed {
    sql: ${TABLE}.last_consumed ;;
  }
  dimension: total_inventory {
    sql: ${TABLE}.total_inventory ;;
  }
  dimension: total_on_order {
    sql: ${TABLE}.total_on_order ;;
  }
  dimension: consuming_markets {
    sql: ${TABLE}.consuming_markets ;;
  }
  dimension: 6mo_demand_index {
    type: number
    sql: zeroifnull(${last_6mo_quantity}) - (zeroifnull(${total_inventory}) + zeroifnull(${total_on_order})) ;;

  }
}
