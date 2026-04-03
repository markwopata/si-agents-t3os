with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__fa_revaluations_bk') }}

),

renamed as (

    select
        -- ids
        asset_code,

        -- strings
        book_code,

        -- booleans
        _fivetran_deleted,

        -- numerics
        revaluation_year,

        revaluation_revalued_gbv,
        revaluation_previous_gbv,

        revaluation_revalued_salvage_value,
        revaluation_previous_salvage_value,

        revaluation_revalued_minimum_nbv,
        revaluation_previous_minimum_nbv,

        -- dates

        -- timestamp
        _fivetran_synced
    from source
    where _fivetran_deleted != TRUE
)

select * from renamed
