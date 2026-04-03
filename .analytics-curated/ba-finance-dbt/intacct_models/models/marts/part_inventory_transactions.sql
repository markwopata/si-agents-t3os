with transactions_combined as (
-- Negative transactions (reducing inventory)
    select
        il.store_id,
        il.store_name,
        --coalesce(il.parent_id, il.store_id)   parent_store_id,
        m.market_id,
        m.market_name,
        tt.transaction_type_id,
        tt.transaction_type,
        mar.manual_adjustment_reason_id,
        mar.manual_adjustment_reason,
        ts.transaction_status,
        -ti.quantity_received as quantity,
        spc.cost,
        -ti.quantity_received * spc.cost as amount,
        wac.weighted_average_cost,
        -ti.quantity_received * wac.weighted_average_cost as wac_extended_amount,
        sp.store_part_id,
        spc.store_part_cost_id,
        p.part_id,
        p.part_number,
        p.description,
        p.root_part_id,
        p.root_part_number,
        p.root_part_description,
        t.from_id,
        t.to_id,
        ti.cost_per_item, -- Choosing to not trust this cost at this time
        u.user_id as created_by_user_id,
        u.username as created_by_username,
        u_m.user_id as updated_by_user_id,
        u_m.username as updated_by_user_name,
        t.transaction_id,
        ti.transaction_item_id,
        ti.wac_snapshot_id,
        t.memo,
        t.custom_id,
        t.from_uuid_id,
        t.to_uuid_id,
        t.split_from,
        t.transaction_group_id,
        t.date_completed,
        t.date_cancelled,
        ti.quantity_ordered,
        ti.date_created,
        date_trunc('month', t.date_completed) as month_,
        iff(t.transaction_type_id = 7, t.to_id, null) as work_order_id,
        iff(t.transaction_type_id = 22, t.to_uuid_id, null)
            as purchase_order_id,
        iff(t.transaction_type_id in (3, 13), t.to_id, null) as invoice_id,
        iff(t.transaction_type_id = 10, t.to_id, null) as rental_id,
        case
            when t.transaction_type_id = 7 -- Store to Work Order
                then
                    'https://app.estrack.com/#/service/work-orders/'
                    || t.to_id::STRING
            when t.transaction_type_id = 22 -- Store to Purchase Order
                then
                    'https://costcapture.estrack.com/purchase-orders/'
                    || t.to_uuid_id
                    || '/detail'
        end as url_t3,
        case
            when t.transaction_type_id = 10 -- Store to Rental
                then
                    'https://admin.equipmentshare.com/#/home/rentals/'
                    || t.to_id::TEXT
            when t.transaction_type_id = 3 -- Store to Retail Sale
                then
                    'https://admin.equipmentshare.com/#/home/transactions/invoices/'
                    || t.to_id::TEXT
            when t.transaction_type_id = 13 -- Store to Rental Retail Sale
                then
                    'https://admin.equipmentshare.com/#/home/transactions/invoices/'
                    || t.to_id::TEXT
        end as url_admin,
        'negatives' as src,
        ti.transaction_item_id::TEXT
        || '-'
        || src as pk_part_inventory_transactions_id,
        ma.manual_adjustment_id
    from {{ ref("stg_es_warehouse_inventory__transactions") }} as t
        inner join {{ ref('stg_es_warehouse_inventory__transaction_items')}} as ti
            on t.transaction_id = ti.transaction_id
        inner join {{ ref("stg_es_warehouse_inventory__transaction_types") }} as tt
            on t.transaction_type_id = tt.transaction_type_id
        inner join {{ ref("stg_es_warehouse_inventory__transaction_statuses") }} as ts
            on t.transaction_status_id = ts.transaction_status_id
        inner join {{ ref("stg_parts") }} as p
            on ti.part_id = p.part_id
        inner join {{ ref("stg_es_warehouse_inventory__inventory_locations") }} as il
            on t.from_id = il.store_id
        --left join {{ ref("stg_es_warehouse_inventory__inventory_locations") }} ps -- Parent store
        --          on s.PARENT_ID = ps.STORE_ID
        inner join {{ ref("stg_es_warehouse_public__markets") }} as m
            on il.market_id = m.market_id
        --on coalesce(s.branch_id, ps.branch_id) = m.market_id
        -- Left join goes against the basic understood principle that every store + part should have a store_part
        left join {{ ref("stg_es_warehouse_inventory__store_parts") }} as sp
            on
                il.store_id = sp.store_id
                and sp.part_id = coalesce(p.root_part_id, p.part_id)
                and sp.date_archived is null
        -- Left join goes against the basic understood principle that every store + part should have a store_part_cost
        left join {{ ref("stg_store_part_costs") }} as spc
            on
                sp.store_part_id = spc.store_part_id
                and t.date_created >= spc.date_start
                and t.date_created < spc.date_end
        inner join {{ ref("stg_es_warehouse_public__users") }} as u
            on ti.created_by = u.user_id
        inner join {{ ref("stg_es_warehouse_public__users") }} as u_m
            on ti.modified_by = u_m.user_id
        inner join {{ ref('stg_analytics_public__es_companies') }} as ec
            on
                t.company_id = ec.company_id
                and ec.owned
        left join {{ ref("stg_es_warehouse_inventory__manual_adjustments") }} as ma
            on ti.transaction_item_id = ma.transaction_item_id
        left join {{ ref("stg_es_warehouse_inventory__manual_adjustment_reasons") }} as mar
            on ma.reason_id = mar.manual_adjustment_reason_id
        left join {{ ref("stg_weighted_average_cost") }} as wac
            on
                il.store_id = wac.inventory_location_id
                and coalesce(p.root_part_id, p.part_id) = wac.product_id
                and t.date_completed >= wac.date_start
                and t.date_completed < wac.date_end
    where tt.transaction_type ilike 'Store to%'

    union all

    -- Positive transactions (Increasing inventory)
    select
        il.store_id,
        il.store_name,
        --coalesce(il.parent_id, il.inventory_location_id) parent_store_id,
        m.market_id,
        m.market_name,
        tt.transaction_type_id,
        tt.transaction_type,
        mar.manual_adjustment_reason_id,
        mar.manual_adjustment_reason,
        ts.transaction_status,
        ti.quantity_received as quantity,
        spc.cost,
        ti.quantity_received * spc.cost as amount,
        wac.weighted_average_cost,
        ti.quantity_received * spc.cost as wac_extended_amount,
        sp.store_part_id,
        spc.store_part_cost_id,
        p.part_id,
        p.part_number,
        p.description,
        p.root_part_id,
        p.root_part_number,
        p.root_part_description,
        t.from_id,
        t.to_id,
        ti.cost_per_item, -- Choosing to not trust this cost at this time
        u.user_id as created_by_user_id,
        u.username as created_by_user_name,
        u_m.user_id as updated_by_user_id,
        u_m.username as updated_by_user_name,
        t.transaction_id,
        ti.transaction_item_id,
        ti.wac_snapshot_id,
        t.memo,
        t.custom_id,
        t.from_uuid_id,
        t.to_uuid_id,
        t.split_from,
        t.transaction_group_id,
        t.date_completed,
        t.date_cancelled,
        ti.quantity_ordered,
        ti.date_created,
        date_trunc('month', t.date_completed) as month_,
        iff(t.transaction_type_id = 9, t.from_id, null) as work_order_id,
        iff(t.transaction_type_id = 21, t.from_uuid_id, null)
            as purchase_order_id,
        iff(t.transaction_type_id in (4), t.from_id, null) as invoice_id,
        iff(t.transaction_type_id = 11, t.from_id, null) as rental_id,
        case
            when t.transaction_type_id = 9 -- Work Order to Store
                then
                    'https://app.estrack.com/#/service/work-orders/'
                    || t.from_id::STRING
            when t.transaction_type_id = 21 -- Purchase Order to Store
                then
                    'https://costcapture.estrack.com/purchase-orders/'
                    || t.from_uuid_id
                    || '/detail'
        end as url_t3,
        case
            when t.transaction_type_id = 11 -- Rental to Store
                then
                    'https://admin.equipmentshare.com/#/home/rentals/'
                    || t.from_id::TEXT
            when t.transaction_type_id = 4 -- Retail Sale to Store
                then
                    'https://admin.equipmentshare.com/#/home/transactions/invoices/'
                    || t.from_id::TEXT
        end as url_admin,
        'positives' as src,
        ti.transaction_item_id::TEXT
        || '-'
        || src as pk_part_inventory_transactions_id,
        ma.manual_adjustment_id
    from {{ ref("stg_es_warehouse_inventory__transactions") }} as t
        inner join {{ ref('stg_es_warehouse_inventory__transaction_items') }} as ti
            on t.transaction_id = ti.transaction_id
        inner join {{ ref("stg_es_warehouse_inventory__transaction_types") }} as tt
            on t.transaction_type_id = tt.transaction_type_id
        inner join {{ ref("stg_es_warehouse_inventory__transaction_statuses") }} as ts
            on t.transaction_status_id = ts.transaction_status_id
        inner join {{ ref("stg_parts") }} as p
            on ti.part_id = p.part_id
        inner join {{ ref("stg_es_warehouse_inventory__inventory_locations") }} as il
            on t.to_id = il.store_id
        --left join {{ ref("stg_es_warehouse_inventory__inventory_locations") }} ps -- Parent store
        --          on s.PARENT_ID = ps.STORE_ID
        inner join {{ ref("stg_es_warehouse_public__markets") }} as m
            on il.market_id = m.market_id
        --on coalesce(s.branch_id, ps.branch_id) = m.market_id
        -- Left join goes against the basic understood principle that every store + part should have a store_part
        left join {{ ref("stg_es_warehouse_inventory__store_parts") }} as sp
            on
                il.store_id = sp.store_id
                and sp.part_id = coalesce(p.root_part_id, p.part_id)
                and sp.date_archived is null
        -- Left join goes against the basic understood principle that every store + part should have a store_part_cost
        left join {{ ref("stg_store_part_costs") }} as spc
            on
                sp.store_part_id = spc.store_part_id
                and t.date_created >= spc.date_start
                and t.date_created < spc.date_end
        inner join {{ ref("stg_es_warehouse_public__users") }} as u
            on ti.created_by = u.user_id
        inner join {{ ref("stg_es_warehouse_public__users") }} as u_m
            on ti.modified_by = u_m.user_id
        inner join {{ ref('stg_analytics_public__es_companies') }} as ec
            on
                t.company_id = ec.company_id
                and ec.owned
        left join {{ ref("stg_es_warehouse_inventory__manual_adjustments") }} as ma
            on ti.transaction_item_id = ma.transaction_item_id
        left join {{ ref("stg_es_warehouse_inventory__manual_adjustment_reasons") }} as mar
            on ma.reason_id = mar.manual_adjustment_reason_id
        left join {{ ref("stg_weighted_average_cost") }} as wac
            on
                il.store_id = wac.inventory_location_id
                and coalesce(p.root_part_id, p.part_id) = wac.product_id
                and t.date_completed >= wac.date_start
                and t.date_completed < wac.date_end
    where tt.transaction_type ilike '% to Store'
)

select *
from transactions_combined
