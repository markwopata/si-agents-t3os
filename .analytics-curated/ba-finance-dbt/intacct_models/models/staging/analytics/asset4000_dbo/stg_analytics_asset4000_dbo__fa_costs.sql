with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__fa_costs') }}

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
        cost_per_sequence,
        cost_year,
        transfer_per_sequence,
        transfer_year,
        oec,
        period_depreciation_expense,
        year_to_date_depreciation_expense,
        nbv,
        gbv,
        life_used,

        -- dates
        depreciation_date,

        -- timestamp
        _fivetran_synced
    from source
    where _fivetran_deleted != TRUE
)

select * from renamed
