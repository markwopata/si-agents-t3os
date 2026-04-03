view: lead_time_2023 {
  derived_table: {
    sql:--Pulls POs to measure lead time since the beginning of 2023. If a market hasn't received a specific part since then, historical data will be pulled back to the beginning of 2021
with all_pos_prep as ( --need to pull in who received it
    select m.region_name
        , m.district
        , il.branch_id as market_id
        , m.market_name
        , po.purchase_order_number
        , po.purchase_order_id
        , po.date_created
        , r.date_received
        , datediff(days,po.date_created,r.date_received) lead_time
        , li.price_per_unit
        , ri.accepted_quantity
        , p.master_part_id as the_part_id
        , p.part_number as the_part_number
        , pt.description
        , pr.name provider
        , e.name vendor
        , evs.EXTERNAL_ERP_VENDOR_REF as vendorid
        , tvm.vendor_type
        , tvm.mapped_vendor_name
        , p.item_id
        , li.purchase_order_line_item_id
        , li.quantity
        , r.purchase_order_receiver_id
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    join ES_WAREHOUSE.INVENTORY.PARTS p1
        on li.item_id = p1.item_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on p1.part_id = p.part_id
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
        on r.purchase_order_id=po.purchase_order_id
    left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" e
        on po.vendor_ID = e.entity_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
        on e.entity_ID = evs.entity_ID
    left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on il.inventory_location_id = r.store_id
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = il.branch_id
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = evs.EXTERNAL_ERP_VENDOR_REF
    where po.purchase_order_number != 321858 --obvious mistake
        and to_date(po.date_created) >= '2021-01-01' --looking to 2021 for historical lead time, will calc avg in next cte
        and lead_time >=0  --this is cleaning up where PO created date is after received date due to manual receptions
        and ri.created_by_id != 21758 --this is eric prieto correcting POs for cost/quantities, but we want the og reception date
        and ri.accepted_quantity > 0 --Parts that were actually received
        and po.status!= 'ARCHIVED'
        and po.date_archived is null
        and li.date_archived is null
)

, eliminate_partial_deliveries as ( --Pulling total quantity accepted per line item and the max lead time to get the latest delivery.
    select max(lead_time) as max_lead_time
        , sum(accepted_quantity) as total_accepted
        , purchase_order_line_item_id
    from all_pos_prep
    group by purchase_order_line_item_id, quantity
    having total_accepted = quantity --We have accepted the full quantity if parts
)

, all_pos_final as (
    select distinct app.region_name --distinct for mistakes where deliveries were received multiple times.
        , app.district
        , app.market_id
        , app.market_name
        , app.purchase_order_number
        , app.purchase_order_id
        , app.date_created
        , max(to_timestamp_ntz(app.date_received)) as date_received --For deliveries on the same day
        , app.lead_time
        , app.price_per_unit
        , sum(epd.total_accepted) as accepted_quantity --Total accepted for that line item
        , app.the_part_id
        , app.the_part_number
        , app.description
        , app.provider
        , app.vendor
        , app.vendorid
        , app.vendor_type
        , app.mapped_vendor_name
        , app.item_id
        , app.purchase_order_line_item_id
    from all_pos_prep app
    join eliminate_partial_deliveries epd
        on epd.purchase_order_line_item_id = app.purchase_order_line_item_id
            and app.lead_time = epd.max_lead_time
    group by app.region_name
        , app.district
        , app.market_id
        , app.market_name
        , app.purchase_order_number
        , app.purchase_order_id
        , app.date_created
        , app.lead_time
        , app.price_per_unit
        , app.the_part_id
        , app.the_part_number
        , app.description
        , app.provider
        , app.vendor
        , app.vendorid
        , app.vendor_type
        , app.mapped_vendor_name
        , app.item_id
        , app.purchase_order_line_item_id
)
, po_23 as (
    select region_name
        , district
        , market_id
        , market_name
        , purchase_order_number
        , purchase_order_id
        , date_created
        , date_received
        , lead_time
        , price_per_unit
        , accepted_quantity
        , the_part_id as part_id
        , the_part_number as part_number
        , description
        , provider
        , vendor
        , vendorid
        , vendor_type
        , mapped_vendor_name
        , item_id
        , purchase_order_line_item_id
from all_pos_final
    where to_date(date_created) >= '2023-01-01'
)

, po_23_roll_call as (
    select distinct part_id
        , market_id
        , count(part_id)
    from po_23
    group by part_id, market_id
)

, po_23_check as ( --all POs for parts not in po_23 outside of the year 2023
    select ap.*
        , p23.part_id as check_id
        , p23.market_id as market_id_check
    from all_pos_final ap
    left join po_23_roll_call p23
        on p23.part_id = ap.the_part_id and p23.market_id = ap.market_id
    where to_date(ap.date_created) < '2023-01-01'
        and check_id is null
        and market_id_check is null
)

--, test as (
select region_name
    , district
    , market_id
    , market_name
    , purchase_order_number
    , purchase_order_id
    , date_created
    , date_received
    , lead_time
    , price_per_unit
    , accepted_quantity
    , the_part_id as part_id
    , the_part_number as part_number
    , description
    , provider
    , vendor
    , vendorid
    , vendor_type
    , mapped_vendor_name
    , item_id
    , purchase_order_line_item_id
from po_23_check

union

select *
from po_23
;;
}
dimension: region_name {
  type: string
  sql: ${TABLE}."REGION_NAME" ;;
}

  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: purchase_order_line_item_id {
    primary_key: yes
    sql:CAST(${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" as VARCHAR) ;;
  }

  dimension: po_number_link {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    html:<font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="_blank">{{ purchase_order_number._value }}</a></font></u>;;
  }

  dimension: date_created {
    type: date
    sql:  ${TABLE}."DATE_CREATED" ;;
  }

  dimension: date_received {
    type: date
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: lead_time {
    type: number
    sql: ${TABLE}."LEAD_TIME" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."ACCEPTED_QUANTITY" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
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

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: vendorid {
    type: number
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: selected_hierarchy_dimension {
    label: " Filtered Location"
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql: {% if district_name._in_query %}
          ${market_name}
        {% elsif market_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

measure: avg_price_paid {
  type: average
  sql: ${price_per_unit} ;;
  value_format: "$#.00"
}

  measure: avg_lead_time {
    type: average
    value_format: "0"
    sql: ${lead_time} ;;
    drill_fields: [
        selected_hierarchy_dimension
      , po_number_link
      , date_created
      , date_received
      , lead_time
      , part_id
      , part_number
      , description
      , provider
      , accepted_quantity
    ]
  }

  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${TABLE}."DATE_CREATED" <= current_date AND ${TABLE}."DATE_CREATED" >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  30_60_days{
    type: yesno
    sql:  ${TABLE}."DATE_CREATED" <= (current_date - INTERVAL '30 days') AND ${TABLE}."DATE_CREATED" >= (current_date - INTERVAL '60 days')
      ;;
  }

  measure: 30_day_avg {
    type: average
    filters: [last_30_days: "Yes"]
    value_format: "0"
    sql: ${lead_time} ;;
  }

  measure: days_30_avg_lead {
    type: average
    filters: [last_30_days: "No"]
    value_format: "0"
    sql: ${lead_time} ;;
  }

  measure: 30_60_day_avg {
    type: average
    filters: [30_60_days: "Yes"]
    value_format: "0"
    sql: ${lead_time} ;;
  }
  # -------------------- end rolling 30 days section --------------------
}

view: vendor_lead_time_score {
  derived_table: {
    sql:
with agg as (
    select v.mapped_vendor_name
        , avg(v.lead_time) vendor_avg_lead_time
    from ${lead_time_2023.SQL_TABLE_NAME} v
    where v.date_created >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1
)

, peer_avg as (
    select tvm.vendorid
        , avg(v.lead_time) as peer_avg_lead_time
    from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
    join ${lead_time_2023.SQL_TABLE_NAME} v
        on v.mapped_vendor_name <> tvm.mapped_vendor_name
            and v.vendor_type = tvm.vendor_type
            and v.date_created >= dateadd(month, -12, date_trunc(month, current_date))
    where tvm.primary_vendor ilike 'yes'
    group by 1
)

select v.vendorid
    , a.mapped_vendor_name
    , a.vendor_avg_lead_time
    , pa.peer_avg_lead_time
    , least(coalesce(pa.peer_avg_lead_time, 1000000000000), 3) as lead_time_target
    , iff(((lead_time_target / nullifzero(a.vendor_avg_lead_time)) * (1/14)) > (1/14), (1/14), (lead_time_target / nullifzero(a.vendor_avg_lead_time)) * (1/14) ) as lead_time_score
    , iff(((lead_time_target / nullifzero(a.vendor_avg_lead_time)) * 10) > 10, 10, (lead_time_target / nullifzero(a.vendor_avg_lead_time)) * 10 ) as lead_time_score10
from agg a
join "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
    on primary_vendor ilike 'yes'
        and v.mapped_vendor_name = a.mapped_vendor_name
left join peer_avg pa
    on pa.vendorid = v.vendorid ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }
  dimension: vendor_avg_lead_time {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.vendor_avg_lead_time  ;;
  }
  dimension: peer_avg_lead_time {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peer_avg_lead_time ;;
  }
  dimension: graded_target {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.lead_time_target ;;
  }
  dimension: lead_time_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.lead_time_score, 0) ;;
  }
  dimension: lead_time_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.lead_time_score10, 0) ;;
  }
}
