{{ config(
    materialized='table'
    , cluster_by=['company_id', 'date_created']
) }}

with
    po_approval as (
        select
            po.purchase_order_id,
            po.purchase_order_number,
            po.date_created,
            po.created_by_id as requesting_user_id,
            po.requesting_branch_id as market_id,
            po_amount.purchase_order_amount,
            array_agg(
                distinct coalesce(mal.group_name, ral.group_name, cal.group_name)
            ) as approver_group,
            array_agg(
                distinct coalesce(mal.user_id, ral.user_id, cal.user_id)
            ) as approver_user_id
        from {{ ref("platform", "procurement_purchase_orders") }} po
        left join
            (
                select
                    purchase_order_id,
                    sum(quantity * price_per_unit) as purchase_order_amount
                from {{ ref("platform", "purchase_order_line_items") }}
                where date_archived is null
                group by purchase_order_id
            ) po_amount
            on po.purchase_order_id = po_amount.purchase_order_id
        left join
            {{ ref("int_policy_grants") }} mal
            on po.requesting_branch_id = mal.market_id
            and po_amount.purchase_order_amount
            <= coalesce(mal.group_spending_limit, mal.role_spending_limit)
            and (
                mal.permission_granted_by_level = 'Branch'
                or mal.branch_level_access = 'YES'
            )
        left join
            {{ ref("int_policy_grants") }} ral
            on po.requesting_branch_id = ral.market_id
            and po_amount.purchase_order_amount
            <= coalesce(ral.group_spending_limit, ral.role_spending_limit)
            and ral.permission_granted_by_level = 'Region'
        left join
            {{ ref("int_policy_grants") }} cal
            on po.requesting_branch_id = cal.market_id
            and po_amount.purchase_order_amount
            <= coalesce(cal.group_spending_limit, cal.role_spending_limit)
            and cal.permission_granted_by_level = 'Company'
        group by
            po.purchase_order_id,
            po.purchase_order_number,
            po.date_created,
            po.created_by_id,
            po.requesting_branch_id,
            po_amount.purchase_order_amount
    ),
    approver_list as (
        select
            poa.purchase_order_id,
            poa.purchase_order_number,
            poa.date_created,
            poa.requesting_user_id,
            poa.market_id,
            poa.purchase_order_amount,
            a.value as approver_id,
            e.name as vendor,
            e.entity_id,
            coalesce(tvm.preferred, 'No') as preferred,
            po.status,
            po.company_id
        from po_approval poa
        join
            {{ ref("platform", "procurement_purchase_orders") }} po
            on po.purchase_order_id = poa.purchase_order_id
        left join {{ ref("platform", "entities") }} e on po.vendor_id = e.entity_id
        left join {{ ref('platform', 'entity_vendor_settings') }} evs
            on evs.entity_id = e.entity_id
        left join {{ source("analytics__parts_inventory", "top_vendor_mapping") }} tvm
            on evs.external_erp_vendor_ref = tvm.vendorid,
            lateral flatten(input => approver_user_id) a
        where
            a.value <> 0
            and requesting_user_id <> a.value
    )
select
    al.*,
    dm.market_name as cost_center,
    dm.market_region_name as region_name,
    dm.market_district as district,
    dm.market_type,
    dm.market_branch_earnings_start_month as branch_earnings_start_month,
    pg.group_name as approver_group,
    coalesce(role_spending_limit, group_spending_limit) as approver_spending_limit
from approver_list al
join
    {{ ref("int_policy_grants") }} pg
    on pg.market_id = al.market_id
    and pg.user_id = al.approver_id
left join {{ ref("platform", "dim_markets") }} dm on dm.market_id = al.market_id
