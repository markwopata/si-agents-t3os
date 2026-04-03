with t3_po_header as (
    select * from {{ ref('t3_purchase_order_header') }}
),

purchase_order_line_items as (
    select * from {{ ref('stg_procurement_public__purchase_order_line_items') }}
),

items as (
    select * from {{ ref('stg_procurement_public__items') }}
),

non_inventory_items as (
    select * from {{ ref('stg_procurement_public__non_inventory_items') }}
),

parts as (
    select * from {{ ref('stg_es_warehouse_inventory__parts') }}
),

providers as (
    select * from {{ ref('stg_es_warehouse_inventory__providers') }}
)

select
    t3h.t3_po_id                             as fk_t3_po_header_key,
    poli.purchase_order_line_item_id         as t3_po_line_key,
    row_number() 
    over (
      partition by t3h.t3_po_id 
      order by poli.purchase_order_line_item_id
    )                                        as t3_line_number,
    poli.item_id                             as t3_item_id,
    poli.purchase_order_line_description     as t3_line_description,
    poli.purchase_order_line_memo            as t3_line_memo,
    poli.quantity                            as t3_qty_ordered,
    poli.price_per_unit                      as t3_ppu,
    (t3_qty_ordered * t3_ppu)                as t3_line_amount,
    itm.item_type                            as t3_item_type,
    pa.part_id                               as t3_part_id,
    case
        when t3_item_type = 'inventory' then pa.part_number  
        when t3_item_type <> 'inventory' then left(ninv.name,5)
    end                                      as t3_part_number,
    case
        when t3_item_type = 'inventory' then pa.description  
        when t3_item_type <> 'inventory' then substr(ninv.name,9)
    end                                      as t3_part_name,
    pa.search                                as t3_part_description,
    pr.name                                  as t3_part_provider_name,
    case
        when t3_item_type  = 'inventory' then 'a1301'
        when t3_item_type  = 'non_inventory' then left(ninv.name,5)
    end                                      as sage_item_id,
    poli._es_update_timestamp                as t3_updated_at,
    poli.date_archived                       as t3_date_archived,
from t3_po_header t3h
left join purchase_order_line_items poli
    on t3h.t3_po_id = poli.purchase_order_id
left join items itm 
    on poli.item_id = itm.item_id 
        and itm.company_id = 1854 -- companies besides eqs in there
left join non_inventory_items ninv
    on poli.item_id = ninv.item_id
left join parts pa
    on itm.item_id = pa.item_id
left join providers pr
    on pa.provider_id = pr.provider_id
