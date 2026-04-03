with inv_stores as (
    select * from {{ ref('stg_es_warehouse_inventory__stores') }}
),

receipts as (
    select * from {{ ref('stg_procurement_public__purchase_order_receivers') }}
),

orders as (
    select * from {{ ref('stg_procurement_public__purchase_orders') }}
),

vendor as (
    select * from {{ ref('stg_analytics_intacct__vendor') }}
),

parent_branch as (
    select
        str1.store_id,
        coalesce(str1.branch_id, str2.branch_id) as parent_branch_id
    from inv_stores as str1
        left join inv_stores as str2 on str1.parent_id = str2.store_id
    where str1.company_id = 1854
),

-- determines the suffix of the po number (does not exclude adjustments).
-- if the rank of the date received for each po is 1, there will be no suffix.
-- otherwise, it will return '-2','-3',...etc
suffix as (
    select
        r.purchase_order_receiver_id,
        r.purchase_order_id,
        r.date_created,
        r.receiver_type,
        p.purchase_order_number,
        case
            when row_number() over (partition by r.purchase_order_id order by r.date_created asc) > 1
                then concat('-', (row_number() over (partition by r.purchase_order_id order by r.date_created asc)))
            else ''
        end as suffix,
        concat(p.purchase_order_number, suffix) as final_po_number
    from receipts as r
        left join orders as p on r.purchase_order_id = p.purchase_order_id
    where r.date_created >= '2023-10-16'
)

select
    poh.purchase_order_number as cc_po_number,
    suffix.final_po_number as intacct_po_number,
    prh.purchase_order_receiver_id,
    prh.purchase_order_id,
    prl.fk_t3_purchase_order_receiver_item_id,
    prh.store_id as received_to_store,
    store_branch.intacct_department_id as intacct_dept_from_store,
    d1.department_name as intacct_dept_name_from_store,
    d1.department_status as intacct_dept_status_from_store,
    poh.requesting_branch_id as order_branch_id,
    po_branch.intacct_department_id as intacct_dept_from_po_branch,
    d2.department_name as intacct_dept_name_from_po_branch,
    d2.department_status as intacct_dept_status_from_po_branch,
    case
        when itm.item_type = 'INVENTORY'
            then coalesce(store_branch.intacct_department_id, to_char(trunc(pb.parent_branch_id, 0)))
        else coalesce(po_branch.intacct_department_id, to_char(trunc(poh.requesting_branch_id, 0)))
    end as final_department_id,
    cast(convert_timezone('America/Chicago', prh.date_received) as date) as pr_date_received,
    cast(convert_timezone('America/Chicago', prh.date_created) as date) as pr_date_created,
    poh.vendor_id as cc_vendor_id,
    coalesce(vend_redirect.vendor_redirect, vend.external_erp_vendor_ref) as vendor_id,
    vendint.vendor_name,
    vendint.vendor_status,
    vendint.vendor_term,
    coalesce(nullif(returntocontact.contact_name, ''), contact.contact_name) as returnto_contactname,
    coalesce(nullif(paytocontact.contact_name, ''), contact.contact_name) as payto_contactname,
    left(poh.reference, 118) as referenceno,
    itm.item_type,
    p.part_number,
    p.description as part_name,
    p.search as full_part_description,
    p.part_id,
    ninv.name as non_inv_item,
    case
        when itm.item_type = 'INVENTORY' then 'A1301'
        when itm.item_type = 'NON_INVENTORY' then left(ninv.name, 5)
    end as item_id,
    left(pol.purchase_order_line_description, 254) as memo,
    prl.accepted_quantity,
    prl.rejected_quantity,
    prl.price_per_unit,
    concat(poh.created_by_id, ' - ', user1.first_name, ' ', user1.last_name) as t3_po_created_by,
    concat(prh.created_by_id, ' - ', user2.first_name, ' ', user2.last_name) as t3_pr_created_by,
    poh.url_t3 as t3_po_url
