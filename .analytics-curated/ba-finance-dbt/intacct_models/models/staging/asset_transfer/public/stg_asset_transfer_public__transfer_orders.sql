with source as (

    select * from {{ source('asset_transfer_public', 'transfer_orders') }}

),

renamed as (

    select
        -- IDs
        transfer_order_id,
        transfer_order_number,
        asset_id,
        to_branch_id,
        from_branch_id,
        requester_id,
        approver_id,
        received_by_id,
        cancelled_by_id,
        company_id,
        transfer_type_id,

        -- Strings / Notes / Text
        requester_note,
        approver_note,
        cancellation_note,
        status,

        -- Numerics

        -- Booleans
        iff(status = 'Approved', TRUE, FALSE) as is_in_transit,
        is_rental_transfer,
        is_closed,

        -- Dates
        date_created,
        date_updated,
        date_approved,
        date_received,
        date_rejected,
        date_transfer_cancelled,
        date_request_cancelled,

        -- Timestamps (metadata)
        _es_update_timestamp,
        _es_load_timestamp

    from source
)

select * from renamed
