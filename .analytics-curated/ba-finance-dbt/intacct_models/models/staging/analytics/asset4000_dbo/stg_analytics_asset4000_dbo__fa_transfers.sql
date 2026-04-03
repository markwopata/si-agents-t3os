with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__fa_transfers') }}

),

renamed as (

    select

        -- ids
        asset_code,

        -- numerics
        transfer_per_sequence,
        transfer_year,

        -- booleans
        _fivetran_deleted,

        -- dates
        transfer_date,
        
        -- timestamps
        tfr_timestamp,
        _fivetran_synced

    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
