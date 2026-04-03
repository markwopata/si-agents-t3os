{{
    config(materialized='view',
        persist_docs={'columns': false}
    )
 }}

with base as (
    select
        ir.gl_date,
        ir.market_id,
        ir.market_name,
        ir.ship_from_state,
        ir.ship_from_city,
        ir.ship_to_state,
        ir.ship_to_city,
        case
        -- Rental Revenues
            when ir.is_rental_revenue then 'Rental Revenue'
            -- Sales Revenues
            when am.internal_is_grouping = 'Equipment Sales' then 'Sales Revenue'
        end as revenue_type,
        ard.amount,
        ir.src
    from {{ ref("ar_detail") }} as ard
        inner join {{ ref("int_revenue") }} as ir
            on ard.invoice_id = ir.invoice_id
                and ard.fk_admin_line_item_id = ir.line_item_id
        inner join
            {{ ref("stg_analytics_revmodel__account_mapping3") }} as am
            on ir.account_number = am.accountno
    where true
        and (
            am.internal_is_grouping = 'Equipment Sales'
            or ir.is_rental_revenue
        )
        -- am.internal_is_grouping = 'Equipment Sales' includes COGs, am.cost_revenue excludes most COGs
        and am.cost_revenue = 'R'
        -- leftover COGs account, COGS - OWN Agent Equipment Sales under Revenues.
        and am.accountno != '5160'
        -- Exclude any invoices/credits that net to 0 (no revenue was generated in this case)
    qualify sum(ir.amount) over (partition by ir.invoice_number) > 0
)

select
    gl_date,
    market_id,
    market_name,
    ship_from_state,
    ship_from_city,
    ship_to_state,
    ship_to_city,
    revenue_type,
    sum(amount) as revenue_amount
from base
where src = 'invoices'
group by all
