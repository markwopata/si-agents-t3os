with

    source_data as (
        select
            po.date_created as purchase_order_date_created,
            po.requesting_branch_id,
            po.created_by_id,
            po.status as purchase_order_status,
            po.purchase_order_number,
            po.reference purchase_order_reference,
            po.purchase_order_id,

            li.quantity as purchase_order_line_items_quantity,
            li.price_per_unit as purchase_order_line_items_price_per_unit,

            it.item_type,

            u.first_name,
            u.last_name,

            m.name as market_name,
            m.company_id as market_company_id,

            mrx.region_name as market_region_xwalk_region_name,
            mrx.district as market_region_xwalk_district_name,
            mrx.market_type as market_type, 

            e.name as purchase_entity_name,

            tvm.preferred as top_vendor_mapping_preferred,

            max(r.date_received) as purchase_order_receivers_date_received,

            case
                when it.item_type = 'INVENTORY'
                then 'A1301 - Equipment Parts Inventory'
                when it.item_type = 'NON_INVENTORY'
                then nit.name
            end as item_service

        from {{ ref("platform", "procurement_purchase_orders") }} po
        left join
            {{ ref("platform", "purchase_order_line_items") }} li
            on po.purchase_order_id = li.purchase_order_id
        left join {{ ref("platform", "items") }} it on it.item_id = li.item_id
        left join
            {{ ref('platform', 'es_warehouse__public__markets') }} m
            on m.market_id = po.requesting_branch_id
        left join
            {{ source("analytics__public", "market_region_xwalk") }} mrx
            on mrx.market_id = m.market_id
        left join
            {{ ref("platform", "es_warehouse__public__users") }} u
            on u.user_id = po.created_by_id
        left join
            {{ ref("platform", "non_inventory_items") }} nit on nit.item_id = li.item_id
        left join {{ ref("platform", "entities") }} e on po.vendor_id = e.entity_id
        left join
            {{ ref("platform", "entity_vendor_settings") }} vend
            on po.vendor_id = vend.entity_id
        left join
            {{ source("analytics__parts_inventory", "top_vendor_mapping") }} tvm
            on tvm.vendorid = vend.external_erp_vendor_ref
        left join
            {{ ref("platform", "purchase_order_receiver_items") }} ri
            on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
        left join
            {{ ref("platform", "purchase_order_receivers") }} r
            on r.purchase_order_receiver_id = ri.purchase_order_receiver_id

        where
            po.date_archived is null
            and it.date_archived is null
            and li.date_archived is null

        group by all

    )
select
    purchase_order_date_created,
    requesting_branch_id,
    created_by_id,
    purchase_order_status,
    purchase_order_number,
    purchase_order_reference,
    purchase_order_id,
    purchase_order_line_items_quantity,
    purchase_order_line_items_price_per_unit,
    item_type,
    first_name,
    last_name,
    market_name,
    market_company_id,
    market_region_xwalk_region_name,
    market_region_xwalk_district_name,
    market_type,
    purchase_entity_name,
    top_vendor_mapping_preferred,
    purchase_order_receivers_date_received,
    item_service
from source_data
