
-- pull new/dealership sales

-- all commission rate assignment is done on invoice level for new/dealership sales items
with dealership as (
    with base as (
        select 
            drsc.invoice_id,
            li.LINE_ITEM_ID,
            line_item_type_id,
            drsc.profit_margin,
            CASE
                WHEN drsc.profit_margin <= 0.00 THEN 64
                WHEN drsc.profit_margin <= 0.12 THEN 63
                WHEN drsc.profit_margin <= 0.14 THEN 62
                WHEN drsc.profit_margin <= 0.20 THEN 61
            ELSE 60 END AS rate_tier_id,
        from {{ ref("int_retail_sales_commissions") }} drsc
            left join {{ ref("stg_es_warehouse_public__line_items")}} li
                on drsc.invoice_id = li.invoice_id
        where (LINE_ITEM_TYPE_ID in (80, 140, 141, 152, 153) -- dealerships prior retool app
        AND date_created >= '2025-04-01'  -- if created before the retool app
        )         
    )
    select 
        base.invoice_id,
        base.line_item_id,
        base.line_item_type_id,

        null as nbv,
        base.profit_margin,

        null as FLOOR_RATE,
        null as BENCHMARK_RATE,
        null as ONLINE_RATE,

        base.rate_tier_id,
        crt.name as rate_tier_name,
        crt.commission_percentage as commission_rate
    from base 
        left join {{ ref("stg_analytics_rate_achievement__commission_rate_tiers") }} crt 
            on base.rate_tier_id = crt.rate_tier_id
),

used as (
    select 
        ursc.INVOICE_ID,
        ursc.LINE_ITEM_ID,
        li.line_item_type_id,

        ursc.NBV,
        ursc.PROFIT_MARGIN,
        
        ursc.FLOOR_RATE,
        ursc.BENCHMARK_RATE,
        ursc.ONLINE_RATE,

        ursc.rate_tier_id,
        ursc.rate_tier_name,
        ursc.COMMISSION_RATE,

    from {{ ref("int_retail_sales_commissions_used") }} ursc 
        left join {{ ref("stg_es_warehouse_public__line_items") }} li
            on li.line_item_id = ursc.line_item_id
)
select * 
from
    (select *, 'dealership' as source
    from dealership

    union all

    select *, 'used' as source
    from used) cd

where invoice_id is not null