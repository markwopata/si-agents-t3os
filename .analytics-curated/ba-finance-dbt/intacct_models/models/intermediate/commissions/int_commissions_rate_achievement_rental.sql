-- TODO: Make this an incremental model
with source_data as (
    select
        li.line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        itl_rep_rate_tier_id,
        rac.business_segment_id,
        ec.name as equipment_class_name,
        ec.equipment_class_id,
        deal_floor,
        floor_rate,
        benchmark_rate,
        book_rate,
        '{{ this.name }}' as source_model
    from {{ ref("stg_es_warehouse_public__line_items") }} as li
        inner join
            {{ ref("stg_es_warehouse_public__invoices") }} as i
            on li.invoice_id = i.invoice_id
        left join
            {{ ref("stg_es_warehouse_public__rentals") }} as r
            on li.rental_id = r.rental_id
        left join
            {{ ref("stg_es_warehouse_public__equipment_classes") }} as ec
            on r.equipment_class_id = ec.equipment_class_id
        left join
            {{ ref("stg_es_warehouse_public__orders") }} as ord
            on r.order_id = ord.order_id
        left join
            {{ ref("stg_es_warehouse_public__markets") }} as m
            on ord.market_id = m.market_id
        inner join
            {{ ref("stg_analytics_rate_achievement__rate_achievement_commissions") }} as rac
            on li.line_item_id = rac.line_item_id

    where
        li.line_item_type_id = 8
        and i.billing_approved_date::date >= '2024-09-01'
)

select distinct
    *,
    current_timestamp() as _es_update_timestamp
from source_data
