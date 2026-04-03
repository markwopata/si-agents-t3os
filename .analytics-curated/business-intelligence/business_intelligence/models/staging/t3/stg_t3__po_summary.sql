{{ config(
    materialized='table'
    , cluster_by=['date_created']
) }}

with
po_summary as (
        select
        po.purchase_order_id,
        po.purchase_order_number,
        po.reference,
        po.status,
        po.promise_date,
        po.date_created,
        du.user_full_name as created_by,
        e.name as vendor,
        coalesce(tvm.preferred, 'No') as preferred,
        dm.market_name as cost_center,
        dm.market_region_name as region_name,
        dm.market_district as district,
        dm.market_type,
        it.item_type,
        li.description as line_item_description,
        li.quantity,
        li.price_per_unit,
        dm.market_id,
        dm.market_company_id as company_id,
        sum(li.quantity * li.price_per_unit) as total_po_cost,
        case
            when it.item_type = 'INVENTORY'
            then 'A1301 - Equipment Parts Inventory'
            when it.item_type = 'NON_INVENTORY'
            then nit.name
        end as item_service,
        max(r.date_received) as date_received,
        case
            when it.item_type = 'INVENTORY'
            then p.part_number
            else 'Non-Inventory Item'
        end as part_number,
        dm.market_branch_earnings_start_month as branch_earnings_start_month
        from {{ ref("platform", "purchase_order_line_items") }} as li
        inner join
            {{ ref("platform", "procurement_purchase_orders") }} as po
            on li.purchase_order_id = po.purchase_order_id
        left join
            {{ ref("platform", "dim_markets") }} as dm
            on po.requesting_branch_id = dm.market_id
        left join {{ ref("platform", "entities") }} as e on po.vendor_id = e.entity_id
        left join {{ ref('platform', 'entity_vendor_settings') }} evs
            on evs.entity_id = e.entity_id
        left join {{ source("analytics__parts_inventory", "top_vendor_mapping") }} tvm
            on evs.external_erp_vendor_ref = tvm.vendorid
        left join {{ ref("platform", "dim_users") }} as du on po.created_by_id = du.user_id
        left join {{ ref("platform", "items") }} as it on li.item_id = it.item_id
        left join
            {{ ref("platform", "non_inventory_items") }} as nit
            on li.item_id = nit.item_id
        left join
            {{ ref("platform", "purchase_order_receiver_items") }} as ri
            on li.purchase_order_line_item_id = ri.purchase_order_line_item_id
        left join
            {{ ref("platform", "purchase_order_receivers") }} as r
            on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
        left join {{ ref("platform", "parts") }} as p on li.item_id = p.item_id
        where
            po.date_archived is null
            and it.date_archived is null
            and li.date_archived is null
        group by
            po.purchase_order_id,
            po.purchase_order_number,
            po.reference,
            po.status,
            po.promise_date,
            po.date_created,
            du.user_full_name,
            e.name,
            tvm.preferred,
            dm.market_name,
            dm.market_region_name,
            dm.market_district,
            dm.market_type,
            it.item_type,
            li.description,
            li.quantity,
            dm.market_id,
            dm.market_company_id,
            li.price_per_unit,
            nit.name,
            p.part_number,
            dm.market_branch_earnings_start_month
    )
select distinct
    case
        when date_created < DATEADD('day', -59, CURRENT_DATE())
          and date_received < DATEADD('day', -59, CURRENT_DATE()) then 'Over_60_Both'
        when date_created < DATEADD('day', -59, CURRENT_DATE()) then 'Over_60_Created'
        when date_received < DATEADD('day', -59, CURRENT_DATE()) then 'Over_60_Received'
        else 'filtered_pos'
    end as po_list_select_flag,
    purchase_order_id,
    purchase_order_number,
    reference,
    status,
    promise_date,
    date_created,
    created_by,
    vendor,
    preferred,
    cost_center,
    region_name,
    market_type,
    district,
    item_type,
    line_item_description,
    quantity,
    price_per_unit,
    market_id,
    company_id,
    total_po_cost,
    item_service,
    date_received,
    part_number,
    branch_earnings_start_month
from po_summary