--receipt headers
from receipts as prh
    --receipt lines
    left join {{ ref('stg_procurement_public__purchase_order_receiver_items') }} as prl
        on prh.purchase_order_receiver_id = prl.purchase_order_receiver_id
    --order headers
    left join orders as poh on prh.purchase_order_id = poh.purchase_order_id
    --order lines
    left join {{ ref('stg_procurement_public__purchase_order_line_items') }} as pol
        on prl.purchase_order_line_item_id = pol.purchase_order_line_item_id
    --add suffix for the po number (see cte)
    left join suffix on prh.purchase_order_receiver_id = suffix.purchase_order_receiver_id
    --user info for order header creator
    left join {{ ref('stg_es_warehouse_public__users') }} as user1 on poh.created_by_id = user1.user_id
    --user info for receipt creator
    left join {{ ref('stg_es_warehouse_public__users') }} as user2 on prh.created_by_id = user2.user_id
    --bring in item type (inventory / non-inventory / service)
    left join {{ ref('stg_procurement_public__items') }} as itm on pol.item_id = itm.item_id
    --item ids and descriptions for non_inventory (i.e. a6320 - temporary labor)
    left join {{ ref('stg_procurement_public__non_inventory_items') }} as ninv on pol.item_id = ninv.item_id
    --parts
    left join {{ ref('stg_es_warehouse_inventory__parts') }} p on pol.item_id = p.item_id and p.company_id = 1854
    --these joins pull the branch on the store id of the receipt or the parent of the store id then map that 
    --branch id to the erp department id and brings in intacct settings for that department
    left join parent_branch as pb on prh.store_id = pb.store_id
    left join {{ ref('stg_es_warehouse_public__branch_erp_refs') }} as store_branch
        on pb.parent_branch_id = store_branch.branch_id
    left join {{ ref('stg_analytics_intacct__department') }} as d1
        on store_branch.intacct_department_id = d1.department_id
    --maps branch from the po to the erp department id and brings in intacct settings for that department
    left join {{ ref('stg_es_warehouse_public__branch_erp_refs') }} as po_branch
        on poh.requesting_branch_id = po_branch.branch_id
    left join {{ ref('stg_analytics_intacct__department') }} as d2
        on po_branch.intacct_department_id = d2.department_id
    --map vendor ids to sage vendor ids, some vendor ids are redirected to others so vend_redirect checks this first
    left join {{ ref('stg_es_warehouse_purchases__entity_vendor_settings') }} as vend
        on poh.vendor_id = vend.entity_id
    left join vendor as vend_redirect on vend.external_erp_vendor_ref = vend_redirect.vendor_id
    --joins on the vendor_id redirected to first and if null, just joins on the mapped vendor_id
    left join vendor as vendint
        on coalesce(vend_redirect.vendor_redirect, vend.external_erp_vendor_ref) = vendint.vendor_id
    --this join is necessary because sometimes the display contact name is not shown on the vendor record, 
    --instead a display_contact_key is specified
    left join {{ ref('stg_analytics_intacct__contact') }} as contact
        on vendint.display_contact_key = contact.pk_contact_id
    left join {{ ref('stg_analytics_intacct__contact') }} as paytocontact
        on vendint.pay_to_key = paytocontact.pk_contact_id
    left join {{ ref('stg_analytics_intacct__contact') }} as returntocontact
        on vendint.return_to_key = returntocontact.pk_contact_id
where 1 = 1
    --only 1854 (equipmentshare internal)
    and poh.company_id = 1854
    --exclude receipt adjustments
    and prh.receiver_type = 'RECEIPT'
    --exclude receipts created before live accruals
    and prh.date_created >= '2023-10-16'
    --exclude null fk_t3_purchase_order_receiver_item_id (seems to be related to timing)
    and prl.fk_t3_purchase_order_receiver_item_id is not null
