with source as (
    select * from {{ source('procurement_public', 'purchase_orders') }}
),

renamed as (
    select
        purchase_order_id,
        vendor_id,
        company_id,
        created_by_id,
        modified_by_id,
        requesting_branch_id,
        deliver_to_id,
        external_po_id,
        store_id,
        vendor_snapshot_id,
        deliver_to_snapshot_id,
        cost_center_snapshot_id,

        -- strings
        purchase_order_number,
        reference,
        status,
        search,
        'https://costcapture.estrack.com/purchase-orders/' || purchase_order_id || '/detail' as url_t3,

        -- numerics
        amount_approved,

        --booleans
        is_external,

        -- timestamps
        date_created,
        date_updated,
        promise_date,
        _es_update_timestamp,
        date_archived

    from source
)

select * from renamed
