with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_acct_period') }}

),

renamed as (

    select

        -- ids
        period_seq as period_sequence,
        year_ram as year,

        -- strings
        nullif(period_dsdepchg, '') as period_dsdepchg,
        period_desc as period_name,
        nullif(period_closed, '') as period_closed_flag,
        nullif(period_lastinqtr, '') as period_lastinqtr,

        -- numerics
        period as period_number,
        period_units,
        period_sunits,

        -- booleans
        _fivetran_deleted,

        case 
            when period_closed_flag = 'C' then true
            when period_closed_flag = 'O' then false
        end as is_period_closed,

        -- dates
        period_start::date as period_start_date, -- drop timestamp because end_date's time is 00:00:00
        period_end::date as period_end_date, -- drop timestamp because end_date's time is 00:00:00
 
        -- timestamps

        _fivetran_synced

    from source

)

select * from renamed