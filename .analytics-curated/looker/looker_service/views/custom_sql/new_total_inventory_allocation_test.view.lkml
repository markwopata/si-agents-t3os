view: new_total_inventory_allocation_test {
  derived_table: {
    sql:
with inventory_on_hand_prep as (
    select sp.STORE_ID
        , sp.PART_ID
        , sp.store_part_id
        , sp.QUANTITY
        , sp.available_quantity
        , sum(iff(r.target_type_id = 1,r.quantity,0)) as reserved_work_order
        , sum(iff(r.target_type_id = 2,r.quantity,0)) as reserved_invoice
        , sum(zeroifnull(r.quantity)) as reserved
    from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
    left join es_warehouse.inventory.reservations r
        on r.store_id = sp.store_id
            and r.part_id = sp.part_id
            and date_completed is null
            and date_cancelled is null
    group by 1,2,3,4,5
)
-- select count(reservation_id), count(distinct reservation_id) from inventory_on_hand ; --No dupes

, inventory_on_hand as (
    select store_id
        , part_id
        , store_part_id
        , available_quantity as quantity_on_hand
        , reserved_work_order
        , reserved_invoice
        , reserved
        , quantity - quantity_on_hand - reserved as quantity_on_rent
    from inventory_on_hand_prep
)

, current_store_inventory as (
    select dm.market_region as the_region_id
        , dm.market_region_name as the_region_name
        --no district id
        , dm.market_district as the_district_name
        , dm.market_id as the_market_id
        , dm.market_name as the_market_name
        , i.store_id
        , s.name as store_name
        , pr.provider_id
        , pr.name as provider_name
        , p.part_number
        , pt.description
        , p.master_part_id
        , i.part_id as the_part_id
        , i.store_part_id
        , wac.weighted_average_cost as average_cost
        , i.quantity_on_hand
        , i.quantity_on_hand * zeroifnull(wac.weighted_average_cost) as value_on_hand
        , i.quantity_on_rent
        , i.quantity_on_rent * zeroifnull(wac.weighted_average_cost) as value_on_rent
        , i.reserved_work_order
        , i.reserved_work_order * zeroifnull(wac.weighted_average_cost) as value_reserved_work_order
        , i.reserved_invoice
        , i.reserved_invoice * zeroifnull(wac.weighted_average_cost) as value_reserved_invoice
    from inventory_on_hand i
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
        on i.STORE_ID = s.INVENTORY_LOCATION_ID
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
        on dm.market_id = s.branch_id
    left join ANALYTICS.PARTS_INVENTORY.PARTS p
        on i.part_id = p.part_id
    left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wac
        on wac.is_current = TRUE
            and the_part_id = wac.product_id
            and i.STORE_ID = wac.inventory_location_id
    where s.date_archived is null
        and s.INVENTORY_LOCATION_ID in ( -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                select il.inventory_location_id -- this is the accounting JE suppression piece
                from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                join ES_WAREHOUSE.PUBLIC.MARKETS m
                    on il.BRANCH_ID = m.MARKET_ID
                where il.company_id = 1854
                    and il.date_archived is null
                    and m.ACTIVE = TRUE) -- inactive store & market suppression;
)

, market_parts as ( --Pulling the every part and market combination present in the inventory.
    select distinct the_market_id
        , the_part_id
   from current_store_inventory
   where the_part_id is not null
)

, on_order as (
    select concat(dm.market_id, p.part_id) as sum_distinct_key_on_order
        , iff(mp.the_market_id is null, TRUE, FALSE) as new_part
        , dm.market_region as the_region_id
        , dm.market_region_name as the_region_name
        --no district id
        , dm.market_district as the_district_name
        , dm.market_id as the_market_id
        , dm.market_name as the_market_name
        , null as store_id
        , null as store_name
        , pr.provider_id
        , pr.name as provider_name
        , p.part_number as the_part_number
        , pt.description
        , p.part_id as the_part_id
        , null as store_part_id
        , sum(poli.quantity - poli.total_accepted - poli.total_rejected) as quantity_on_order
        , avg(poli.price_per_unit) as avg_line_item_price
        , sum(poli.price_per_unit * (poli.quantity - poli.total_accepted - poli.total_rejected))  as value_on_order
    from procurement.public.purchase_orders po
    join procurement.public.purchase_order_line_items poli
        on po.purchase_order_id = poli.purchase_order_id
    join es_warehouse.inventory.parts og
        on poli.item_id = og.item_id
    join analytics.parts_inventory.parts p
        on og.part_id = p.part_id
    left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
        on p.provider_id = pr.provider_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
        on po.REQUESTING_BRANCH_ID = dm.market_id
            and dm.market_active
    left join market_parts mp
        on mp.the_market_id = dm.market_id
            and mp.the_part_id = p.part_id
    where po.date_archived is null
        and po.status = 'OPEN'
        and poli.date_archived is null
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
    having quantity_on_order > 0
)

    select ti.the_region_name
        , ti.the_district_name
        , ti.the_market_id
        , ti.the_market_name
        , ti.store_id
        , ti.store_name
        , ti.provider_id
        , ti.provider_name
        , ti.part_number
        , ti.description
        , ti.the_part_id as part_id
        , ti.store_part_id
        , ti.average_cost
        , ti.quantity_on_hand
        , ti.value_on_hand
        , ti.quantity_on_rent
        , ti.value_on_rent
        , ti.reserved_work_order
        , ti.value_reserved_work_order
        , ti.reserved_invoice
        , ti.value_reserved_invoice
        , oo.sum_distinct_key_on_order
        , zeroifnull(oo.quantity_on_order) quantity_on_order --MUST BE SUM DISTINCT ON kEY
        , zeroifnull(oo.value_on_order) as value_on_order --MUST BE SUM DISTINCT ON kEY
        , oo.avg_line_item_price
    from current_store_inventory ti
    left join on_order oo
        on oo.the_part_id = ti.the_part_id
            and oo.the_market_id = ti.the_market_id
            and oo.new_part = FALSE
    where ti.quantity_on_hand + ti.quantity_on_rent + ti.reserved_work_order + ti.reserved_invoice + zeroifnull(oo.quantity_on_order) <> 0

    union

    select the_region_name
        , the_district_name
        , the_market_id
        , the_market_name
        , store_id
        , store_name
        , provider_id
        , provider_name
        , the_part_number as part_number
        , description
        , the_part_id as part_id
        , null as store_part_id
        , null as average_cost
        , 0 as quantity_on_hand
        , 0 as value_on_hand
        , 0 as quantity_on_rent
        , 0 as value_on_rent
        , 0 as reserved_work_order
        , 0 as value_reserved_work_order
        , 0 as reserved_invoice
        , 0 as value_reserved_invoice
        , oo.sum_distinct_key_on_order
        , oo.quantity_on_order --MUST BE SUM DISTINCT ON kEY
        , oo.value_on_order as value_on_order --MUST BE SUM DISTINCT ON kEY
        , oo.avg_line_item_price
    from on_order oo
     where oo.new_part = TRUE
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

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.store_id ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: store_part_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  # dimension: primary_key {
  #   type: string
  #   primary_key: yes
  #   sql: concat(${market_id}, ${part_id}) ;;
  # }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER";;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION";;
  }

  dimension: average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.average_cost ;;
  }

  dimension: quantity_on_hand {
    type: number
    sql: ${TABLE}.quantity_on_hand;;
  }

  dimension: inventory_yesno {
    type: yesno
    sql: ${quantity_on_hand} > 0 ;;
  }

  dimension: value_on_hand {
    type: number
    value_format_name: usd
    sql: ${TABLE}.value_on_hand ;;
  }

  dimension: total_on_rent {
    type: number
    sql: ${TABLE}.quantity_on_rent;;
  }

  dimension: rent_yesno {
    type: yesno
    sql: ${total_on_rent} > 0 ;;
  }

  dimension: value_on_rent {
    type: number
    value_format_name: usd
    sql: ${TABLE}.value_on_rent;;
  }

  dimension: reserved_work_order {
    type: number
    sql: ${TABLE}.reserved_work_order ;;
  }

  dimension: value_reserved_work_order {
    type: number
    value_format_name: usd
    sql: ${TABLE}.value_reserved_work_order ;;
  }

  dimension: reserved_invoice {
    type: number
    sql: ${TABLE}.reserved_invoice ;;
  }

  dimension: value_reserved_invoice {
    type: number
    value_format_name: usd
    sql: ${TABLE}.value_reserved_invoice ;;
  }

  dimension: reserved_yesno {
    type: yesno
    sql: ${reserved_invoice} + ${reserved_work_order} > 0 ;;
  }

  dimension: sum_distinct_key_on_order {
    type: string
    sql: ${TABLE}.sum_distinct_key_on_order ;;
  }

  dimension: total_ordered {
    type: number
    sql: ${TABLE}.quantity_on_order;;
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
          ${store_name}
        {% elsif district_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

  dimension: provider_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.provider_id  ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  measure: avg_cost {
    type: average
    value_format_name: usd
    sql: ${average_cost} ;;
  }

  measure: on_hand_value  {
    type: sum
    sql: ${value_on_hand};;
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

  measure: reserved_work_order_value  {
    type: sum
    sql: ${value_reserved_work_order} ;;
    filters: [reserved_yesno: "yes"]
    value_format_name: usd_0
    # drill_fields: [on_rent_drill*]
  }

  measure: reserved_invoice_value  {
    type: sum
    sql: ${value_reserved_invoice} ;;
    filters: [reserved_yesno: "yes"]
    value_format_name: usd_0
    # drill_fields: [on_rent_drill*]
  }

  measure: on_order_value  {
    type: sum_distinct
    sql: ${order_value} ;;
    sql_distinct_key: ${sum_distinct_key_on_order} ;;
    filters: [ordered_yesno: "yes"]
    value_format_name: usd_0
    drill_fields: [on_order_drill*]
  }

  measure: on_hand {
    type: sum
    sql: ${quantity_on_hand} ;;
  }

  measure: on_rent {
    type: sum
    sql: ${total_on_rent} ;;
  }

  measure: reserved_wo {
    type: sum
    sql: ${reserved_work_order} ;;
  }

  measure: reserved_inv {
    type: sum
    sql: ${reserved_invoice} ;;
  }

  measure: on_order {
    type: sum_distinct
    sql_distinct_key: ${sum_distinct_key_on_order} ;;
    sql: ${total_ordered};;
  }

  set: drill_view {
    fields: [
      selected_hierarchy_dimension
      , part_id
      , part_number
      , description
      , provider
      , average_cost
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
