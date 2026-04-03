with source as (
    select * from {{ source('es_warehouse_time_tracking', 'work_codes') }}
)
 
, renamed as (
    select
        -- ids
        work_code_id,
        custom_id,
        organization_id,
        created_by_user_id,

        -- strings

        work_code_type,
        name,
        description,

        -- boolean
        deleted,

        -- timestamp
        created_date,
        _es_update_timestamp

    from source
)
select * from renamed
