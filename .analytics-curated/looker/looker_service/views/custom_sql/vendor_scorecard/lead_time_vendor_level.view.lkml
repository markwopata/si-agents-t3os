view: lead_time_vendor_level {
derived_table: {
  sql:with
    all_pos_prep as ( --need to pull in who received it
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
            , coalesce(p2.part_id, p.part_id) as the_part_id
            , coalesce(p2.part_number, p.part_number) as the_part_number
            , pt.description
            , pr.name provider
            , e.name vendor
            , evs.entity_id as vendor_id
            , p.item_id
            , li.purchase_order_line_item_id
            , r.purchase_order_receiver_id
        from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
        left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
            on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
        join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
            on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
        join "ES_WAREHOUSE"."INVENTORY"."PARTS" p
            on li.item_id = p.item_id
        left join ES_WAREHOUSE.INVENTORY.PARTS p2
            on p.DUPLICATE_OF_ID = p2.PART_ID
        left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
            on coalesce(p2.provider_id, p.provider_id) = pr.provider_id
        join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
            on coalesce(p2.part_type_id, p.part_type_id) = pt.PART_TYPE_ID
        join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
            on r.purchase_order_id=po.purchase_order_id
        left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" e
            on po.vendor_ID = e.entity_ID
        left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
            on il.inventory_location_id = r.store_id
        join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
            on m.market_id = il.branch_id
        where
            po.purchase_order_number != 321858 --obvious mistake
            and to_date(po.date_created) >= '2021-01-01' --looking to 2021 for historical lead time, will calc avg in next cte
            and lead_time >=0  --this is cleaning up where PO created date is after received date due to manual receptions
            and ri.created_by_id != 21758 --this is eric prieto correcting POs for cost/quantities, but we want the og reception date
            and ri.accepted_quantity > 0 --Parts that were actually received
            and po.status!= 'ARCHIVED'
            and m.region_name is not null
            and il.company_id = 1854

            and po.date_archived is null
            and li.date_archived is null
    )

    , eliminate_partial_deliveries as ( --Pulling total quantity accepted per line item and the max lead time to get the latest delivery.
    select max(lead_time) as max_lead_time
    , sum(accepted_quantity) as total_accepted
    , purchase_order_line_item_id
    from all_pos_prep
    group by purchase_order_line_item_id
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
    , app.vendor_id
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
    , app.vendor_id
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
    , vendor_id
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


    , lead_time_2023_pre AS (--Pulls po data for 2023 by part and market, if unavailable then back to 2021
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
    , vendor_id
    , item_id
    , purchase_order_line_item_id

    from po_23_check

    union

    select *
    from po_23
    )

    , lead_time_2023 as (
    SELECT *,
    CASE WHEN date_created <= GETDATE() AND date_created > (DATEADD(DAY, -30, GETDATE())) THEN 30
    ELSE 0
    END AS days_30_60
    FROM lead_time_2023_pre
    )

    SELECT
    external_erp_vendor_ref as vendorid,
    e.name as vendor_name,
    lt.date_created,
    lt.date_received,
    days_30_60,
    lead_time
    FROM lead_time_2023 lt
    left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" e
    on lt.vendor_ID = e.entity_ID
    left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
    on e.entity_ID = evs.entity_ID
    GROUP BY external_erp_vendor_ref, e.name, lt.date_created, lt.date_received, days_30_60, lead_time
    order by external_erp_vendor_ref
    ;;
}

dimension: vendorid {
  type: string
  primary_key: yes
  sql: ${TABLE}.vendorid ;;
}

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.date_created ;;
  }

  dimension: date_received {
    type: date
    sql: ${TABLE}.date_received ;;
  }

  dimension: lead_time {
    type: number
    sql: ${TABLE}.lead_time ;;
  }

  dimension: days_30_60 {
    type: number
    sql: ${TABLE}.days_30_60 ;;
  }

  measure: days_30_avg_lead {
    type: average
    filters: [days_30_60: "0"]
    value_format: "0"
    sql: ${TABLE}.lead_time ;;
  }

  measure: avg_lead {
    type: average
    value_format: "0"
    sql: ${TABLE}.lead_time ;;
  }

}
