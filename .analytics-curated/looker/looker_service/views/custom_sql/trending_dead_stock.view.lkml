view: trending_dead_stock {
  derived_table: {
    sql: with get_past_days as (
        --12 months trailing end dates
        select last_day(dateadd(month,'-' || row_number() over (order by null),dateadd(day, '+1', current_date())), 'month') as generated_date
        from table (generator(rowcount => 12))
    ), inventory_on_hand as (--using this cte to get all possible parts, even where we dont have inv, so that subs are not missed
        select sp.STORE_ID                                                                  as inventory_location_id
             , sp.PART_ID
             , sp.store_part_id
             , sp.QUANTITY
        from ES_WAREHOUSE.INVENTORY.STORE_PARTS                                             as sp
        where sp.store_id not in (432,6004,400,9814)
    ), inv_snap as (
        select ibs.part_id
             , ibs.store_id
             , ibs.TIMESTAMP::date                                                          as snap_date
             , ibs.quantity
             , wac.weighted_average_cost                                                    as avg_cost
             , ibs.quantity * wac.weighted_average_cost                                     as inv_dollars
             , ibs.part_id||ibs.store_id||snap_date                                         as unique_key
        from ANALYTICS.PUBLIC.INVENTORY_BALANCES_SNAPSHOT                                   as ibs
        join get_past_days                                                                  as gd
            on ibs.TIMESTAMP::date = gd.generated_date
        join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS                         as wac --changed to wac 1/17/24
            on ibs.PART_ID = wac.product_id
                and ibs.STORE_ID = wac.inventory_location_id
                --and ibs.TIMESTAMP::date = acs.SNAPSHOT_DATE
        join "ES_WAREHOUSE"."INVENTORY"."INVENTORY_LOCATIONS"                               as il
            on ibs.store_id =il.inventory_location_id
        where ibs.timestamp like '% 17:0%'
            and ibs.store_id not in (432,6004,400,9814)
            and il.date_archived is null
            and wac.is_current = true
    ), ttl_inv_snap as (--using this to get the denominator for deadstock% of ttl inv. Tommie added store id to this to get store level dead stock per part. 1/17/24
        select snap_date,
               store_id,
               part_id,
               sum(inv_dollars)                                                             as total_snap_balance
        from inv_snap
        group by snap_date, store_id, part_id -- not sure if store needs to be added yet
    ), last_time_consumed as (
        select ti.PART_ID,
               t.FROM_ID                                                                    as inventory_location_id,
               il.BRANCH_ID,
               max(t.DATE_COMPLETED)::date                                                  as last_use_date,
               generated_date
        from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS                                       as ti
        join ES_WAREHOUSE.INVENTORY.TRANSACTIONS                                            as t
            on ti.TRANSACTION_ID = t.TRANSACTION_ID
        join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES                                       as tt
            on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
        left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                as il
            on t.FROM_ID = il.INVENTORY_LOCATION_ID
        join get_past_days                                                                  as gd
            on t.DATE_COMPLETED::date <= generated_date
        where tt.TRANSACTION_TYPE_ID in (3, -- Store to Retail Sale
                                       7, -- Store to Work Order
                                       13) -- Store to Rental Retail Sale
            and DATE_CANCELLED is null
            and t.from_id not in (432, 6004,400,9814)
        group by generated_date,
                 ti.PART_ID,
                 t.FROM_ID,
                 il.branch_id
        --order by part_id, inventory_location_id, generated_date
    ), last_time_rented as ( --all based on market, so one rental is getting passed as use to all the stores within the market
        SELECT distinct rpa.PART_ID
                      , il.INVENTORY_LOCATION_ID
                      , il.BRANCH_ID
                      , max(iff(generated_date between rpa.START_DATE and coalesce(rpa.END_DATE, '2099-12-31'),generated_date, rpa.END_DATE))::date as last_use_date
                      , generated_date
        FROM ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS                                    as rpa
        join ES_WAREHOUSE.PUBLIC.RENTALS                                                    as r
          on rpa.RENTAL_ID = r.RENTAL_ID
        join ES_WAREHOUSE.PUBLIC.ORDERS                                                     as o
          on r.ORDER_ID = o.ORDER_ID
        join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                     as il
          on o.MARKET_ID = il.BRANCH_ID
        join get_past_days                                                                  as gd
          on rpa.start_date <= generated_date
        where r.DELETED = false
        group by rpa.PART_ID,
                 il.INVENTORY_LOCATION_ID,
                 il.BRANCH_ID,
                 generated_date
        -- order by rpa.part_id, il.inventory_location_id, generated_date
    ), last_used_date as (
        select part_id
             , inventory_location_id
             , branch_id
             , max(last_use_date)                                                           as last_used_date
             , generated_date
             , part_id||inventory_location_id||generated_date                               as unique_key
        from (select *
              from last_time_consumed
                  union all
              select *
              from last_time_rented)                                                        as last_use
        group by part_id,
                 inventory_location_id,
                 branch_id, generated_date
        -- order by part_id, inventory_location_id, generated_date
    ), last_time_ordered as (
        select ti.PART_ID,
               t.to_ID                                                                      as inventory_location_id,
               il.BRANCH_ID,
               max(t.DATE_COMPLETED)::date                                                  as last_ordered_date,
               generated_date,
               part_id||to_id||generated_date                                               as unique_key
        from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS                                       as ti
        join ES_WAREHOUSE.INVENTORY.TRANSACTIONS                                            as t
          on ti.TRANSACTION_ID = t.TRANSACTION_ID
        join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES                                       as tt
          on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
        left join ES_WAREHOUSE.INVENTORY.MANUAL_ADJUSTMENTS                                 as ma
          on ti.transaction_item_id = ma.TRANSACTION_ITEM_ID
        join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                     as il
          on t.to_id = il.INVENTORY_LOCATION_ID
        join get_past_days                                                                  as gd
          on t.DATE_COMPLETED::date <= generated_date
        where t.transaction_type_id in (1, 4, 6, 9, 11, 14, 15, 17, 20, 21, 23) -- all ""to store""
          and t.DATE_CANCELLED is null
          and t.to_id not in (432, 6004,400,9814)
          and t.date_completed is not null
        group by ti.PART_ID,
                 t.to_ID,
                 il.branch_id,
                 generated_date
        -- order by ti.part_id, t.to_id, generated_date
    ), og_stock as (
        select s.part_id,
               s.store_id,
               s.snap_date,
               s.QUANTITY                                                                   as total_in_inventory,
               s.AVG_COST,
               s.inv_dollars,
               lud.last_used_date,
               lto.last_ordered_date,
               coalesce(lud.last_used_date, lto.last_ordered_date) last_date,
               sp.SUB_PART_NUMBER,
               p.part_id                                                                    as sub_part_id,
               p.part_id||s.store_id||s.snap_date                                           as sub_unique_key
        from inv_snap                                                                       as s --this is bringing in the detail inv snaps for each month
        left join last_used_date                                                            as lud
          on s.unique_key=lud.unique_key
        left join last_time_ordered                                                         as lto
          on s.unique_key=lto.unique_key
        left join ANALYTICS.PARTS_INVENTORY.SUB_PARTS                                       as sp
          on s.PART_ID = sp.ORIGINAL_PART_ID
        left join ES_WAREHOUSE.INVENTORY.PARTS                                              as p
          on sp.SUB_PART_NUMBER = p.PART_NUMBER
              and sp.SUB_PROVIDER_ID = p.PROVIDER_ID
        --  order by part_id, store_id, snap_date
    ), subs as(
        select s.part_id,
               s.store_id,
               s.snap_date,
               lud.last_used_date,
               lto.last_ordered_date,
               coalesce(lud.last_used_date, lto.last_ordered_date)                          as last_date,
               p.part_number,
               p.provider_id,
               s.unique_key
        from inv_snap s --this is bringing in the detail inv snaps for each month
        left join last_used_date                                                            as lud
          on s.unique_key=lud.unique_key
        left join last_time_ordered                                                         as lto
          on s.unique_key=lto.unique_key
        left join ES_WAREHOUSE.INVENTORY.PARTS                                              as p
          on s.part_id = p.part_id
        --  order by part_id, store_id
    ), sub_status as(
        select distinct og.part_id                                                          as og_part_id,
                        og.store_id,
                        og.snap_date,
                        sub.part_id                                                         as sub_part_id,
                        sub.part_number                                                     as sub_part_number,
                        max(greatest(og.last_date,sub.last_date)) over (partition by og_part_id,og.store_id, og.snap_date) as max_lud,
                        iff(datediff('days',max_lud, og.snap_date)>180,0,1)                 as sub_not_dead
        from og_stock                                                                       as og
        left join subs                                                                      as sub
          on og.sub_unique_key=sub.unique_key
        where og_part_id != sub.part_id
    --order by og.part_id, og.store_id, og.snap_date
    ), sub_flag as (
        select og_part_id,
               store_id,
               snap_date,
               listagg(sub_part_id,', ')                                                    as sub_part_ids,
               listagg(distinct sub_part_number, ', ')                                      as sub_part_numbers, --some part_ids map to the same part number, resulting in the same part number repeating in the list
               max_lud,
               sum(sub_not_dead) sub_flag --0 is truly dead in that location, >=1 a sub has been used in the last year in the location
        from sub_status
        group by og_part_id,
                 store_id,
                 snap_date,
                 max_lud
        --order by og_part_id, store_id, snap_date
    ), deadstock_detail as (
        select distinct og.snap_date,
                        og.part_id,
                        p.part_number,
                        p.search                                                            as description,
                        p.provider_id,
                        pr.name provider,
                        location bin_location,
                        sub_part_numbers,
                        sub_part_ids,
                        //case when sub_flag>=1 then 'Alive Sub'
                        //when sub_part_numbers is not null then 'Dead'
                        //else 'Dead and No Known Sub' end sub_flag_name,
                        og.store_id                                                         as inventory_location_id,
                        s.name as location_name,
                        coalesce(xw.MARKET_ID, ma.market_id)                                as the_market_id,
                        coalesce(xw.MARKET_NAME, ma.NAME)                                   as the_market_name,
                        coalesce(xw._id_dist, ma.district_id)                               as the_district_id,
                        coalesce(xw.DISTRICT, d.name)                                       as the_district_name,
                        coalesce(xw.REGION, d.REGION_ID)                                    as the_region_id,
                        coalesce(xw.REGION_NAME, r.name)                                    as the_region_name,
                        og.last_date                                                        as og_last_consumed,
                        coalesce(max_lud,og.last_date)                                      as overall_last_consumed,
                        iff(datediff('days',overall_last_consumed, og.snap_date)>{% parameter dead_stock_definition %},'Dead','Alive') as inv_health,
                        total_in_inventory,
                        avg_cost,
                        inv_dollars,
                        iff(inv_health='Dead', inv_dollars, 0)                              as dead_stock
        from og_stock                                                                       as og
        left join sub_flag                                                                  as sf --could add unique keys here
          on og.part_id = sf.og_part_id
              and og.store_id = sf.store_id
              and og.snap_date = sf.snap_date
        join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS                                     as s
          on og.store_id = s.INVENTORY_LOCATION_ID
        left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK                                      as xw
          on s.BRANCH_ID = xw.MARKET_ID
        left join ES_WAREHOUSE.PUBLIC.MARKETS                                               as ma
          on s.BRANCH_ID = ma.MARKET_ID
        left join ES_WAREHOUSE.PUBLIC.DISTRICTS                                             as d
          on ma.DISTRICT_ID = d.DISTRICT_ID
        left join ES_WAREHOUSE.PUBLIC.REGIONS                                               as r
          on d.REGION_ID = r.REGION_ID
        join es_warehouse.inventory.store_parts                                             as sp
          on og.part_id = sp.part_id
              and og.store_id = sp.store_id
        left join ES_WAREHOUSE.INVENTORY.PARTS                                              as p
          on og.part_id = p.part_id
        left join ES_WAREHOUSE.INVENTORY.PROVIDERS                                          as pr
          on p.provider_id = pr.provider_id
        left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS                             as tpi
          on tpi.part_id = og.part_id
        where total_in_inventory <> 0                       --1/17/24
          and location_name not ilike '%tele%'
          and tpi.part_id is null
          and p.provider_id not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api)
        order by og.part_id,
                 og.store_id,
                 og.snap_date
    ), dead_stock_by_store_part as (
        select d.snap_date
             , inventory_location_id
             , d.location_name                                                              as store_name
             , d.the_market_id
             , d.the_market_name
             , d.the_district_id
             , d.the_district_name
             , d.the_region_id
             , d.the_region_name
             , d.part_id
             , d.part_number
             , d.description
             , d.provider_id
             , sum(dead_stock)                                                              as dead_dollars
             , total_snap_balance                                                           as inventory_dollars
             --, dead_dollars/inventory_dollars
        from deadstock_detail                                                               as d
        join ttl_inv_snap                                                                   as t
          on d.snap_date=t.snap_date
              and t.store_id = inventory_location_id
              and t.part_id = d.part_id
        where inventory_location_id in (select il.inventory_location_id -- this is the accounting JE suppression piece
                                        from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS     as il
                                        join ES_WAREHOUSE.PUBLIC.MARKETS                    as m
                                          on il.BRANCH_ID = m.MARKET_ID
                                        where il.company_id = 1854
                                          and il.date_archived is null -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                                          and m.ACTIVE = TRUE) -- inactive store & market suppression
        group by d.snap_date
               , total_snap_balance
               , d.inventory_location_id
               , d.location_name
               , d.the_market_id
               , d.the_market_name
               , d.the_district_id
               , d.the_district_name
               , d.the_region_id
               , d.the_region_name
               , d.part_id
               , d.part_number
               , d.description
               , d.provider_id
        order by d.snap_date desc
    )
    --Less lookml work
        select snap_date
             , provider_id
             , part_id
             , inventory_location_id
             , store_name
             , the_market_id
             , the_market_name
             , the_district_name
             , the_region_name
             , sum(dead_dollars)                                                            as total_inventory_dead_dollars
             , sum(inventory_dollars)                                                       as total_inventory_value
             , total_inventory_dead_dollars/total_inventory_value                           as dead_ratio
        from dead_stock_by_store_part
        group by snap_date
               , provider_id
               , part_id
               , inventory_location_id
               , store_name
               , the_market_id
               , the_market_name
               , the_district_name
               , the_region_name
        order by snap_date desc;;
  }

  dimension: snap_date {
    type: date_month
    sql: ${TABLE}."SNAP_DATE" ;;
  }

  dimension_group: snap_date_complete {
    type: time
    timeframes: [raw, date, week, month, month_name, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SNAP_DATE" ;;
  }

  dimension: provider_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.provider_id ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: inventory_location_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."THE_MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."THE_MARKET_NAME" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."THE_DISTRICT_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."THE_REGION_NAME" ;;
  }

  dimension: dead_dollars {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_INVENTORY_DEAD_DOLLARS" ;;
  }

  measure: total_dead_dollars {
    type: sum
    value_format_name: usd_0
    sql: ${dead_dollars} ;;
  }

  dimension: inventory_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_INVENTORY_VALUE" ;;
  }

  dimension: dead_stock_ratio {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}."DEAD_RATIO" ;;
  }
  measure: total_dead_stock_ratio_html {
    type: number
html: {{total_dead_stock_ratio_html._rendered_value}} | {{total_dead_dollars._rendered_value}} of {{total_inventory_value._rendered_value}};;
    value_format_name: percent_1
    sql: ${total_dead_dollars}/${total_inventory_value} ;;
    drill_fields: [dead_stock_detail*]
  }
  measure: total_inventory_value {
    type: sum
    value_format_name: usd_0
    sql: ${inventory_value} ;;
    drill_fields: [dead_stock_detail*]
  }

set: dead_stock_detail {
  fields: [
          market_region_xwalk.market_id,
          market_region_xwalk.market_name,
          inventory_value,
          total_dead_dollars,
          total_dead_stock_ratio
          ]
}

  measure: total_dead_stock_ratio {
    type: number
    value_format_name: percent_0
    sql: ${total_dead_dollars} / ${total_inventory_value} ;;
  }

  dimension: selected_hierarchy_dimension {
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
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
  parameter: dead_stock_definition {
    type: string
    default_value: "180"
    allowed_value: {
      label: "3 Months"
      value: "90"
    }
    allowed_value: {
      label: "6 Months"
      value: "180"
    }
    allowed_value: {
      label: "9 Months"
      value: "270"
    }
    allowed_value: {
      label: "12 Months"
      value: "365"
    }
  }
}
