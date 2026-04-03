with quotes as (
    select
        quote_pk_id,
        quote_id,
        status,
        is_current,
        payment_method,
        invoice_id,
        company_id,
        company_name,
        billing_provider,
        market_id,
        type_of_sale,
        quote_created_at,
        quote_completed_at
    from {{ ref("stg_tools_trailer_retail_sales__quotes") }}
),

assets as (
    select
        a.pk_id,
        a.quote_pk_id,
        a.asset_pk_id,
        a.asset_id,
        a.serial_number,
        a.asset_type,
        upper(trim(a.make)) as make,
        upper(trim(a.model)) as model, -- noqa: RF04
        concat(a.make, '-', a.model, '-', a.serial_number) as description,
        a.rebate_oec,
        zeroifnull(a.sale_price) as sale_price,
        zeroifnull(a.oec) as oec
    from {{ ref("stg_tools_trailer_retail_sales__assets") }} as a
),

additional_costs as (
    select
        quote_pk_id,
        asset_pk_id,
        array_agg(object_construct('line_type', line_type, 'price', price, 'cost', cost, 'description', description))
            as line_description,
        sum(price) as additional_items_price,
        sum(cost) as additional_items_cost
    from {{ ref("stg_tools_trailer_retail_sales__cost_items") }}
    where line_type != 't3 subscription'
    group by all
),

rebate_items as (
    select
        quote_pk_id,
        asset_pk_id,
        array_agg(
            object_construct(
                'line_type', type_id, 'dollar', value_dollar, 'percent', value_percent, 'description', description
            )
        ) as rebate_description,
        sum(iff(amount_type = 'dollars', value_dollar, 0)) as rebate_dollars,
        sum(iff(amount_type = 'percent', value_percent, 0)) as rebate_percent
    from {{ ref("stg_tools_trailer_retail_sales__rebate_items") }}
    group by all
),

trade_ins as (
    select
        quote_pk_id,
        asset_pk_id,
        sum(trade_in_value) as total_trade_in_value,
        sum(trade_in_over_allowance) as total_trade_in_over_allowance
    from {{ ref("stg_tools_trailer_retail_sales__trade_ins") }}
    group by all
)

select
    a.pk_id,
    q.quote_created_at,
    q.quote_completed_at,
    q.status,
    q.quote_pk_id,
    q.quote_id,
    q.invoice_id,
    q.payment_method,
    q.billing_provider,
    q.company_id,
    q.company_name,
    q.type_of_sale,
    q.market_id,
    a.asset_pk_id,
    a.asset_type,
    a.asset_id,
    a.serial_number,
    a.make,
    a.model,
    a.description,
    a.rebate_oec,
    a.sale_price,
    a.oec,
    ac.line_description,
    ac.additional_items_price,
    ac.additional_items_cost,
    ri.rebate_description,
    ti.total_trade_in_value,
    ti.total_trade_in_over_allowance,
    a.sale_price + zeroifnull(ac.additional_items_price) as total_asset_price,
    a.oec + zeroifnull(ac.additional_items_cost) + zeroifnull(ti.total_trade_in_over_allowance) as total_asset_cost,
    round(zeroifnull(a.rebate_oec * ri.rebate_percent) + zeroifnull(ri.rebate_dollars), 2) as total_rebate,
    total_asset_price - (total_asset_cost - total_rebate) as total_margin,
    q.is_current
from quotes as q
    inner join assets as a
        on q.quote_pk_id = a.quote_pk_id
    left join additional_costs as ac
        on a.quote_pk_id = ac.quote_pk_id
            and a.asset_pk_id = ac.asset_pk_id
    left join rebate_items as ri
        on a.quote_pk_id = ri.quote_pk_id
            and a.asset_pk_id = ri.asset_pk_id
    left join trade_ins as ti
        on a.quote_pk_id = ti.quote_pk_id
            and a.asset_pk_id = ti.asset_pk_id
