with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_ass_grpdetail_bk') }}

),

renamed as (

    select

        -- ids
        group_id,
        group_code,
        book_code,
        depreciation_code,

        -- strings
        change_type, -- drops characters after the special characters denoted and casts to number
        entity_name,
        disposal_type,
        acquisition_type,
        
        -- numerics
        useful_life_years,
        insure_percent_points,
        insure_percentage,
        capitalization_value,
        disposal_percent_points,
        disposal_percentage,
        residual_percent_points,
        residual_percentage,
        acquisition_percent_points,
        acquisition_percentage,

        -- booleans
        assgdbk_irs_electads,
        _fivetran_deleted,

        -- timestamps
        residual_percent_last_modified_timestamp,

        -- dates
        -- timestamps
        _fivetran_synced
        
    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
