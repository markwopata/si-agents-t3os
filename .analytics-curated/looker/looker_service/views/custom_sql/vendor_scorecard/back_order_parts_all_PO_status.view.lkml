view: back_order_parts_all_PO_status {
  derived_table: {
    sql:
select xw.MARKET_ID                                  as the_market_id
        , xw.MARKET_NAME                             as the_market_name
        , xw._id_dist                                as the_district_id
        , xw.DISTRICT                                as the_district_name
        , xw.REGION                                  as the_region_id
        , xw.REGION_NAME                             as the_region_name
        , po.purchase_order_number
        , po.date_created
        , datediff(days, po.date_created, coalesce(max(DATE_RECEIVED),current_date)) days_since_order
        , li.purchase_order_line_item_id
        , li.quantity as total_on_order
        , li.price_per_unit
        , total_on_order * li.price_per_unit as value_on_order
        , p.master_part_id as the_part_id
        , p.part_number as the_part_number
        , pr.name as provider_name
        , pt.description
        , max(r.date_received) date_received
        , po.purchase_order_id
        , ent.name as vendor_name
        , evs.EXTERNAL_ERP_VENDOR_REF as vendorid
        , tvm.mapped_vendor_name
        , tvm.vendor_type
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on po.PURCHASE_ORDER_ID = li.PURCHASE_ORDER_ID
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    join ES_WAREHOUSE.INVENTORY.PARTS p1
        on li.item_id = p1.item_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on p1.part_id = p.part_id
    join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.part_type_id = pt.PART_TYPE_ID
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
        on po.REQUESTING_BRANCH_ID = xw.MARKET_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITIES" ent
        on po.VENDOR_ID = ent.ENTITY_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
        on ent.entity_ID = evs.entity_ID
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = evs.EXTERNAL_ERP_VENDOR_REF
    where po.date_archived is null
        and li.date_archived is null
        and purchase_order_number not in (1129828, 321858) --Receiver dates hundreds of years from now
    group by the_market_id
        , the_market_name
        , the_district_id
        , the_district_name
        , the_region_id
        , the_region_name
        , po.purchase_order_number
        , po.date_created
        , the_part_id
        , the_part_number
        , pt.description
        , provider_name
        , li.purchase_order_line_item_id
        , po.purchase_order_number
        , li.price_per_unit
        , po.purchase_order_id
        , ent.name
        , evs.EXTERNAL_ERP_VENDOR_REF
        , total_on_order
        , tvm.mapped_vendor_name
        , tvm.vendor_type
    having days_since_order >= 7
    order by days_since_order desc;;

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
    sql: ${TABLE}."THE_MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."THE_MARKET_NAME" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: date_created {
    type: date
    sql:  ${TABLE}."DATE_CREATED" ;;
  }

  dimension: days_since_order {
    type: number
    sql: ${TABLE}."DAYS_SINCE_ORDER" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."THE_PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."THE_PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: purchase_order_line_item_id {
    primary_key: yes
    type:  string
    sql:CAST(${TABLE}.purchase_order_line_item_id as VARCHAR) ;;
  }

#<<<<<<< HEAD
  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: po_number_link {
    label: "PO w/ Link"
    type: number
    sql:${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    html:<font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="_blank">{{ purchase_order_number._value }}</a></font></u>;;
  }

  dimension: qty_on_order {
    type: number
    sql: ${TABLE}."TOTAL_ON_ORDER" ;;
  }
#=======
  dimension: value_on_order {
    type: number
    sql: ${TABLE}."VALUE_ON_ORDER" ;;
#>>>>>>> branch 'master' of https://github.com/EquipmentShare/looker_service.git
  }

# dimension: vendor {
#   type: string
#   sql: ${TABLE}."VENDOR" ;;
# }

# dimension: item_id {
#   type: string
#   sql: ${TABLE}."ITEM_ID" ;;
# }

  dimension: selected_hierarchy_dimension_v2 {
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql: {% if market_name._in_query %}
          ${market_name}
        {% elsif district_name._in_query %}
          ${district_name}}
        {% elsif region_name._in_query %}
          ${region_name}
        {% else %}
          null
        {% endif %};;
  }

  measure: avg_days_since_order {
    type: average
    value_format: "0"
    sql: ${days_since_order} ;;
    drill_fields: [
      region_name
      , district_name
      , market_name
      , po_number_link
      , date_created
      , days_since_order
      , part_number
      , description
      , provider
      , back_order_work_orders.potential_wo
      , back_order_work_orders.asset_id
      , back_order_work_orders.make
      , back_order_work_orders.model
    ]}

  measure: sum_value_on_order {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${value_on_order} ;;
    drill_fields: [
      region_name
      , district_name
      , market_name
      , po_number_link
      , date_created
      , days_since_order
      , part_number
      , description
      , provider
      , back_order_work_orders.potential_wo
      , back_order_work_orders.asset_id
      , back_order_work_orders.make
      , back_order_work_orders.model
    ]}

  measure: sum_value_on_order_no_drill{ #under construction
    label: "Total value on order"
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${value_on_order} ;;
    drill_fields: [entities.name,
      part_id, part_number, sum_total_on_order,
      po_number_link,
      back_order_work_orders_listed.make_2,
      back_order_work_orders_listed.model_2,
      assets_aggregate.oec,
      daily_rev_calculation.time_utilization,
      work_orders.max_days_open,
      unreceived_pos.invoice_number
    ] #assets_aggregate.class - not sure if really needed here -
  }
#
  measure: count_po {
    type: count_distinct
    sql: ${purchase_order_number} ;;
    drill_fields: [
      region_name
      , district_name
      , market_name
      , po_number_link
      , date_created
      , days_since_order
      , part_number
      , description
      , provider
      , back_order_work_orders.potential_wo
      , back_order_work_orders.asset_id
      , back_order_work_orders.make
      , back_order_work_orders.model
    ]}


  measure: count_part_id {
    type: count
    drill_fields: [
      region_name
      , district_name
      , market_name
      , po_number_link
      , date_created
      , days_since_order
      , part_number
      , description
      , provider
      , back_order_work_orders.potential_wo
      , back_order_work_orders.asset_id
      , back_order_work_orders.make
      , back_order_work_orders.model
    ]}


  measure: sum_total_on_order { #under construction
    type: sum
    sql: ${qty_on_order} ;;
  }

  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${TABLE}."DATE_CREATED" <= current_date AND ${TABLE}."DATE_CREATED" >= (current_date - INTERVAL '30 days')
      ;;
  }

  measure: 30_day_cost {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${value_on_order} ;;
  }

  measure: 30_day_avg {
    type: average
    filters: [last_30_days: "No"]
    value_format: "0"
    sql: ${days_since_order} ;;
  }

  # -------------------- end rolling 30 days section --------------------
}

