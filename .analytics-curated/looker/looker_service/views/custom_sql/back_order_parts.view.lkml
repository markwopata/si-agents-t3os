view: back_order_parts {
derived_table: {
  sql:
    select coalesce(xw.MARKET_ID, ma.market_id)               as the_market_id
        , coalesce(xw.MARKET_NAME, ma.NAME)                   as the_market_name
        , coalesce(xw._id_dist, ma.district_id)               as the_district_id
        , coalesce(xw.DISTRICT, d.name)                       as the_district_name
        , coalesce(xw.REGION, d.REGION_ID)                    as the_region_id
        , coalesce(xw.REGION_NAME, reg.name)                  as the_region_name
        , po.purchase_order_number
        , li.purchase_order_line_item_id
        , listagg(ri.purchase_order_receiver_item_id, ' / ') as PURCHASE_ORDER_RECEIVER_ITEM_ID
        , po.date_created
        , datediff(days, po.date_created, current_date) days_since_order
        , li.quantity as q_ordered
        , sum(zeroifnull(ri.accepted_quantity)) as a_quant
        , sum(zeroifnull(ri.rejected_quantity)) as r_quant
        , li.quantity - a_quant - r_quant as total_on_order
        , li.price_per_unit
        , total_on_order * li.price_per_unit as value_on_order
        , p.master_part_id as the_part_id
        , p.part_number as the_part_number
        , pr.name as provider_name
        , pr.provider_id
        , pt.description
        , max(r.date_received) date_received
        , po.purchase_order_id
        , ent.name as vendor_name
        , evs.EXTERNAL_ERP_VENDOR_REF as vendorid
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
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
        on po.REQUESTING_BRANCH_ID = xw.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.MARKETS ma
        on po.REQUESTING_BRANCH_ID = ma.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.DISTRICTS d
        on ma.DISTRICT_ID = d.DISTRICT_ID
    left join ES_WAREHOUSE.PUBLIC.REGIONS reg
        on d.REGION_ID = reg.REGION_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITIES" ent
        on po.VENDOR_ID = ent.ENTITY_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
        on ent.entity_ID = evs.entity_ID
    where days_since_order >= 7 --changing from 10 to 7 per alistair (procurement) -HH 11/22/24
        and po.status = 'OPEN'
        and po.date_archived is null
        and li.date_archived is null
        and ma.company_id = 1854
    group by the_market_id
        , the_market_name
        , the_district_id
        , the_district_name
        , the_region_id
        , the_region_name
        , po.purchase_order_number
        , po.date_created
        , li.quantity
        , the_part_id
        , the_part_number
        , pt.description
        , provider_name
        , pr.provider_id
        , li.purchase_order_line_item_id
        , li.price_per_unit
        , po.purchase_order_id
        , ent.name
        , evs.EXTERNAL_ERP_VENDOR_REF
    having total_on_order > 0
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
  value_format_name: usd
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

dimension: provider_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.provider_id ;;
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
                   part_id,
                   part_number,
                   description,
                   price_per_unit,
                   sum_total_on_order,
                   po_number_link,
                  part_back_order_requests_board.vendor_updates,
                   days_since_order,
                   back_order_work_orders_listed.make_2,
                   back_order_work_orders_listed.model_2,
                   assets_aggregate.oec,
                  assets_aggregate.serial_number,
                   daily_rev_calculation.time_utilization,
                   market_region_xwalk.market_name,
                  market_region_xwalk.region_name,
                   work_orders.work_order_id,
                   work_orders.asset_id,
                   work_orders.severity_level_name,
                  part_back_order_requests_board.equipment_priority,
                   unreceived_pos.invoices_listed
                  ]
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
