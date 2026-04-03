view: current_deadstock {
  derived_table: {
    sql:--Deadstock
with inventory_on_hand as (
    select sp.STORE_ID as inventory_location_id
        , sp.PART_ID
        , sp.store_part_id
        , sp.QUANTITY
    from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
    where sp.store_id not in (432, 6004, 9814)
)

, last_time_consumed as (
    select ti.PART_ID
        , t.FROM_ID                   as inventory_location_id
        , il.BRANCH_ID
        , max(t.DATE_COMPLETED)::date as last_use_date
    from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
    join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
        on ti.TRANSACTION_ID = t.TRANSACTION_ID
    join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
        on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
    left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on t.FROM_ID = il.INVENTORY_LOCATION_ID
    where tt.TRANSACTION_TYPE_ID in (3,7,13)  -- Store to Retail Sale; Store to Work Order, Store to Rental Retail Sale
        and DATE_CANCELLED is null
        and t.from_id not in (432, 6004, 9814)
    group by ti.PART_ID
        , t.FROM_ID
        , il.branch_id)

, last_time_rented as (
     SELECT distinct rpa.PART_ID
        , il.INVENTORY_LOCATION_ID
        , il.BRANCH_ID
        , max(iff(
            current_date() between rpa.START_DATE and coalesce(rpa.END_DATE, '2099-12-31')
            , current_date()
            , rpa.END_DATE))::date as last_use_date
    FROM ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
    join ES_WAREHOUSE.PUBLIC.RENTALS r
        on rpa.RENTAL_ID = r.RENTAL_ID
    join ES_WAREHOUSE.PUBLIC.ORDERS o
        on r.ORDER_ID = o.ORDER_ID
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on o.MARKET_ID = il.BRANCH_ID
    where r.DELETED = false
        and il.date_archived is null
    group by rpa.PART_ID, il.INVENTORY_LOCATION_ID, il.BRANCH_ID
)

, last_used_date as (
    select part_id
        , inventory_location_id
        , branch_id
        , max(last_use_date) as last_used_date
    from (select *
        from last_time_consumed

    union all

    select *
    from last_time_rented) as last_use
    group by part_id
        , inventory_location_id
        , branch_id)

, last_time_ordered as (
    select ti.PART_ID
        , t.to_ID as inventory_location_id
        , il.BRANCH_ID
        , max(t.DATE_COMPLETED)::date as last_ordered_date
    from ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
    join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
        on ti.TRANSACTION_ID = t.TRANSACTION_ID
    join ES_WAREHOUSE.INVENTORY.TRANSACTION_TYPES tt
        on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
    left join ES_WAREHOUSE.INVENTORY.MANUAL_ADJUSTMENTS ma
        on ti.transaction_item_id = ma.TRANSACTION_ITEM_ID
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on t.to_id = il.INVENTORY_LOCATION_ID
    where t.transaction_type_id in (1, 4, 6, 9, 11, 14, 15, 17, 20, 21, 23) -- all ""to store""
        and t.DATE_CANCELLED is null
        and t.to_id not in (432, 6004, 9814)
        and t.date_completed is not null
    group by ti.PART_ID
        , t.to_ID
        , il.branch_id
)

, og_stock as (
    select m.part_id
        , m.store_part_id
        , m.inventory_location_id
        , m.QUANTITY                                          as total_in_inventory
        , acs.weighted_average_cost                           as AVG_COST
        , lud.last_used_date
        , lto.last_ordered_date
        , coalesce(lud.last_used_date, lto.last_ordered_date) as the_date
        , datediff(month, the_date, current_date())           as months_since_consumption
        , m.QUANTITY * acs.weighted_average_cost              as total_dollars_in_inventory
        , sp.SUB_PART_NUMBER
        , p.part_id                                           as sub_part_id
        , case
            when months_since_consumption > 6 then total_in_inventory
            when months_since_consumption is null then total_in_inventory
            else 0 end as dead_stock_quantity
        , dead_stock_quantity * acs.weighted_average_cost as total_deadstock_dollars
    from inventory_on_hand m
        left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS acs
            on m.PART_ID = acs.product_id
                and m.inventory_location_id = acs.inventory_location_id
        left join last_used_date lud
            on m.PART_ID = lud.PART_ID
                and m.inventory_location_id = lud.inventory_location_id
        left join last_time_ordered lto
            on m.PART_ID = lto.PART_ID
                and m.inventory_location_id = lto.inventory_location_id
        left join ANALYTICS.PARTS_INVENTORY.SUB_PARTS sp
            on m.PART_ID = sp.ORIGINAL_PART_ID
        left join ES_WAREHOUSE.INVENTORY.PARTS p
            on sp.SUB_PART_NUMBER = p.PART_NUMBER
                and sp.SUB_PROVIDER_ID = p.PROVIDER_ID
        where acs.is_current = true
            and m.inventory_location_id != 400
            and dead_stock_quantity <> 0
        order by part_id, store_part_id
)

, subs as(
    select m.part_id
        , m.store_part_id
        , m.inventory_location_id
        , lud.last_used_date
        , lto.last_ordered_date
        , coalesce(lud.last_used_date, lto.last_ordered_date) as the_date
        , p.part_number
    from inventory_on_hand m
    left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS acs
        on m.PART_ID = acs.product_id
            and m.inventory_location_id = acs.inventory_location_id
    left join last_used_date lud
        on m.PART_ID = lud.PART_ID
            and m.inventory_location_id = lud.inventory_location_id
    left join last_time_ordered lto
        on m.PART_ID = lto.PART_ID
            and m.inventory_location_id = lto.inventory_location_id
    left join ES_WAREHOUSE.INVENTORY.PARTS p
        on m.part_id = p.part_id
    where acs.is_current = true
        and m.inventory_location_id != 400
    order by part_id, store_part_id
)

, sub_status as (
    select distinct og.part_id as og_part_id
        , og.inventory_location_id
        , sub.part_id sub_part_id
        , sub.part_number sub_part_number
        , max(greatest(og.the_date,sub.the_date)) over (partition by og_part_id,og.inventory_location_id) max_lut
        , iff(datediff('days',max_lut, current_date)>180,0,1) sub_not_dead
    from og_stock og
    left join subs sub
        on og.sub_part_id=sub.part_id
            and og.inventory_location_id=sub.inventory_location_id
    where og_part_id != sub.part_id
    order by og.part_id, og.inventory_location_id
)

, sub_flag as (
    select og_part_id
        , inventory_location_id
        , listagg(sub_part_id,' / ') sub_part_ids
        , listagg(sub_part_number, ' / ') sub_part_numbers
        , max_lut
        , sum(sub_not_dead) sub_flag --0 is truly dead in that location, 1 is a sub has been used in the last year in the location
    from sub_status
    group by og_part_id
    , inventory_location_id
    , max_lut
)

--, test as (
select distinct og.part_id
    , og.store_part_id
    , p.part_number
    , pt.description
    , p.provider_id
    , pr.name provider
    , location bin_location
    , sub_part_numbers
    , sub_part_ids
    --, sub_flag alive_subs --1 is not truly dead, 0 is dead dead
    , case when sub_flag>=1 then 'Alive Sub'
        when sub_part_numbers is not null then 'Dead'
        else 'Dead and No Known Sub'
        end sub_flag_name
    , og.inventory_location_id
    , s.name location_name
    , xw.market_type
    , coalesce(xw.MARKET_ID, ma.market_id) as the_market_id
    , coalesce(xw.MARKET_NAME, ma.NAME) as the_market_name
    , coalesce(xw._id_dist, ma.district_id) as the_district_id
    , coalesce(xw.DISTRICT, d.name) as the_district_name
    , coalesce(xw.REGION, d.REGION_ID) as the_region_id
    , coalesce(xw.REGION_NAME, r.name) as the_region_name
    , coalesce(the_date, '2021-01-01') as og_last_consumed
    , max_lut overall_last_consumed
    , total_in_inventory
    , avg_cost
    , total_dollars_in_inventory
    , dead_stock_quantity
    , coalesce(total_deadstock_dollars,0) as deadstock_value
from og_stock og
left join sub_flag sf
    on og.part_id=sf.og_part_id and
       og.inventory_location_id = sf.inventory_location_id
join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
    on og.inventory_location_id = s.INVENTORY_LOCATION_ID
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
    on s.BRANCH_ID = xw.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.MARKETS ma
    on s.BRANCH_ID = ma.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
    on ma.DISTRICT_ID = d.DISTRICT_ID
left join ES_WAREHOUSE.PUBLIC.REGIONS r
    on d.REGION_ID = r.REGION_ID
join es_warehouse.inventory.store_parts sp
    on og.store_part_id = sp.store_part_id
left join ES_WAREHOUSE.INVENTORY.PARTS p
    on og.part_id = p.part_id
left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
    on p.provider_id = pr.provider_id
left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
    on p.part_type_id = pt.part_type_id
left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi
    on tpi.part_id = og.part_id
where (sub_flag = 0 or sub_flag is null) --dead dead
  and total_in_inventory <> 0
  and s.date_archived is null
  and ma.company_id = 1854
  and location_name not ilike '%tele%'
  and tpi.part_id is null
  and p.provider_id not in (select api.provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS as api)
--  and og.dead_stock_quantity <> total_in_inventory
--  where sub_flag>0 --has a sub in use
 ;;
  }

dimension: snap_reference {
  type: date
  sql: ${TABLE}."SNAP_REFERENCE" ;;
}

dimension: part_id {
  type: number
  value_format_name: id
  sql: ${TABLE}."PART_ID" ;;
}

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
    primary_key: yes
  }

dimension: part_number {
  type: string
  sql: ${TABLE}."PART_NUMBER" ;;
}

dimension: description {
  type: string
  sql: ${TABLE}."DESCRIPTION" ;;
}

dimension: provider {
  type: string
  sql: ${TABLE}."PROVIDER" ;;
}

dimension: bin_location {
  type: string
  sql: ${TABLE}."BIN_LOCATION" ;;
}

dimension: sub_part_number {
  type: string
  sql: trim(${TABLE}."SUB_PART_NUMBERS") ;;
  skip_drill_filter: yes
}

dimension: sub_part_ids {
  type: string
  sql: ${TABLE}."SUB_PART_IDS" ;;
}

dimension: sub_flag_name {
  type: string
  sql: ${TABLE}."SUB_FLAG_NAME" ;;
  }

dimension: market_type {
  type: string
  sql: ${TABLE}.market_type ;;
}

dimension: inventory_location_id {
  type: number
  sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
}

dimension: store_name {
  type: string
  sql: ${TABLE}."LOCATION_NAME" ;;
}

dimension: market_id {
  type: number
  sql: ${TABLE}."THE_MARKET_ID" ;;
}

dimension: market_name {
  type: string
  sql: ${TABLE}."THE_MARKET_NAME" ;;
}

dimension: district_id {
  type: string
  sql: ${TABLE}."THE_DISTRICT_ID" ;;
}

dimension: district_name {
  type: string
  sql: ${TABLE}."THE_DISTRICT_NAME" ;;
}

dimension: region_id {
type: string
sql: ${TABLE}."THE_REGION_ID" ;;
}

dimension: region_name {
  type: string
  sql: ${TABLE}."THE_REGION_NAME" ;;
}

dimension: og_last_consumed {
  type: date
  sql: ${TABLE}."OG_LAST_CONSUMED" ;;
}

dimension: overall_last_consumed {
  type: date
  sql: iff(${og_last_consumed} <= coalesce(${TABLE}."OVERALL_LAST_CONSUMED", '1999-01-01'), ${TABLE}."OVERALL_LAST_CONSUMED", ${og_last_consumed})  ;;
  }

dimension: total_in_inventory {
  type: number
  sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
}

dimension: avg_cost {
  type: number
  sql: ${TABLE}."AVG_COST" ;;
}

  dimension: total_dollars_in_inventory {
    type: number
    sql: ${TABLE}."TOTAL_DOLLARS_IN_INVENTORY" ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}."DEAD_STOCK_QUANTITY" ;;
  }

  dimension: deadstock_value {
    type: number
    sql: ${TABLE}."DEADSTOCK_VALUE" ;;
  }

  dimension: selected_hierarchy_dimension {
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql:{% if market_name._in_query %}
          ${store_name}
        {% elsif district_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

  dimension: selected_hierarchy_dimension_inverted {
    type: string
    #   # link: {label:"El ChuPARTcabra Dashboard"
    #   #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql:{% if region_name._in_query %}
          ${region_name}
        {% elsif district_name._in_query %}
          ${district_name}
        {% elsif market_name._in_query %}
          ${market_name}
        {% else %}
          null--${market_name}
        {% endif %};;
  }

  measure: total_dead_stock_quantity {
    type: sum
    sql: ${dead_stock_quantity} ;;
    filters: [sub_flag_name: "Dead, Dead and No Known Sub"]
  }

  measure: total_dead_stock_dollars {
    type: sum
    value_format_name: usd
    sql: ${deadstock_value} ;;
    filters: [sub_flag_name: "Dead, Dead and No Known Sub"]
  }

  measure: total_inventory_quantity {
    type: sum
    sql: ${total_in_inventory} ;;
  }

  measure: total_value {
    type: sum
    value_format_name: usd
    sql: ${total_dollars_in_inventory} ;;
  }

  measure: dead_stock_ratio {
    type: number
    value_format_name: percent_2
    sql: ${total_dead_stock_dollars} / ${total_value} ;;
      link: {
      label: "Current Dead Stock Inventory"
      url: "https://equipmentshare.looker.com/dashboards/1113?District+Name={{ _filters['deadstock.district_name'] | url_encode }}&Market+Name={{ _filters['deadstock.market_name'] | url_encode }}&Region+Name={{ _filters['deadstock.region_name'] | url_encode }}&Store+Name={{ _filters['deadstock.store_name'] | url_encode }}&Part+Number="
    }
  }

}
      # part_id,
      # provider,
      # part_number,
      # description,

view: market_wide_part_dead_stock {
  derived_table: {
    sql:
      select the_market_id
        , part_number
        , sum(zeroifnull(dead_stock_quantity)) as dead_quantity
        , sum(zeroifnull(deadstock_value)) as dead_value
      from ${current_deadstock.SQL_TABLE_NAME}
      group by 1, 2;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_market_id;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${market_id}, ${part_number}) ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}.dead_quantity ;;
  }

  dimension: dead_stock_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.dead_value ;;
  }
}

view: company_wide_part_dead_stock {
  derived_table: {
    sql:
      select part_number
        , sum(zeroifnull(dead_stock_quantity)) as dead_quantity
        , sum(zeroifnull(deadstock_value)) as dead_value
      from ${current_deadstock.SQL_TABLE_NAME}
      group by 1;;
  }

  dimension: part_number {
    type: string
    primary_key: yes
    sql: ${TABLE}.part_number ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}.dead_quantity ;;
  }

  dimension: dead_stock_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.dead_value ;;
  }
}
