select 
    asset_transfer_order_key
    , asset_transfer_order_id
    , asset_transfer_order_number
    , asset_transfer_order_asset_key
    , asset_transfer_order_company_key
    , asset_transfer_order_from_market_key
    , asset_transfer_order_to_market_key
    , asset_transfer_status
    , asset_transfer_type
    , is_rental_transfer
    , is_active_transfer

    , asset_transfer_order_created_date_key
    , asset_transfer_order_created_time_key
    , asset_transfer_order_requester_user_key
    , requester_note

    , asset_transfer_order_request_cancelled_date_key
    , asset_transfer_order_request_cancelled_time_key

    , asset_transfer_order_rejected_date_key
    , asset_transfer_order_rejected_time_key

    , asset_transfer_order_approved_date_key
    , asset_transfer_order_approved_time_key
    , approver_note
    , asset_transfer_order_approver_user_key

    , asset_transfer_order_transfer_cancelled_date_key
    , asset_transfer_order_transfer_cancelled_time_key
    , cancellation_note

    , asset_transfer_order_received_date_key
    , asset_transfer_order_received_time_key
    , asset_transfer_order_receiver_user_key

    , _created_recordtimestamp
    , _updated_recordtimestamp

from {{ ref('fact_asset_transfers_accumulating_snapshot') }}