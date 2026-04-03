with source as (

    select * from {{ source('analytics_concur', 'last_close_date_ap') }}

),

renamed as (

    select
        -- dates
        last_closed_date as period_end_date,

        -- timestamps
        last_modified

    from source

)

select * from renamed
