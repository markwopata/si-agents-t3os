-- TODO: Make this an incremental model
with source_data as (

    select
        li.line_item_id,
        grace_period_flag,
        deal_floor_flag,
        rate_tier_id,
        rac.business_segment_id,
        deal_floor,
        floor_rate,
        book_rate,
        '{{ this.name }}' as source_model
    from {{ ref("stg_es_warehouse_public__line_items") }} as li
        inner join
            {{ ref("stg_es_warehouse_public__invoices") }} as i
            on li.invoice_id = i.invoice_id
        left join
            {{ ref("stg_analytics_rate_achievement__rate_achievement_commissions") }} as rac
            on li.line_item_id = rac.line_item_id
    where
        li.line_item_type_id in ('129', '130', '131')  -- onsite fuel delivery line items
        and i.billing_approved_date::date >= '2024-09-01'
)

select *
from source_data
