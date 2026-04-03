with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__fa_revaluations') }}

),

renamed as (

    select
        -- ids
        asset_code,

        -- strings
        revaluation_modified_by,
        revaluation_reason,

        -- booleans
        _fivetran_deleted,

        -- numerics
        revaluation_year,
 
        -- dates 
        revaluation_date,
        revaluation_month_end,
        
        -- timestamps
        revaluation_timestamp,
        _fivetran_synced

    from source
    where _fivetran_deleted != TRUE

)

select * from renamed