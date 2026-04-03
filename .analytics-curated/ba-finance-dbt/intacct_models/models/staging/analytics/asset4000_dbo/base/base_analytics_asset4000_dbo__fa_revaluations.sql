with source as (

    select * from {{ source('analytics_asset4000_dbo', 'fa_revaluations') }}

),

renamed as (

    select
        -- ids
        ass_code as asset_code,

        -- strings
        rvl_usr as revaluation_modified_by,
        reval_reason as revaluation_reason,

        -- booleans
        _fivetran_deleted,

        -- numerics
        reval_year as revaluation_year,
 
        -- dates 
        reval_date as revaluation_date,
        last_day(reval_date) as revaluation_month_end,

        -- timestamps
        rvl_timestamp as revaluation_timestamp,
        _fivetran_synced

    from source

)

select * from renamed