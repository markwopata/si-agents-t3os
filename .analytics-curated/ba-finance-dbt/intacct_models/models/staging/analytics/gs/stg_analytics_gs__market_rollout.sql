with source as (

    select * from {{ source('analytics_gs', 'market_rollout') }}

),

renamed as (

    select
        --  ids
        market_id,
        market_level,


        -- strings
        market_name,
        model_name,
        sales_model,
        xero_market_name,
        outside_service_model,

        -- numerics
        market_factor,

        -- dates
        financing_start_month,
        market_end_month::date market_end_month,
        market_start_month::date market_start_month,
        sale_leaseback_month,
        sales_start_month,
        outside_service_start_month,
        sale_leaseback,
        rental_model_start_month,
        branch_earnings_start_month::date branch_earnings_start_month,

        -- timestamps
        _fivetran_synced


    from source

)

select * from renamed
