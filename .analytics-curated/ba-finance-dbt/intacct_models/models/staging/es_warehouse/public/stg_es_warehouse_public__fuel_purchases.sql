SELECT
    fp.fuel_purchase_id,
    fp.address,
    fp.city,
    fp.purchase_date,
    fp.card_holder,
    fp.transaction_sequence_number,
    fp.purchase_code,
    fp.asset_id,
    fp.state_id,
    fp.purchase_code_id,
    fp.company_id,
    fp.purchase_price,
    fp.gallons_purchased,
    fp.cost_per_gallon,
    fp._es_update_timestamp
FROM {{ source('es_warehouse_public', 'fuel_purchases') }} as fp
