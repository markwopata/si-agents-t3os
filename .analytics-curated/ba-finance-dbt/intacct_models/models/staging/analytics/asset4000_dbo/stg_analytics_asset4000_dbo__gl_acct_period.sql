with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_acct_period') }}

),

renamed as (

    select

        -- ids
        period_sequence,
        year,
        -- strings
        period_dsdepchg,
        period_name,
        period_closed_flag,
        period_lastinqtr,

        -- numerics
        period_number,
        period_units,
        period_sunits,

        -- booleans
        _fivetran_deleted,
        is_period_closed,

        -- dates
        period_start_date,
        period_end_date,
        
        -- timestamps
        _fivetran_synced

    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
