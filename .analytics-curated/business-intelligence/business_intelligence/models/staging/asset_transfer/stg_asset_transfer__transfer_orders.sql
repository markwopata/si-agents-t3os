with 

source as (

    select * from {{ source('asset_transfer', 'transfer_orders') }}

),

renamed as (

    select
        _es_update_timestamp
        , transfer_order_id as asset_transfer_order_id
        , transfer_order_number as asset_transfer_order_number
        , asset_id
        , company_id
        , from_branch_id
        , to_branch_id
        , status as transfer_status
        , transfer_type_id
        , is_rental_transfer
        , IFF(is_closed, false, true) as is_active_transfer

        , date_created
        , requester_id as requester_user_id
        , NULLIF(requester_note, '') as requester_note
        
        , date_rejected
        , date_request_cancelled

        , date_approved
        , approver_id as approver_user_id
        , approver_note

        , date_transfer_cancelled
        , NULLIF(cancellation_note, '') as cancellation_note

        , date_received
        , received_by_id as receiver_user_id

        , date_updated

    from source

)

select * from renamed
