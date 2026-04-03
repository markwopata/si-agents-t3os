with source as (

    select * from {{ source('analytics_asset4000_dbo', 'fa_costs') }}

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
        cost_perseq as cost_per_sequence,
        cost_year,
        tfr_perseq as transfer_per_sequence,
        tfr_year as transfer_year,
        cost_gbv as oec,
        cost_perdep as period_depreciation_expense,
        cost_ytddep as year_to_date_depreciation_expense,
        cost_nbv as nbv,
        cost_gbv as gbv,
        cost_lifeused as life_used,

        -- dates
        last_day(date_from_parts(cost_year, cost_perseq, 1), month)::date as depreciation_date,

        -- timestamp
        _fivetran_synced
    from source

)

select * from renamed
