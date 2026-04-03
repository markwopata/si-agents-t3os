SELECT
    p.payout_id,
    p.amount,
    p.equipment_assignment_id,
    p.description,
    p.line_item_id,
    p.company_id,
    p.bill_id,
    p.asset_id,
    p.payout_program_id,
    p.date_created,
    p._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payouts') }} as p
