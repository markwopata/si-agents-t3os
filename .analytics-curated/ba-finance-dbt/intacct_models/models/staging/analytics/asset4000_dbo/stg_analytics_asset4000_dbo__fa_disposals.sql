with base as (

    select * from {{ ref('base_analytics_asset4000_dbo__fa_disposals') }}

),

renamed as (

    select

        -- ids
        asset_code,

        -- strings
        asset_disposal_reason,
        asset_disposal_user_created_by,

        -- numerics
        asset_disposal_period,
        asset_disposal_year,

        -- booleans
        _fivetran_deleted,

        -- dates
        asset_disposal_date,

        -- timestamps
        asset_disposal_timestamp,
        _fivetran_synced

    from base
    where _fivetran_deleted != TRUE

)

select * from renamed
