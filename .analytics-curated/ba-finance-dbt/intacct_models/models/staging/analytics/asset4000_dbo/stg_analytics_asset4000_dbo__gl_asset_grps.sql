with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_asset_grps') }}

),

renamed as (

    select
    
        -- ids
        asset_code,
        market_id,

        -- strings
        asset_class,
        address,

        -- numerics
        asset_account,
        accumulated_depreciation_account,
        depreciation_expense_account,

        -- booleans
        _fivetran_deleted,

        -- timestamps
        asset_gl_assignment_date,
        next_gl_assignment_date,
        _fivetran_synced

    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
