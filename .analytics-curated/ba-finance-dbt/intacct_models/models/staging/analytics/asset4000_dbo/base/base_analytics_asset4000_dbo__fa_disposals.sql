with source as (

    select * from {{ source('analytics_asset4000_dbo', 'fa_disposals') }}

),

renamed as (

    select

        -- ids
        ass_code as asset_code,

        -- strings
        disp_reason as asset_disposal_reason,
        dsp_usr as asset_disposal_user_created_by,

        -- numerics
        disp_perseq as asset_disposal_period,
        disp_year as asset_disposal_year,

        -- booleans
        _fivetran_deleted,

        -- dates
        disp_date as asset_disposal_date,

        -- timestamps
        dsp_timestamp as asset_disposal_timestamp,
        _fivetran_synced

    from source

)

select * from renamed
