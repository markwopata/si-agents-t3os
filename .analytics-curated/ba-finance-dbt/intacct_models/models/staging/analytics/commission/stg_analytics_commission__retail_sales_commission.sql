with source as (
    select * from {{ source('analytics_commission', 'retail_sales_commission') }}
),

renamed as (
    select

        -- ids
        line_item_id,
        invoice_id,
        asset_id,
        salesperson_user_id,
        commission_type_id,

        -- strings
        rate_achievement,

        -- numerics
        commission_rate,
        nbv,
        line_item_amount,
        credit_amount,
        net_sales_price,
        profit,
        profit_margin,
        amount,
        floor_rate,
        benchmark_rate,
        online_rate,

        -- timestamps
        _es_date_created,

        -- bools
        new_calc_ind,
        used,
        new

    from source
)

select * from renamed
