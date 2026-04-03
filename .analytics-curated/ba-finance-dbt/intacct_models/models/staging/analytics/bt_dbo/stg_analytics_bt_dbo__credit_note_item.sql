select
    productbatchid as product_batch_id,
    productbatchquantitytally as product_batch_quantity_tally,
    creditnoteid as credit_note_id,
    creditnoteitemid as credit_note_item_id,
    productbatchcostperid as product_batch_cost_per_id,
    productbatchquantity as product_batch_quantity,
    pickingnoteitemid as picking_note_item_id,
    plateid as plate_id,
    productbatchquantityperid as product_batch_quantity_per_id,
    packid as pack_id,
    productbatchitemid as product_batch_item_id,
    creditnotelineid as credit_note_line_id,
    productbatchunitcostprice as product_batch_unit_cost_price,
    _fivetran_deleted,
    _fivetran_synced

from {{ source('analytics_bt_dbo', 'creditnoteitem') }}
