with source as (

    select * from {{ source('analytics_public', 'regions') }}

),

renamed as (

    select

        -- ids
        _row,
        region_id,

        -- strings
        region_name

    from source

)

select * from renamed
