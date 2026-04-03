with assets as (
    select
        pk_id as quote_asset_pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_id,
        asset_id,
        serial_number,
        upper(trim(make)) as make,
        upper(trim(model)) as model, -- noqa: RF04
        object_construct('make', make, 'model', model, 'serial_number', serial_number) as description,
        rebate_oec,
        zeroifnull(sale_price) as sale_price,
        zeroifnull(oec) as oec
    from {{ ref("stg_tools_trailer_retail_sales__assets") }}
),

additional_items as (
    select
        pk_id,
        quote_pk_id,
        asset_pk_id,
        concat(quote_pk_id, '-', asset_pk_id) as quote_asset_pk_id,
        quote_id,
        line_type,
        object_construct('line_type', line_type, 'price', price, 'cost', cost, 'description', description)
            as description,
        price,
        cost
    from {{ ref("stg_tools_trailer_retail_sales__cost_items") }}
),

rebates as (
    select
        ri.pk_id,
        ri.quote_pk_id,
        ri.asset_pk_id,
        concat(ri.quote_pk_id, '-', ri.asset_pk_id) as quote_asset_pk_id,
        ri.quote_id,
        ri.type_id as line_type,
        object_construct(
            'line_type',
            ri.type_id,
            'dollar',
            ri.value_dollar,
            'percent',
            ri.value_percent,
            'rebate OEC',
            a.rebate_oec,
            'description',
            ri.description
        )
            as description,
        0 as price,
        -- Rebate is shown as a negative cost (reduces the cost of the asset)
        case
            when ri.amount_type = 'dollars' then (ri.value_dollar)
            when ri.amount_type = 'percent' then round((ri.value_percent * a.rebate_oec), 2)
            else 0
        end as cost
    from {{ ref("stg_tools_trailer_retail_sales__rebate_items") }} as ri
        left join assets as a
            on concat(ri.quote_pk_id, '-', ri.asset_pk_id) = a.quote_asset_pk_id
),

trade_ins as (
    select
        pk_id,
        quote_pk_id,
        asset_pk_id,
        concat(quote_pk_id, '-', asset_pk_id) as quote_asset_pk_id,
        quote_id,
        object_construct(
            'asset_id', asset_id,
            'build_spec', build_spec,
            'hours', hours,
            'make', make,
            'model', model,
            'model_year', model_year,
            'payoff_amount', payoff_amount,
            'serial_number', serial_number,
            'trade_in_over_allowance', trade_in_over_allowance,
            'trade_in_value', trade_in_value
        ) as description,
        'trade in over allowance' as line_type,
        0 as price,
        trade_in_over_allowance as cost
    from {{ ref("stg_tools_trailer_retail_sales__trade_ins") }}
    where trade_in_over_allowance != 0
),

asset_lines as (
    select
        quote_asset_pk_id as pk_id,
        quote_pk_id,
        asset_pk_id,
        description,
        concat(quote_pk_id, '-', asset_pk_id) as quote_asset_pk_id,
        quote_id,
        'asset' as line_type,
        sale_price as price,
        oec as cost
    from assets
),

unioned_output as (

----------- /* Asset Section */ ------------
    select
        concat(pk_id, '-C') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'cost' as cost_revenue,
        line_type,
        cost * -1 as amount
    from asset_lines

    union all

    select
        concat(pk_id, '-R') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'revenue' as cost_revenue,
        line_type,
        price as amount
    from asset_lines

    ----------- /* Additional Items Section */ ------------
    union all

    select
        concat(pk_id, '-C') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'cost' as cost_revenue,
        line_type,
        cost * -1 as amount
    from additional_items

    union all

    select
        concat(pk_id, '-R') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'revenue' as cost_revenue,
        line_type,
        price as amount
    from additional_items

    ----------- /* Rebates Section */ ------------
    union all

    select
        concat(pk_id, '-C') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'cost' as cost_revenue,
        line_type,
        cost as amount
    from rebates

    ----------- /* Trade Ins Section */ ------------
    union all

    select
        concat(pk_id, '-C') as pk_id,
        quote_pk_id,
        asset_pk_id,
        quote_asset_pk_id,
        quote_id,
        description,
        'cost' as cost_revenue,
        line_type,
        cost * -1 as amount
    from trade_ins
)

select
    uo.pk_id,
    uo.quote_pk_id,
    uo.asset_pk_id,
    uo.quote_asset_pk_id,
    uo.quote_id,
    a.asset_id,
    uo.description,
    uo.cost_revenue,
    uo.line_type,
    uo.amount,
    q.quote_created_at,
    q.quote_completed_at,
    q.billing_provider,
    q.company_id,
    q.company_name,
    q.invoice_id,
    q.market_id,
    q.status,
    q.is_current
from unioned_output as uo
    inner join {{ ref("stg_tools_trailer_retail_sales__quotes") }} as q
        on uo.quote_pk_id = q.quote_pk_id
    left join assets as a
        on uo.quote_asset_pk_id = a.quote_asset_pk_id
