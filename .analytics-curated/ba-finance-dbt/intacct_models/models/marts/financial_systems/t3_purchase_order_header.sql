with purchase_orders as (
    select * from {{ ref('int_procurement_public_purchase_orders_1854') }}
),

entity_vendor_settings as (
    select * from {{ ref('stg_es_warehouse_purchases__entity_vendor_settings') }}
),

users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
)

select
    po.purchase_order_id                           as t3_po_id,
    po.date_created                                as t3_date_created,
    po.date_updated                                as t3_date_updated,
    po.vendor_id                                   as t3_vendor_id,
    evs.external_erp_vendor_ref                    as sage_vendor_id,
    po.purchase_order_number                       as t3_po_number,
    po.created_by_id                               as t3_created_by_id,
    po.modified_by_id                              as t3_modified_by_id,
    concat(user1.first_name, ' ', user1.last_name) as t3_po_created_by,
    concat(user2.first_name, ' ', user2.last_name) as t3_po_modified_by,
    concat(user1.email_address)                    as t3_po_created_by_email,
    po.reference                                   as t3_reference,
    po.requesting_branch_id                        as t3_requesting_branch_id,
    po.deliver_to_id                               as t3_deliver_to_id,
    po.status                                      as t3_status,
    po.promise_date                                as t3_promise_date,
    po.external_po_id                              as t3_external_po_id,
    po.is_external                                 as t3_is_external,
    po._es_update_timestamp                        as t3_update_timestamp,
    po.date_archived                               as t3_date_archived,
    po.amount_approved                             as t3_amount_approved,
    po.store_id                                    as t3_store_id,
    po.search                                      as t3_search
from
    purchase_orders po
    left join entity_vendor_settings evs on po.vendor_id = evs.entity_id
    left join users user1 on po.created_by_id = user1.user_id
    left join users user2 on po.modified_by_id = user2.user_id
where po.company_id = 1854