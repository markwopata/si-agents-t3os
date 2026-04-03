with source as (
    select * from {{ source('es_warehouse_time_tracking', 'time_entry_work_code_xref') }}
)

, renamed as (
    select
        -- ids
        time_entry_id,
        work_code_id,
        -- timestamp
        _es_update_timestamp
    from source
)
select * from renamed
