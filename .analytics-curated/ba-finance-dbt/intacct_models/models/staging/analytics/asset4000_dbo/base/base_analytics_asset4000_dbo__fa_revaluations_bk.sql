with source as (

    select * from {{ source('analytics_asset4000_dbo', 'fa_revaluations_bk') }}

),

renamed as (

    select
        -- ids
        ass_code as asset_code,

        -- strings
        book_code,

        -- booleans
        _fivetran_deleted,

        -- numerics
        reval_year as revaluation_year,

        revalbk_new_gbv as revaluation_revalued_gbv,
        revalbk_old_gbv as revaluation_previous_gbv,

        revalbk_new_res as revaluation_revalued_salvage_value,
        revalbk_old_res as revaluation_previous_salvage_value,

        revalbk_new_min as revaluation_revalued_minimum_nbv,
        revalbk_old_min as revaluation_previous_minimum_nbv,

        -- dates

        -- timestamp
        _fivetran_synced
    from source

)

select * from renamed
