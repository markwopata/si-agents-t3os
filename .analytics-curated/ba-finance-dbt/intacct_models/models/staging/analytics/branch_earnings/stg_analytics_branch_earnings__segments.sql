with source as (

    select * from {{ source('analytics_branch_earnings', 'segments') }}

),

renamed as (

    select

        -- id
        pk_segment_id,

        -- strings
        segment

    from source

)

select * from renamed
