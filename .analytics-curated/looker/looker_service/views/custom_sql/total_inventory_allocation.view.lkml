view: total_inventory_allocation {
  derived_table: {
    sql: with inventory_on_hand as (select sp.STORE_ID
                                , sp.PART_ID
                                , sp.store_part_id
                                , sp.QUANTITY
                                , sp.available_quantity
                           from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                           where sp.store_id not in (432, 6004, 9814)
)

,reservation_parts as (
select
    r.part_id,
    r.store_id,
    s.store_part_id,
    sum(iff(r.target_type_id = 1,r.quantity,0)) as reserved_wo,
    sum(iff(r.target_type_id = 2,r.quantity,0)) as reserved_invoice,
    sum(r.quantity) as reserved
from es_warehouse.inventory.reservations r
join es_warehouse.inventory.store_parts s
    on r.store_id = s.store_id and r.part_id = s.part_id
where date_completed is null
and date_cancelled is null
group by
    r.part_id,
    r.store_id,
    s.store_part_id
)

, current_store_inventory as (
    select m.part_id
        , acs.weighted_average_cost                           as average_cost
        , m.store_part_id
        , m.store_id
        , m.AVAILABLE_QUANTITY                                as quantity_on_hand
        , quantity_on_hand * average_cost                     as value_on_hand
        , m.QUANTITY - (m.AVAILABLE_QUANTITY + zeroifnull(rp.reserved))     as quantity_on_rent
        , quantity_on_rent * average_cost                     as value_on_rent
        , reserved_wo
        , reserved_wo * average_cost                          as value_reserved_wo
        , reserved_invoice
        , reserved_invoice * average_cost                     as value_reserved_invoice
        , coalesce(xw.MARKET_ID, ma.market_id)                as the_market_id
        , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
        , coalesce(xw._id_dist, ma.district_id)               as the_district_id
        , coalesce(xw.DISTRICT, d.name)                       as the_district_name
        , coalesce(xw.REGION, d.REGION_ID)                    as the_region_id
        , coalesce(xw.REGION_NAME, r.name)                    as the_region_name
        , s.name                                              as store_name
        , p.master_part_id                                    as the_part_id
        , p.part_number                                       as the_part_number
        , pr.provider_id
        , pr.name as provider_name
        , pt.description
    from inventory_on_hand m
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
        on m.STORE_ID = s.INVENTORY_LOCATION_ID
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
        on s.BRANCH_ID = xw.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.MARKETS ma
        on s.BRANCH_ID = ma.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
        on ma.DISTRICT_ID = d.DISTRICT_ID
    left join ES_WAREHOUSE.PUBLIC.REGIONS r
        on d.REGION_ID = r.REGION_ID
    left join ANALYTICS.PARTS_INVENTORY.PARTS p
        on m.part_id = p.part_id
    left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS acs
        on the_part_id = acs.product_id
            and m.STORE_ID = acs.inventory_location_id
    left join reservation_parts rp
        on m.store_part_id = rp.store_part_id
    where s.date_archived is null
        and m.QUANTITY > 0
        and the_region_id is not null
        and acs.is_current = true
        and s.INVENTORY_LOCATION_ID in (select il.inventory_location_id -- this is the accounting JE suppression piece
                     from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                              join ES_WAREHOUSE.PUBLIC.MARKETS m
                                   on il.BRANCH_ID = m.MARKET_ID
                     where il.company_id = 1854
                       and il.date_archived is null -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                       and m.ACTIVE = TRUE) -- inactive store & market suppression
)

, total_inventory_market as ( --have to rewrite it at the market level for PO data to work
    select the_region_id
        , the_region_name
        , the_district_id
        , the_district_name
        , the_market_id
        , the_market_name
        , the_part_id
        , the_part_number
        , provider_id
        , provider_name
        , description
        , avg(average_cost) as average_cost_across_market
        , sum(quantity_on_hand) as total_market_inventory
        , sum(value_on_hand) as market_inventory_value
        , sum(quantity_on_rent) as total_market_on_rent
        , sum(value_on_rent) as market_rent_value
        , zeroifnull(sum(reserved_wo)) as total_market_reserved_wo
        , zeroifnull(sum(value_reserved_wo)) as market_reserved_wo_value
        , zeroifnull(sum(reserved_invoice)) as total_market_reserved_invoice
        , zeroifnull(sum(value_reserved_invoice)) as market_reserved_invoice_value
    from  current_store_inventory
    group by the_part_id
        , the_part_number
        , provider_id
        , provider_name
        , description
        , the_district_id
        , the_district_name
        , the_region_id
        , the_region_name
        , the_market_id
        , the_market_name
)

, market_parts as ( --Pulling the every part and market combination present in the inventory.
    select distinct the_market_id
        , the_part_id
   from total_inventory_market
   where the_part_id is not null
)

, on_order as ( --All open purchase orders by requesting market. We don't know who is going to receive them based off the data.
    select coalesce(xw.MARKET_ID, ma.market_id)               as the_market_id
        , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
        , coalesce(xw._id_dist, ma.district_id)               as the_district_id
        , coalesce(xw.DISTRICT, d.name)                       as the_district_name
        , coalesce(xw.REGION, d.REGION_ID)                    as the_region_id
        , coalesce(xw.REGION_NAME, reg.name)                  as the_region_name
        , sum(li.quantity - li.total_accepted - total_rejected) as total_on_order
        , avg(li.price_per_unit) as avg_line_item_price
        , total_on_order * avg_line_item_price as value_on_order
        , p.master_part_id as the_part_id
        , p.part_number as the_part_number
        , pr.provider_id
        , pr.name as provider_name
        , pt.description
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on po.PURCHASE_ORDER_ID = li.PURCHASE_ORDER_ID
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    join es_warehouse.inventory.parts og
  on li.item_id=og.item_id
   join analytics.parts_inventory.parts p
    on og.part_id = p.part_id
    join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
        on po.REQUESTING_BRANCH_ID = xw.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.MARKETS ma
        on po.REQUESTING_BRANCH_ID = ma.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
        on ma.DISTRICT_ID = d.DISTRICT_ID
    left join ES_WAREHOUSE.PUBLIC.REGIONS reg
        on d.REGION_ID = reg.REGION_ID
    where po.status = 'OPEN'
        AND DATE_RECEIVED IS NULL
        and the_region_id is not null
        and li.date_archived is null
        and po.date_archived is null
        and ma.company_id = 1854
        and ma.ACTIVE = TRUE
    group by the_market_id
        , the_market_name
        , the_district_id
        , the_district_name
        , the_region_id
        , the_region_name
        , the_part_id
        , the_part_number
        , pt.description
        , pr.provider_id
        , provider_name
)

, new_parts as  (
    select oo.* --Pull all on order that don't have an existing market part combination.
    from on_order oo
    left join market_parts m
        on oo.the_part_id = m.the_part_id
            and oo.the_market_id = m.the_market_id
    where m.the_part_id is null
)

    select ti.the_region_name
        , ti.the_district_name
        , ti.the_market_id
        , ti.the_market_name
        , ti.the_part_id as part_id
        , ti.the_part_number as part_number
        , ti.description
        , ti.provider_id
        , ti.provider_name
        , ti.average_cost_across_market
        , ti.total_market_inventory
        , ti.market_inventory_value
        , ti.total_market_on_rent
        , ti.market_rent_value
        , ti.total_market_reserved_wo
        , ti.market_reserved_wo_value
        , ti.total_market_reserved_invoice
        , ti.market_reserved_invoice_value
        , oo.total_on_order
        , oo.value_on_order
        , oo.avg_line_item_price
    from total_inventory_market ti
    left join on_order oo
        on oo.the_part_id = ti.the_part_id
            and oo.the_market_id = ti.the_market_id

    union

    select np.the_region_name
        , np.the_district_name
        , np.the_market_id
        , np.the_market_name
        , np.the_part_id as part_id
        , np.the_part_number as part_number
        , np.description
        , np.provider_id
        , np.provider_name
        , null as average_cost_across_market
        , 0 as total_market_inventory
        , 0 as market_inventory_value
        , 0 as total_market_on_rent
        , 0 as market_rent_value
        , 0 as total_market_reserved_wo
        , 0 as market_reserved_wo_value
        , 0 as total_market_reserved_invoice
        , 0 as market_reserved_invoice_value
        , np.total_on_order
        , np.value_on_order
        , np.avg_line_item_price
    from new_parts np
;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."THE_REGION_NAME" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."THE_DISTRICT_NAME" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."THE_MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."THE_MARKET_NAME";;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${market_id}, ${part_id}) ;;
  }

  measure: count {
    type: count
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER";;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION";;
  }

  dimension: average_market_cost{
    type: number
    value_format_name: usd
    sql: ${TABLE}."AVERAGE_COST_ACROSS_MARKET";;
  }

  dimension: total_market_inventory {
    type: number
    sql: ${TABLE}."TOTAL_MARKET_INVENTORY";;
  }

  dimension: inventory_yesno {
    type: yesno
    sql: ${total_market_inventory} > 0 ;;
  }

  dimension: market_inventory_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."MARKET_INVENTORY_VALUE";;
  }

  dimension: total_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_MARKET_ON_RENT";;
  }

  dimension: rent_yesno {
    type: yesno
    sql: ${total_on_rent} > 0 ;;
  }

  dimension: value_on_rent {
    type: number
    value_format_name: usd
    sql: ${TABLE}."MARKET_RENT_VALUE";;
  }

  dimension: total_reserved_wo {
    type: number
    sql: ${TABLE}.total_market_reserved_wo ;;
  }

  dimension: value_reserved_wo {
    type: number
    value_format_name: usd
    sql: ${TABLE}.market_reserved_wo_value ;;
  }

  dimension: value_reserved_invoice {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_reserved_invoice_value ;;
  }

  dimension: total_reserved_invoice {
    type: number
    sql: ${TABLE}.total_market_reserved_invoice ;;
  }

  dimension: total_ordered {
    type: number
    sql: ${TABLE}."TOTAL_ON_ORDER";;
  }

  dimension: ordered_yesno {
    type: yesno
    sql: ${total_ordered} > 0 ;;
  }

  dimension: order_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."VALUE_ON_ORDER";;
  }

  dimension: average_line_item_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AVG_LINE_ITEM_PRICE";;
  }

  dimension: selected_hierarchy_dimension {
    label: "Filtered Location"
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql: {% if market_name._in_query %}
          ${market_name}
        {% elsif district_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

  dimension: provider_id {
    type: string
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  measure: avg_cost {
    type: average
    value_format_name: usd
    sql: ${average_market_cost} ;;
  }

  measure: on_hand_value  {
    type: sum
    sql: ${market_inventory_value} ;;
    value_format_name: usd_0
    filters: [inventory_yesno: "yes"]
    drill_fields: [on_hand_drill*]
    #link: {label: "Drill" url:"{{ filterdrill_on_hand_drill._link }}&f[on_hand]>0" }
  }

  measure: on_rent_value  {
    type: sum
    sql: ${value_on_rent} ;;
    filters: [rent_yesno: "yes"]
    value_format_name: usd_0
    drill_fields: [on_rent_drill*]
  }

  measure: reserve_wo_value  {
    type: sum
    sql: ${value_reserved_wo} ;;
    value_format_name: usd_0
  }

  measure: reserve_invoice_value {
    type: sum
    sql: ${value_reserved_invoice} ;;
    value_format_name: usd_0
  }

  measure: on_order_value  {
    type: sum
    sql: ${order_value} ;;
    filters: [ordered_yesno: "yes"]
    value_format_name: usd_0
    drill_fields: [on_order_drill*]
  }

  measure: on_hand {
    type: sum
    sql: ${total_market_inventory} ;;
  }

  measure: on_rent {
    type: sum
    sql: ${total_on_rent} ;;
  }

  measure: on_order {
    type: sum
    sql: ${total_ordered};;
  }

  measure: reserved_wo {
    type: sum
    sql: ${total_reserved_wo} ;;
  }

  measure: reserved_invoice {
    type: sum
    sql: ${total_reserved_invoice} ;;
  }

  set: drill_view {
    fields: [
     selected_hierarchy_dimension
    , part_id
    , part_number
    , description
    , provider
    , average_market_cost
    , on_hand
    , on_hand_value
    , on_rent
    , on_rent_value
    , on_order
    , on_order_value
    , average_line_item_price
  ]
  }

  set: on_hand_drill {
    fields: [
      selected_hierarchy_dimension
      , part_number
      , description
      , provider
      , on_hand
      , on_hand_value
      , avg_cost
    ]
  }

  set: on_rent_drill {
    fields: [
      selected_hierarchy_dimension
      , part_number
      , description
      , provider
      , on_rent
      , on_rent_value
      , avg_cost
    ]
  }

  set: on_order_drill {
    fields: [
      selected_hierarchy_dimension
      , part_number
      , description
      , provider
      , on_order
      , on_order_value
      , average_line_item_price
    ]
  }
  }
