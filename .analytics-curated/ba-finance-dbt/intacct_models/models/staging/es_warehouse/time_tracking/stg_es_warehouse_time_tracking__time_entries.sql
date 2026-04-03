with source as (
    select * from {{ source('es_warehouse_time_tracking', 'time_entries') }}
)

, renamed as (
    select
        -- ids
        time_entry_id,
        user_id,
        event_type_id,
        source_application_id,
        created_by_id,
        work_order_id,
        job_id,
        branch_id,
        asset_id,
        note_id,

        -- strings
        approval_status,
        overtime_state,
        overtime_json,

        -- numerics
        overtime_hours,
        regular_hours,

        -- booleans
        needs_revision,
        is_revision,
        archived,

        -- timestamps
        archived_date,
        created_date,
        start_date,
        end_date,
        _es_update_timestamp
    
    from source
)

select * from renamed
