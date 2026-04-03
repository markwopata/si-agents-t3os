with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_asset_bk') }}

),

renamed as (

    select
        -- ids
        asset_code,

        -- strings
        book_code,
        irs_depreciation_convention,
        asset_acquisition_type,


        -- numerics
        asset_purchase_cost,
        depreciation_acquisition_percentage,
        asset_minimum_value,
        asset_residual_value,
        irs_bonus_depreciation_amount,

        -- booleans
        is_asset_auctioned,

        -- dates
        asset_expiration_date,
        asset_depreciation_start_date,

        -- timestamps
        _fivetran_synced
    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
