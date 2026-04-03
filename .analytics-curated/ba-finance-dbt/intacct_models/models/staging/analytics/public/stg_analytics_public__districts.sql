with source as (
    select * from {{ source('analytics_public', 'districts') }}
),

renamed as (
    select
        id,
        district_id,
        region_id
    from source
)

select * from renamed