view: vendor_back_order_score {
  derived_table: {
    sql:
with agg as (
    select v.mapped_vendor_name
        , avg(v.days_since_order) vendor_avg_back_order_length
    from ${back_order_parts_all_PO_status.SQL_TABLE_NAME} v
    where v.date_created >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1
)

, peer_avg as (
    select tvm.vendorid
        , avg(v.days_since_order) as peer_avg_back_order_length
    from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
    join ${back_order_parts_all_PO_status.SQL_TABLE_NAME} v
        on v.mapped_vendor_name <> tvm.mapped_vendor_name
            and v.vendor_type = tvm.vendor_type
            and v.date_created >= dateadd(month, -12, date_trunc(month, current_date))
    where tvm.primary_vendor ilike 'yes'
    group by 1
)

select v.vendorid
    , a.mapped_vendor_name
    , a.vendor_avg_back_order_length
    , pa.peer_avg_back_order_length
    , least(coalesce(pa.peer_avg_back_order_length, 1000000000000), 14) as back_order_length_target
    , iff(((back_order_length_target / a.vendor_avg_back_order_length) * (1/14)) > (1/14), (1/14), (back_order_length_target / a.vendor_avg_back_order_length) * (1/14)) as back_order_score
    , iff(((back_order_length_target / a.vendor_avg_back_order_length) * 10) > 10, 10, (back_order_length_target / a.vendor_avg_back_order_length) * 10 ) as back_order_score10
from agg a
join "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
    on primary_vendor ilike 'yes'
        and v.mapped_vendor_name = a.mapped_vendor_name
left join peer_avg pa
    on pa.vendorid = v.vendorid;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }
  dimension: vendor_avg_back_order_length {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.vendor_avg_back_order_length ;;
  }
  dimension: peer_avg_back_order_length {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peer_avg_back_order_length ;;
  }
  dimension: graded_target {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.back_order_length_target ;;
  }
  dimension: back_order_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.back_order_score, 0) ;;
  }
  dimension: back_order_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.back_order_score10, 0) ;;
  }
}
