with source as (

    select * from {{ source('analytics_asset4000_dbo', 'fa_transfers') }}

),

renamed as (

    select

        -- ids
        ass_code as asset_code,

        -- numerics
        tfr_perseq as transfer_per_sequence,
        tfr_year as transfer_year,

        -- booleans
        _fivetran_deleted,

        -- dates
        tfr_date as transfer_date,
        
        -- timestamps
        tfr_timestamp,
        _fivetran_synced

    from source

)

select * from renamed
